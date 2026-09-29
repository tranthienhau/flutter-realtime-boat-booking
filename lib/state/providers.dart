import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../engine/availability_engine.dart';
import '../models/models.dart';

/// Turn the simulated operator feed off for deterministic screenshots/tests.
final liveFeedEnabledProvider = Provider<bool>((_) => const bool.fromEnvironment('LIVE_FEED', defaultValue: true));

/// Demo clock: starts at 09:00 on the fixed demo day and runs in real time,
/// so hold countdowns tick while dates stay reproducible.
final clockProvider = Provider<DateTime Function()>((ref) {
  final start = DateTime.now();
  final base = kToday.add(const Duration(hours: 9));
  return () => base.add(DateTime.now().difference(start));
});

final engineProvider = Provider<AvailabilityEngine>((ref) {
  final deps = buildDepartures();
  final engine = AvailabilityEngine(
    departures: deps,
    initialBooked: buildInitialBooked(deps),
    clock: ref.watch(clockProvider),
  );
  for (final b in seededBookings()) {
    engine.adopt(b);
  }
  engine.setBlocked('bali46', true);
  ref.onDispose(engine.dispose);
  return engine;
});

/// Bumps on every inventory change and once a second (for "synced Ns ago").
/// Widgets that show availability watch this to stay live without refresh.
final liveTickProvider = StreamProvider<int>((ref) {
  final engine = ref.watch(engineProvider);
  final controller = StreamController<int>();
  var n = 0;
  final sub = engine.events.listen((_) => controller.add(++n));
  final timer = Timer.periodic(const Duration(seconds: 1), (_) => controller.add(++n));
  controller.add(0);
  ref.onDispose(() {
    sub.cancel();
    timer.cancel();
    controller.close();
  });
  return controller.stream;
});

class SyncState {
  const SyncState(this.lastSync, this.boatsBySource, this.remoteEvents);
  final Map<SyncSource, DateTime> lastSync;
  final Map<SyncSource, int> boatsBySource;
  final int remoteEvents;

  int secondsAgo(SyncSource s, DateTime now) => max(0, now.difference(lastSync[s] ?? now).inSeconds);
}

/// Simulated Nausys / Ankor / manual feeds. Each source "polls" on its own
/// cadence; Nausys and Ankor also push occasional bookings and cancellations
/// onto departures, which flow through the same engine as in-app bookings.
class SyncController extends Notifier<SyncState> {
  Timer? _timer;
  final _rnd = Random(3);
  final _remoteBookings = <String>[];

  @override
  SyncState build() {
    final now = ref.read(clockProvider)();
    ref.onDispose(() => _timer?.cancel());
    if (ref.watch(liveFeedEnabledProvider)) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) => _tick());
    }
    return SyncState(
      {
        SyncSource.nausys: now.subtract(const Duration(seconds: 8)),
        SyncSource.ankor: now.subtract(const Duration(seconds: 21)),
        SyncSource.manual: now.subtract(const Duration(minutes: 4)),
      },
      {SyncSource.nausys: 142, SyncSource.ankor: 58, SyncSource.manual: 6},
      0,
    );
  }

  void _tick() {
    final engine = ref.read(engineProvider);
    final now = ref.read(clockProvider)();
    final source = _rnd.nextBool() ? SyncSource.nausys : SyncSource.ankor;
    final last = {...state.lastSync, source: now};
    // Background churn away from the departures the demo walks through.
    final pool = engine.allDepartures
        .where((d) => d.boatId != 'lagoon380' && d.boatId != 'prometheus' && d.date.isAfter(kToday))
        .toList();
    final d = pool[_rnd.nextInt(pool.length)];
    if (_remoteBookings.isNotEmpty && _rnd.nextInt(3) == 0) {
      engine.cancel(_remoteBookings.removeAt(0));
    } else {
      final r = engine.applyRemoteBooking(d.id, 1 + _rnd.nextInt(2), source);
      if (r is ConfirmOk) _remoteBookings.add(r.booking.id);
    }
    state = SyncState(last, state.boatsBySource, state.remoteEvents + 1);
  }

  void markSynced(SyncSource s) {
    state = SyncState({...state.lastSync, s: ref.read(clockProvider)()}, state.boatsBySource, state.remoteEvents);
  }
}

final syncProvider = NotifierProvider<SyncController, SyncState>(SyncController.new);

final signedInProvider = StateProvider<bool>((_) => false);

/// Bottom tab: 0 Explore, 1 Search, 2 Bookings, 3 Profile.
final tabProvider = StateProvider<int>((_) => 0);

class SearchQuery {
  const SearchQuery({
    required this.destinationId,
    required this.date,
    required this.guests,
    this.onlyAvailable = true,
  });
  final String destinationId;
  final DateTime date;
  final int guests;
  final bool onlyAvailable;

  SearchQuery copyWith({String? destinationId, DateTime? date, int? guests, bool? onlyAvailable}) => SearchQuery(
        destinationId: destinationId ?? this.destinationId,
        date: date ?? this.date,
        guests: guests ?? this.guests,
        onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      );
}

final searchProvider = StateProvider<SearchQuery>((_) => SearchQuery(destinationId: 'bali', date: kTripDay, guests: 4));

class SearchHit {
  const SearchHit(this.boat, this.departures);
  final Boat boat;
  final List<(Departure, int)> departures;
  int get bestLeft => departures.fold(0, (m, d) => max(m, d.$2));
}

/// Boats in a destination on a date. With [SearchQuery.onlyAvailable] only
/// boats with at least one departure that fits the party are returned.
List<SearchHit> runSearch(AvailabilityEngine engine, SearchQuery q) {
  final hits = <SearchHit>[];
  for (final b in kBoats.where((b) => b.destinationId == q.destinationId)) {
    if (engine.isBlocked(b.id)) continue;
    final deps = engine
        .departuresFor(b.id, q.date)
        .map((d) => (d, engine.seatsLeft(d.id)))
        .where((x) => !q.onlyAvailable || x.$2 >= q.guests)
        .toList();
    if (deps.isEmpty) continue;
    hits.add(SearchHit(b, deps));
  }
  return hits;
}

final searchResultsProvider = Provider<List<SearchHit>>((ref) {
  ref.watch(liveTickProvider);
  return runSearch(ref.watch(engineProvider), ref.watch(searchProvider));
});

/// The guest's bookings, newest first.
class BookingsController extends Notifier<List<Booking>> {
  @override
  List<Booking> build() {
    final engine = ref.watch(engineProvider);
    return seededBookings().map((b) => engine.booking(b.id) ?? b).toList();
  }

  void add(Booking b) => state = [b, ...state];

  bool cancel(String id) {
    final ok = ref.read(engineProvider).cancel(id);
    if (ok) state = [...state];
    return ok;
  }

  void clear() => state = [];
}

final bookingsProvider = NotifierProvider<BookingsController, List<Booking>>(BookingsController.new);

/// Checkout flow: select departure -> hold -> pay.
class CheckoutState {
  const CheckoutState({
    this.boatId = 'lagoon380',
    DateTime? date,
    this.departureId,
    this.adults = 2,
    this.children = 1,
    this.hold,
    this.lastBooking,
    this.lostDepartureId,
  }) : _date = date;

  final String boatId;
  final DateTime? _date;
  final String? departureId;
  final int adults;
  final int children;
  final SeatHold? hold;
  final Booking? lastBooking;
  final String? lostDepartureId;

  DateTime get date => _date ?? kTripDay;
  int get guests => adults + children;

  CheckoutState copyWith({
    String? boatId,
    DateTime? date,
    String? departureId,
    int? adults,
    int? children,
    SeatHold? hold,
    bool clearHold = false,
    Booking? lastBooking,
    String? lostDepartureId,
  }) =>
      CheckoutState(
        boatId: boatId ?? this.boatId,
        date: date ?? this.date,
        departureId: departureId ?? this.departureId,
        adults: adults ?? this.adults,
        children: children ?? this.children,
        hold: clearHold ? null : (hold ?? this.hold),
        lastBooking: lastBooking ?? this.lastBooking,
        lostDepartureId: lostDepartureId ?? this.lostDepartureId,
      );
}

enum HoldOutcome { held, lostRace, notEnough }

class CheckoutController extends Notifier<CheckoutState> {
  /// When on, the first attempt at the demo's last-seats departure arrives at
  /// the same moment as a Nausys booking for the same seats (RTB-001 live).
  bool raceDemo = true;

  @override
  CheckoutState build() => CheckoutState(departureId: depId('lagoon380', kTripDay, '13:30'));

  void start(String boatId, DateTime date) {
    _releaseHold();
    state = CheckoutState(boatId: boatId, date: date, adults: state.adults, children: state.children);
    selectDate(date);
  }

  /// Pick a day; preselect the first departure that still fits the party.
  void selectDate(DateTime d) {
    final engine = ref.read(engineProvider);
    final deps = engine.departuresFor(state.boatId, d).toList();
    if (deps.isEmpty) return;
    final fit = deps.where((x) => engine.seatsLeft(x.id) >= state.guests);
    state = state.copyWith(date: d, departureId: (fit.isEmpty ? deps.first : fit.first).id);
  }

  void selectDeparture(String id) => state = state.copyWith(departureId: id);
  void setAdults(int n) => state = state.copyWith(adults: n.clamp(1, 12));
  void setChildren(int n) => state = state.copyWith(children: n.clamp(0, 8));

  HoldOutcome holdSeats() {
    final engine = ref.read(engineProvider);
    final id = state.departureId!;
    final isDemoRace = raceDemo && id == depId('lagoon380', kTripDay, '13:30');
    if (isDemoRace) {
      raceDemo = false;
      // Another guest on the operator's Nausys calendar books the same
      // seats in the same instant. The engine serializes both; Nausys wins.
      engine.applyRemoteBooking(id, engine.seatsLeft(id), SyncSource.nausys);
      ref.read(syncProvider.notifier).markSynced(SyncSource.nausys);
    }
    final r = engine.hold(id, state.guests, holder: kGuestName);
    if (r is HoldOk) {
      state = state.copyWith(hold: r.hold);
      return HoldOutcome.held;
    }
    state = state.copyWith(lostDepartureId: id);
    return isDemoRace || (r as HoldRejected).seatsLeft == 0 ? HoldOutcome.lostRace : HoldOutcome.notEnough;
  }

  /// Alternatives for the "No seats available" sheet, live from inventory.
  List<(Departure, int)> alternatives() {
    final engine = ref.read(engineProvider);
    final lost = engine.departure(state.lostDepartureId ?? state.departureId!)!;
    final out = <(Departure, int)>[];
    for (final day in [lost.date, lost.date.add(const Duration(days: 1))]) {
      for (final b in [state.boatId, 'blue-horizon']) {
        for (final d in engine.departuresFor(b, day)) {
          final left = engine.seatsLeft(d.id);
          if (d.id != lost.id && left >= state.guests) out.add((d, left));
        }
      }
    }
    out.sort((a, b) {
      final sameBoatA = a.$1.boatId == state.boatId ? 0 : 1;
      final sameBoatB = b.$1.boatId == state.boatId ? 0 : 1;
      final c = a.$1.date.compareTo(b.$1.date);
      return c != 0
          ? c
          : sameBoatA != sameBoatB
              ? sameBoatA - sameBoatB
              : a.$1.time.compareTo(b.$1.time);
    });
    return out.take(3).toList();
  }

  void switchTo(Departure d) => state = state.copyWith(boatId: d.boatId, date: d.date, departureId: d.id);

  int totalFor(Boat b) => b.pricePerGuest * state.guests + 100;

  Booking? pay({bool paymentOk = true}) {
    final h = state.hold;
    if (h == null) return null;
    final boat = boatById(state.boatId);
    final r =
        ref.read(engineProvider).confirm(h.id, paymentOk: paymentOk, total: totalFor(boat), currency: boat.currency);
    state = state.copyWith(clearHold: true);
    if (r is ConfirmOk) {
      ref.read(bookingsProvider.notifier).add(r.booking);
      state = state.copyWith(lastBooking: r.booking);
      return r.booking;
    }
    return null;
  }

  void _releaseHold() {
    final h = state.hold;
    if (h != null) ref.read(engineProvider).release(h.id);
  }

  void abandon() {
    _releaseHold();
    state = state.copyWith(clearHold: true);
  }
}

final checkoutProvider = NotifierProvider<CheckoutController, CheckoutState>(CheckoutController.new);
