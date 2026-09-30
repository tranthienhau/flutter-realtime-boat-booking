import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../nav.dart';
import '../state/providers.dart';

class DemoStep {
  const DemoStep(this.name, this.action, {this.dwell = const Duration(milliseconds: 1500), this.inVideo = true});
  final String name;
  final void Function(ProviderContainer c) action;
  final Duration dwell;
  final bool inVideo;
}

/// The guided walkthrough: browse, search, lose the last-seat race, rebook,
/// pay, manage + cancel, then the operator view. Shared by the hands-free
/// demo recording and the integration screenshot test.
List<DemoStep> demoSteps() => [
      DemoStep('01-onboarding', (_) {}, dwell: const Duration(milliseconds: 1600)),
      DemoStep('02-sign-in', (_) => Nav.signIn(), dwell: const Duration(milliseconds: 1000)),
      DemoStep('03-explore', (c) {
        c.read(signedInProvider.notifier).state = true;
        Nav.home();
      }, dwell: const Duration(milliseconds: 1900)),
      DemoStep('04-destination', (_) => Nav.destination('palawan')),
      DemoStep('05-search', (c) {
        Nav.pop();
        c.read(tabProvider.notifier).state = 1;
      }),
      DemoStep('06-search-empty', (c) {
        c.read(searchProvider.notifier).state =
            SearchQuery(destinationId: 'tahiti', date: kTripDay.add(const Duration(days: 1)), guests: 10);
      }, dwell: const Duration(milliseconds: 1300)),
      DemoStep('07-boat-detail', (c) {
        c.read(searchProvider.notifier).state = SearchQuery(destinationId: 'bali', date: kTripDay, guests: 4);
        c.read(tabProvider.notifier).state = 0;
        c.read(checkoutProvider.notifier).start('lagoon380', kTripDay);
        Nav.boat('lagoon380');
      }),
      DemoStep('08-availability', (c) {
        c.read(checkoutProvider.notifier).selectDeparture(depId('lagoon380', kTripDay, '13:30'));
        Nav.availability();
      }, dwell: const Duration(milliseconds: 1800)),
      DemoStep('09-last-seat-taken', (c) {
        c.read(checkoutProvider.notifier).holdSeats();
        Nav.lastSeatTaken();
      }, dwell: const Duration(milliseconds: 2200)),
      DemoStep('10-checkout-hold', (c) {
        final n = c.read(checkoutProvider.notifier);
        Nav.pop();
        n.switchTo(n.alternatives().first.$1);
        n.holdSeats();
        Nav.checkout();
      }, dwell: const Duration(milliseconds: 2200)),
      DemoStep('11-booking-confirmed', (c) {
        c.read(checkoutProvider.notifier).pay();
        Nav.confirmed();
      }, dwell: const Duration(milliseconds: 1800)),
      DemoStep('12-my-trips', (c) {
        c.read(tabProvider.notifier).state = 2;
        Nav.backToRoot();
      }),
      DemoStep('13-booking-detail', (c) => Nav.bookingDetail(c.read(checkoutProvider).lastBooking!.id)),
      DemoStep('14-cancel-booking', (c) => Nav.cancelBooking(c.read(checkoutProvider).lastBooking!.id),
          dwell: const Duration(milliseconds: 1600)),
      DemoStep('15-notifications', (c) {
        Nav.backToRoot();
        c.read(tabProvider.notifier).state = 3;
        Nav.notifications();
      }, dwell: const Duration(milliseconds: 1200)),
      DemoStep('16-operator-console', (c) {
        Nav.pop();
        Nav.operatorConsole();
      }, dwell: const Duration(milliseconds: 2000)),
      DemoStep('17-profile', (_) => Nav.pop(), dwell: const Duration(milliseconds: 1200)),
      DemoStep('18-my-trips-empty', (c) {
        c.read(bookingsProvider.notifier).clear();
        c.read(tabProvider.notifier).state = 2;
      }, inVideo: false),
    ];

class Autopilot {
  Autopilot(this.ref);
  final WidgetRef ref;

  Future<void> run() async {
    final c = ProviderScope.containerOf(navKey.currentContext!);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    for (final s in demoSteps().where((s) => s.inVideo)) {
      s.action(c);
      await Future<void>.delayed(s.dwell);
    }
    debugPrint('AUTOPILOT_DONE');
  }
}
