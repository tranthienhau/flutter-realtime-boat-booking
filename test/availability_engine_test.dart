import 'dart:math';

import 'package:boatingo/engine/availability_engine.dart';
import 'package:boatingo/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Departure dep(String id, {int capacity = 10, String boat = 'b1'}) => Departure(
      id: id,
      boatId: boat,
      date: DateTime(2026, 10, 18),
      time: '13:30',
      label: 'Sunset',
      durationHours: 3.5,
      capacity: capacity,
    );

void main() {
  late DateTime now;
  AvailabilityEngine engine({Map<String, int> booked = const {}}) => AvailabilityEngine(
        departures: [dep('d1'), dep('d2', boat: 'b2')],
        initialBooked: booked,
        clock: () => now,
        random: Random(7),
      );

  setUp(() => now = DateTime(2026, 10, 1, 9));

  test('RTB-001: last seat cannot be double-booked', () async {
    final e = engine(booked: {'d1': 9});
    // Two browsers submit for the final seat at the same moment.
    final results = await Future.wait([
      Future(() => e.hold('d1', 1, holder: 'browser A')),
      Future(() => e.hold('d1', 1, holder: 'browser B')),
    ]);
    final ok = results.whereType<HoldOk>().toList();
    final rejected = results.whereType<HoldRejected>().toList();
    expect(ok, hasLength(1));
    expect(rejected.single.reason, 'No seats available');
    e.confirm(ok.single.hold.id, paymentOk: true, total: 360, currency: 'A\$');
    expect(e.booked('d1'), 10);
    expect(e.seatsLeft('d1'), 0);
    expect(e.overbookedDepartures, 0);
  });

  test('search shows only departures with enough capacity', () {
    final e = engine(booked: {'d1': 8, 'd2': 2});
    expect(e.seatsLeft('d1') >= 4, isFalse);
    expect(e.seatsLeft('d2') >= 4, isTrue);
  });

  test('availability decreases on confirm, not only on payment', () {
    final e = engine();
    final h = (e.hold('d1', 3, holder: 'olivia') as HoldOk).hold;
    expect(e.seatsLeft('d1'), 7, reason: 'held seats leave sale immediately');
    e.confirm(h.id, paymentOk: true, total: 1080, currency: 'A\$');
    expect(e.seatsLeft('d1'), 7);
    expect(e.booked('d1'), 3);
  });

  test('payment failure keeps seats available', () {
    final e = engine();
    final h = (e.hold('d1', 3, holder: 'olivia') as HoldOk).hold;
    final r = e.confirm(h.id, paymentOk: false, total: 0, currency: 'A\$');
    expect(r, isA<ConfirmFailed>());
    expect(e.seatsLeft('d1'), 10);
  });

  test('hold times out and releases seats', () {
    final e = engine();
    final h = (e.hold('d1', 4, holder: 'olivia', ttl: const Duration(minutes: 10)) as HoldOk).hold;
    expect(e.seatsLeft('d1'), 6);
    now = now.add(const Duration(minutes: 10, seconds: 1));
    expect(e.seatsLeft('d1'), 10);
    expect(e.confirm(h.id, paymentOk: true, total: 1, currency: 'A\$'), isA<ConfirmFailed>());
  });

  test('cancellation releases capacity in real time', () async {
    final e = engine();
    final events = <InventoryEvent>[];
    final sub = e.events.listen(events.add);
    final h = (e.hold('d1', 3, holder: 'olivia') as HoldOk).hold;
    final b = (e.confirm(h.id, paymentOk: true, total: 1080, currency: 'A\$') as ConfirmOk).booking;
    expect(e.cancel(b.id), isTrue);
    expect(e.cancel(b.id), isFalse, reason: 'double cancel is a no-op');
    await Future<void>.delayed(Duration.zero);
    expect(e.seatsLeft('d1'), 10);
    expect(events.map((x) => x.kind), contains(InventoryEventKind.cancelled));
    await sub.cancel();
  });

  test('admin block removes boat from availability immediately', () {
    final e = engine();
    e.setBlocked('b1', true);
    expect(e.seatsLeft('d1'), 0);
    expect(e.hold('d1', 1, holder: 'x'), isA<HoldRejected>());
    e.setBlocked('b1', false);
    expect(e.seatsLeft('d1'), 10);
  });

  test('remote operator bookings compete fairly for the last seats', () {
    final e = engine(booked: {'d1': 7});
    expect(e.applyRemoteBooking('d1', 3, SyncSource.nausys), isA<ConfirmOk>());
    final r = e.hold('d1', 3, holder: 'olivia');
    expect(r, isA<HoldRejected>());
    expect(e.booked('d1'), 10);
  });

  test('booking IDs are unique', () {
    final e = AvailabilityEngine(
      departures: [dep('big', capacity: 100000)],
      clock: () => now,
      random: Random(1),
    );
    final ids = <String>{};
    for (var i = 0; i < 10000; i++) {
      final h = (e.hold('big', 1, holder: 'g$i') as HoldOk).hold;
      ids.add((e.confirm(h.id, paymentOk: true, total: 1, currency: 'A\$') as ConfirmOk).booking.id);
    }
    expect(ids, hasLength(10000));
    expect(ids.first, matches(RegExp(r'^BTG-26-1018-[2-9A-Z]{4}$')));
  });

  test('never overbooks under heavy concurrent load', () async {
    final e = engine();
    final rnd = Random(42);
    var confirmed = 0;
    await Future.wait(List.generate(500, (i) async {
      await Future<void>.delayed(Duration(microseconds: rnd.nextInt(500)));
      final r = e.hold('d1', 1 + rnd.nextInt(3), holder: 'u$i');
      if (r is HoldOk) {
        await Future<void>.delayed(Duration(microseconds: rnd.nextInt(500)));
        final c = e.confirm(r.hold.id, paymentOk: rnd.nextBool(), total: 1, currency: 'A\$');
        if (c is ConfirmOk) {
          confirmed += c.booking.guests;
          if (rnd.nextInt(5) == 0) {
            e.cancel(c.booking.id);
            confirmed -= c.booking.guests;
          }
        }
      }
      expect(e.booked('d1') + e.held('d1'), lessThanOrEqualTo(10));
    }));
    expect(e.booked('d1'), confirmed);
    expect(e.overbookedDepartures, 0);
  });
}
