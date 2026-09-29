import 'dart:async';
import 'dart:math';

import '../models/models.dart';

/// Result of trying to hold seats on a departure.
sealed class HoldResult {
  const HoldResult();
}

class HoldOk extends HoldResult {
  const HoldOk(this.hold);
  final SeatHold hold;
}

class HoldRejected extends HoldResult {
  const HoldRejected(this.seatsLeft, this.reason);
  final int seatsLeft;
  final String reason;
}

/// Result of confirming a hold after payment.
sealed class ConfirmResult {
  const ConfirmResult();
}

class ConfirmOk extends ConfirmResult {
  const ConfirmOk(this.booking);
  final Booking booking;
}

class ConfirmFailed extends ConfirmResult {
  const ConfirmFailed(this.reason);
  final String reason;
}

/// Single source of truth for seat inventory.
///
/// Every mutation (hold, confirm, release, cancel, remote booking from an
/// operator feed) runs as one synchronous critical section, so two requests
/// for the last seat are always serialized: exactly one wins. On a real
/// backend the same rule is a single conditional UPDATE
/// (`seats_left >= :n`) inside a transaction.
///
/// Seats are counted as `capacity - booked - held(unexpired)`, so a hold
/// removes seats from sale immediately and a failed or timed-out payment
/// puts them straight back.
class AvailabilityEngine {
  AvailabilityEngine({
    required Iterable<Departure> departures,
    Map<String, int> initialBooked = const {},
    DateTime Function()? clock,
    Random? random,
  })  : _clock = clock ?? DateTime.now,
        _random = random ?? Random() {
    for (final d in departures) {
      _departures[d.id] = d;
      _booked[d.id] = (initialBooked[d.id] ?? 0).clamp(0, d.capacity);
    }
  }

  final DateTime Function() _clock;
  final Random _random;
  final Map<String, Departure> _departures = {};
  final Map<String, int> _booked = {};
  final Map<String, SeatHold> _holds = {};
  final Map<String, Booking> _bookings = {};
  final Set<String> _blockedBoats = {};
  final Set<String> _issuedIds = {};
  final _events = StreamController<InventoryEvent>.broadcast();
  int _holdSeq = 0;

  /// Every inventory change, for live UI updates and the audit log.
  Stream<InventoryEvent> get events => _events.stream;

  DateTime get now => _clock();

  Departure? departure(String id) => _departures[id];

  Iterable<Departure> departuresFor(String boatId, DateTime day) =>
      _departures.values.where((d) => d.boatId == boatId && _sameDay(d.date, day)).toList()
        ..sort((a, b) => a.time.compareTo(b.time));

  Iterable<Departure> get allDepartures => _departures.values;

  bool isBlocked(String boatId) => _blockedBoats.contains(boatId);

  int booked(String departureId) => _booked[departureId] ?? 0;

  int held(String departureId) {
    _expireHolds();
    return _holds.values.where((h) => h.departureId == departureId).fold(0, (sum, h) => sum + h.seats);
  }

  /// Seats a new guest can still buy right now.
  int seatsLeft(String departureId) {
    final d = _departures[departureId];
    if (d == null || isBlocked(d.boatId)) return 0;
    return max(0, d.capacity - booked(departureId) - held(departureId));
  }

  /// Atomically reserve [seats] for [holder] for [ttl].
  HoldResult hold(
    String departureId,
    int seats, {
    required String holder,
    Duration ttl = const Duration(minutes: 10),
  }) {
    final d = _departures[departureId];
    if (d == null) return const HoldRejected(0, 'Unknown departure');
    if (isBlocked(d.boatId)) {
      return const HoldRejected(0, 'Boat is not taking bookings');
    }
    if (seats <= 0) return HoldRejected(seatsLeft(departureId), 'No seats');
    final left = seatsLeft(departureId);
    if (left < seats) {
      return HoldRejected(left, 'No seats available');
    }
    final h = SeatHold(
      id: 'H${++_holdSeq}',
      departureId: departureId,
      seats: seats,
      holder: holder,
      expiresAt: now.add(ttl),
    );
    _holds[h.id] = h;
    _emit(InventoryEventKind.held, departureId, seats, holder);
    return HoldOk(h);
  }

  /// Turn a hold into a booking. A failed payment or an expired hold
  /// releases the seats instead.
  ConfirmResult confirm(
    String holdId, {
    required bool paymentOk,
    required int total,
    required String currency,
  }) {
    _expireHolds();
    final h = _holds.remove(holdId);
    if (h == null) {
      return const ConfirmFailed('Hold expired, seats were released');
    }
    if (!paymentOk) {
      _emit(InventoryEventKind.released, h.departureId, h.seats, h.holder);
      return const ConfirmFailed('Payment failed, seats were released');
    }
    _booked[h.departureId] = booked(h.departureId) + h.seats;
    final d = _departures[h.departureId]!;
    final b = Booking(
      id: _newBookingId(d.date),
      departureId: h.departureId,
      boatId: d.boatId,
      guests: h.seats,
      total: total,
      currency: currency,
      holder: h.holder,
      createdAt: now,
    );
    _bookings[b.id] = b;
    _emit(InventoryEventKind.booked, h.departureId, h.seats, h.holder);
    return ConfirmOk(b);
  }

  /// Give a hold back without paying (user left checkout).
  void release(String holdId) {
    final h = _holds.remove(holdId);
    if (h != null) {
      _emit(InventoryEventKind.released, h.departureId, h.seats, h.holder);
    }
  }

  /// Cancel a booking and put its seats back on sale instantly.
  bool cancel(String bookingId, {BookingStatus as = BookingStatus.cancelled}) {
    final b = _bookings[bookingId];
    if (b == null || b.status == BookingStatus.cancelled || b.status == BookingStatus.weatherCancelled) {
      return false;
    }
    b.status = as;
    _booked[b.departureId] = max(0, booked(b.departureId) - b.guests);
    _emit(InventoryEventKind.cancelled, b.departureId, b.guests, b.holder);
    return true;
  }

  /// Register an existing booking (e.g. seeded history) without touching seats.
  void adopt(Booking b) {
    _bookings[b.id] = b;
    _issuedIds.add(b.id);
  }

  Booking? booking(String id) => _bookings[id];

  /// A booking made on the operator's own system (Nausys / Ankor / manual).
  /// Goes through the same hold + confirm path, so it competes fairly with
  /// in-app guests for the last seats.
  ConfirmResult applyRemoteBooking(
    String departureId,
    int seats,
    SyncSource source,
  ) {
    final r = hold(departureId, seats, holder: source.label);
    if (r is HoldRejected) return ConfirmFailed(r.reason);
    return confirm((r as HoldOk).hold.id, paymentOk: true, total: 0, currency: 'AUD');
  }

  /// Operator blocks a boat: it disappears from availability immediately.
  void setBlocked(String boatId, bool blocked) {
    final changed = blocked ? _blockedBoats.add(boatId) : _blockedBoats.remove(boatId);
    if (!changed) return;
    for (final d in _departures.values.where((d) => d.boatId == boatId)) {
      _emit(blocked ? InventoryEventKind.blocked : InventoryEventKind.unblocked, d.id, 0, 'operator');
    }
  }

  int totalCapacity(DateTime day) =>
      _departures.values.where((d) => _sameDay(d.date, day)).fold(0, (s, d) => s + d.capacity);

  int totalBooked(DateTime day) =>
      _departures.values.where((d) => _sameDay(d.date, day)).fold(0, (s, d) => s + booked(d.id));

  /// Never true by construction; exposed for the operator console + tests.
  int get overbookedDepartures => _departures.values.where((d) => booked(d.id) > d.capacity).length;

  void dispose() => _events.close();

  void _expireHolds() {
    final t = now;
    final dead = _holds.values.where((h) => !h.expiresAt.isAfter(t)).toList();
    for (final h in dead) {
      _holds.remove(h.id);
      _emit(InventoryEventKind.expired, h.departureId, h.seats, h.holder);
    }
  }

  /// BTG-YY-MMDD-XXXX, unique for the lifetime of the engine.
  String _newBookingId(DateTime date) {
    const alphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
    String id;
    do {
      final suffix = List.generate(4, (_) => alphabet[_random.nextInt(alphabet.length)]).join();
      id = 'BTG-${(date.year % 100).toString().padLeft(2, '0')}-'
          '${date.month.toString().padLeft(2, '0')}'
          '${date.day.toString().padLeft(2, '0')}-$suffix';
    } while (!_issuedIds.add(id));
    return id;
  }

  void _emit(InventoryEventKind k, String depId, int seats, String source) {
    if (!_events.isClosed) _events.add(InventoryEvent(k, depId, seats, source));
  }

  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
