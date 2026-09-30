import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../nav.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

Widget statusTag(BookingStatus s) => switch (s) {
      BookingStatus.confirmed => const Tag('Confirmed'),
      BookingStatus.weatherWatch => const Tag('Weather watch',
          icon: Icons.warning_amber_rounded, color: AppColors.warning, bg: AppColors.warningTint),
      BookingStatus.cancelled => const Tag('Cancelled', color: AppColors.text3, bg: AppColors.surfaceAlt),
      BookingStatus.weatherCancelled => const Tag('Weather cancelled', color: AppColors.danger, bg: Color(0xFFFDE8E8)),
    };

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});
  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  bool _past = false;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(bookingsProvider);
    final engine = ref.read(engineProvider);
    bool isPast(Booking b) => b.status == BookingStatus.cancelled || b.status == BookingStatus.weatherCancelled;
    final list = all.where((b) => isPast(b) == _past).toList()
      ..sort((a, b) => engine.departure(a.departureId)!.date.compareTo(engine.departure(b.departureId)!.date));
    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.fromLTRB(20, 10, 20, 24), children: [
        Row(children: [
          const Icon(Icons.sailing_outlined, color: AppColors.graphite),
          const SizedBox(width: 8),
          Expanded(child: Text('My trips', style: T.display(size: 24))),
          RoundIconButton(Icons.tune_rounded, onTap: () {}),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(99)),
          child: Row(children: [
            for (final (i, l) in ['Upcoming', 'Past'].indexed)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _past = i == 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: (i == 1) == _past ? AppColors.graphite : Colors.transparent,
                        borderRadius: BorderRadius.circular(99)),
                    child: Text(l,
                        style: T.label(color: (i == 1) == _past ? Colors.white : AppColors.text2, w: FontWeight.w600)),
                  ),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 18),
        if (list.isEmpty)
          const _EmptyTrips()
        else ...[
          _HeroTrip(booking: list.first),
          if (list.length > 1) ...[
            const SizedBox(height: 22),
            Row(children: [
              Expanded(child: Text(_past ? 'Earlier' : 'Later charters', style: T.title(size: 18))),
              Text('${list.length - 1} more', style: T.caption(size: 12)),
            ]),
            const SizedBox(height: 10),
            for (final b in list.skip(1)) ...[_SmallTrip(booking: b), const SizedBox(height: 12)],
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.brassTint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.brass.withValues(alpha: 0.4))),
            child: Row(children: [
              const Icon(Icons.shield_outlined, color: AppColors.brassText),
              const SizedBox(width: 10),
              Expanded(
                  child: Text('All bookings include 24/7 harbourmaster concierge and marine safety assurance.',
                      style: T.caption(color: AppColors.text2, size: 12.5))),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _HeroTrip extends ConsumerWidget {
  const _HeroTrip({required this.booking});
  final Booking booking;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dep = ref.read(engineProvider).departure(booking.departureId)!;
    final b = boatById(booking.boatId);
    final inDays = dep.date.difference(kToday).inDays;
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Nav.bookingDetail(booking.id),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 150,
          child: Stack(children: [
            Positioned.fill(child: Photo(b.image, radius: 14, overlay: true)),
            Positioned(left: 10, top: 10, child: statusTag(booking.status)),
            if (inDays > 0)
              Positioned(
                right: 10,
                top: 10,
                child:
                    Tag('in $inDays days', icon: Icons.schedule_rounded, color: AppColors.graphite, bg: Colors.white),
              ),
            Positioned(
              left: 14,
              bottom: 12,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${b.kind.label.toUpperCase()} CHARTER', style: T.overline(color: Colors.white70)),
                Text(b.name.split(' - ').first, style: T.display(size: 22, color: Colors.white)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        _iconRow(Icons.calendar_today_outlined, '${dayLabel(dep.date)} - ${dep.time} - ${booking.guests} guests'),
        _iconRow(Icons.place_outlined, b.location),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.brassTint,
                child: Text('LR',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.brassText))),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('SKIPPER ASSIGNED', style: T.overline()),
                Text('Capt. Liam Reeves', style: T.label(w: FontWeight.w700)),
              ]),
            ),
            const Icon(Icons.chat_bubble_outline_rounded, size: 20, color: AppColors.graphite),
          ]),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('BOOKING REFERENCE', style: T.overline()),
                Text(booking.id, style: T.numeral(size: 15, w: FontWeight.w700)),
              ]),
            ),
            const Icon(Icons.copy_rounded, size: 18, color: AppColors.text2),
          ]),
        ),
        const SizedBox(height: 10),
        PillButton('View booking pass',
            icon: Icons.qr_code_2_rounded, trailing: false, onTap: () => Nav.bookingDetail(booking.id)),
      ]),
    );
  }

  Widget _iconRow(IconData i, String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Icon(i, size: 17, color: AppColors.text2),
          const SizedBox(width: 8),
          Expanded(child: Text(t, style: T.label(size: 14)))
        ]),
      );
}

class _SmallTrip extends ConsumerWidget {
  const _SmallTrip({required this.booking});
  final Booking booking;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dep = ref.read(engineProvider).departure(booking.departureId)!;
    final b = boatById(booking.boatId);
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Nav.bookingDetail(booking.id),
      child: Column(children: [
        Row(children: [
          Photo(b.image, radius: 12, width: 72, height: 64),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(b.name, overflow: TextOverflow.ellipsis, style: T.display(size: 17))),
                statusTag(booking.status)
              ]),
              const SizedBox(height: 2),
              Text(destinationById(b.destinationId).name, style: T.caption(size: 12)),
              Text('${dayLabel(dep.date)} - ${dep.time} - ${booking.guests} guests',
                  style: T.caption(size: 12, color: AppColors.text2)),
            ]),
          ),
        ]),
        const Divider(color: AppColors.hairline, height: 18),
        Row(children: [
          Text('ID: ${booking.id}', style: T.numeral(size: 12, w: FontWeight.w600, color: AppColors.text2)),
          const Spacer(),
          Text(booking.status == BookingStatus.weatherWatch ? 'Check forecast' : 'View details',
              style: T.label(size: 13, color: AppColors.brassText, w: FontWeight.w600)),
          const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.brassText),
        ]),
      ]),
    );
  }
}

class _EmptyTrips extends ConsumerWidget {
  const _EmptyTrips();
  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(children: [
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration:
              BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: kCardShadow),
          child: Photo(img('illustration-empty-trips'), radius: 18, height: 220, width: 220),
        ),
        const SizedBox(height: 26),
        Text('No trips booked yet', style: T.display(size: 28)),
        const SizedBox(height: 8),
        Text('Boats with live availability are waiting in ${kDestinations.length} destinations.',
            textAlign: TextAlign.center, style: T.body()),
        const SizedBox(height: 22),
        PillButton('Explore destinations',
            icon: Icons.explore_outlined, onTap: () => ref.read(tabProvider.notifier).state = 0),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: AppColors.brassTint, borderRadius: BorderRadius.circular(99)),
          child: Text('Need help? Chat with our concierge', style: T.label(size: 12.5, color: AppColors.brassText)),
        ),
      ]);
}

class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(bookingsProvider);
    final engine = ref.read(engineProvider);
    final booking = ref.read(bookingsProvider).firstWhere((b) => b.id == bookingId);
    final dep = engine.departure(booking.departureId)!;
    final b = boatById(booking.boatId);
    final cancelled = booking.status == BookingStatus.cancelled || booking.status == BookingStatus.weatherCancelled;
    final freeUntil = dep.date.subtract(const Duration(days: 1));
    final steps = [
      ('Booked', dayLabel(booking.createdAt), 'Reserved via Boatingo mobile', true),
      ('Paid ${money(booking.currency, booking.total)}', 'Visa 4242', 'Receipt emailed + SMS sent', true),
      ('Reminder', dayLabel(freeUntil), 'Check-in instructions and weather briefing', false),
      ('Departure', '${dayLabel(dep.date)} - ${dep.time}', '${dep.label} charter - ${booking.guests} guests', false),
    ];
    return Scaffold(
      body: ListView(padding: EdgeInsets.zero, children: [
        SizedBox(
          height: 300,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(b.image, fit: BoxFit.cover),
            const DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x55000000), Color(0x00000000), Color(0xCC2B2A28)],
                        stops: [0, 0.35, 1]))),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const RoundIconButton(Icons.arrow_back_rounded),
                    Expanded(
                        child: Text('Booking summary',
                            textAlign: TextAlign.center, style: T.label(color: Colors.white, w: FontWeight.w600))),
                    RoundIconButton(Icons.favorite_rounded, onTap: () {}),
                  ]),
                  const Spacer(),
                  LivePill(source: b.source == SyncSource.manual ? null : b.source),
                  const SizedBox(height: 8),
                  Text(b.name, style: T.display(size: 26, color: Colors.white)),
                  Text(b.location, style: T.caption(color: Colors.white70)),
                ]),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AppCard(
              child: Column(children: [
                Row(children: [
                  Text('Ref ', style: T.caption()),
                  Expanded(
                      child: Text(booking.id,
                          overflow: TextOverflow.ellipsis, style: T.numeral(size: 14, w: FontWeight.w700))),
                  const SizedBox(width: 6),
                  statusTag(booking.status),
                ]),
                const Divider(color: AppColors.hairline, height: 22),
                Row(children: [
                  Expanded(
                      child: Text('${dep.label} charter - ${booking.guests} guests',
                          style: T.label(color: AppColors.text2))),
                  Text(cancelled ? 'Refunded' : 'Paid ${money(booking.currency, booking.total)}',
                      style: T.numeral(size: 15, w: FontWeight.w700)),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text('Itinerary', style: T.title(size: 18))),
                  const Tag('4 steps', color: AppColors.brassText, bg: AppColors.brassTint)
                ]),
                const SizedBox(height: 12),
                for (final (i, s) in steps.indexed)
                  IntrinsicHeight(
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Column(children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: s.$4
                                ? AppColors.graphite
                                : i == 3
                                    ? AppColors.graphite
                                    : Colors.white,
                            border: Border.all(color: s.$4 || i == 3 ? AppColors.graphite : AppColors.brass, width: 2),
                          ),
                          child: Icon(
                              s.$4
                                  ? Icons.check_rounded
                                  : i == 3
                                      ? Icons.sailing_rounded
                                      : Icons.circle,
                              size: s.$4 || i == 3 ? 13 : 8,
                              color: s.$4 || i == 3 ? Colors.white : AppColors.brass),
                        ),
                        if (i < steps.length - 1) Expanded(child: Container(width: 2, color: AppColors.hairline)),
                      ]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: i == 3
                              ? Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(s.$1, style: T.label(w: FontWeight.w700)),
                                    Text(s.$2, style: T.title(size: 17)),
                                    Text(s.$3, style: T.caption(size: 12.5)),
                                  ]),
                                )
                              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text: s.$1,
                                        style: T.label(
                                            w: FontWeight.w700, color: i == 2 ? AppColors.brassText : AppColors.text)),
                                    TextSpan(text: '   ${s.$2}', style: T.caption(size: 12)),
                                  ])),
                                  Text(s.$3, style: T.caption(size: 12.5)),
                                ]),
                        ),
                      ),
                    ]),
                  ),
              ]),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('YOUR CAPTAIN', style: T.overline()),
                  const Spacer(),
                  const Icon(Icons.star_rounded, size: 16, color: AppColors.brass),
                  Text(' 5.0', style: T.label(w: FontWeight.w700)),
                  Text(' (84 charters)', style: T.caption(size: 12)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  ClipOval(
                      child:
                          Image.asset(img('portrait-captain-liam-reeves'), width: 52, height: 52, fit: BoxFit.cover)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Captain Liam Reeves', style: T.title(size: 17)),
                      Text('Master Mariner 200GT - 12 yrs exp', style: T.caption(size: 12)),
                    ]),
                  ),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text('Meeting point', style: T.title(size: 18))),
                  Text('Pier C', style: T.label(size: 13, color: AppColors.brassText))
                ]),
                const SizedBox(height: 10),
                Photo(img('map-abell-point-marina'), radius: 14, height: 140),
                const SizedBox(height: 10),
                Text('Abell Point Marina, Pier C - Airlie Beach QLD', style: T.label(w: FontWeight.w600)),
                Text('Meet at the harbour master office 20 min before boarding', style: T.caption(size: 12.5)),
              ]),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.text2),
                const SizedBox(width: 10),
                Expanded(
                    child: Text('Free cancellation until ${dayLabel(freeUntil)} (24h before departure).',
                        style: T.caption(color: AppColors.text2))),
              ]),
            ),
            const SizedBox(height: 18),
            if (!cancelled) ...[
              PillButton('Change date or time', kind: PillKind.secondary, onTap: () {}),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: () => Nav.cancelBooking(booking.id),
                  child: Text('Cancel booking', style: T.label(color: AppColors.danger, w: FontWeight.w600)),
                ),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}

class CancelBookingScreen extends ConsumerStatefulWidget {
  const CancelBookingScreen({super.key, required this.bookingId});
  final String bookingId;
  @override
  ConsumerState<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends ConsumerState<CancelBookingScreen> {
  String _reason = 'Plans changed';

  @override
  Widget build(BuildContext context) {
    ref.watch(liveTickProvider);
    final engine = ref.read(engineProvider);
    final booking = ref.read(bookingsProvider).firstWhere((b) => b.id == widget.bookingId);
    final dep = engine.departure(booking.departureId)!;
    final b = boatById(booking.boatId);
    final left = engine.seatsLeft(dep.id);

    void cancel() {
      ref.read(bookingsProvider.notifier).cancel(booking.id);
      final after = engine.seatsLeft(dep.id);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Cancelled. ${booking.guests} seats back on sale - ${dep.time} now has $after left.')));
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
          Row(children: [
            const RoundIconButton(Icons.close_rounded),
            Expanded(child: Text('Boatingo', textAlign: TextAlign.center, style: T.display(size: 19))),
            Text('Help', style: T.label(color: AppColors.text2)),
          ]),
          const SizedBox(height: 18),
          Text('Cancel this booking?', style: T.display(size: 30)),
          const SizedBox(height: 6),
          Text('Review the refund and confirm cancellation for your upcoming charter.', style: T.body(size: 15)),
          const SizedBox(height: 18),
          AppCard(
            child: Row(children: [
              Photo(b.image, radius: 12, width: 70, height: 62),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(b.name.split(' - ').first, style: T.display(size: 18))),
                    Text(booking.id, style: T.numeral(size: 11, w: FontWeight.w600, color: AppColors.text2)),
                  ]),
                  Text('${dayLabel(dep.date)} - ${dep.time} - ${booking.guests} guests', style: T.caption(size: 12)),
                  Text(b.location, style: T.caption(size: 12)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('ELIGIBLE FOR FULL REFUND', style: T.overline(color: AppColors.text))),
                const Tag('100% guaranteed', color: AppColors.brassText, bg: AppColors.brassTint),
              ]),
              const SizedBox(height: 14),
              Text('REFUND', style: T.overline()),
              Text(money(booking.currency, booking.total), style: T.numeral(size: 36)),
              Text('to Visa ending 4242 within 3-5 business days', style: T.caption(size: 12.5)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  _line('Charter', money(booking.currency, booking.total - 100)),
                  _line('Levy + marine park fee', money(booking.currency, 100)),
                  _line('Cancellation fee', money(booking.currency, 0), accent: true),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Text.rich(TextSpan(children: [
            TextSpan(text: 'Reason for cancellation ', style: T.label(w: FontWeight.w600)),
            TextSpan(text: '(optional)', style: T.caption(size: 12)),
          ])),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final r in ['Plans changed', 'Weather', 'Found another boat', 'Other'])
              ChoiceChipPill(r, selected: r == _reason, onTap: () => setState(() => _reason = r)),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.successTint, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const PulseDot(),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                      'Your ${booking.guests} seats go back on sale instantly ($left left now -> ${left + booking.guests}).',
                      style: T.label(size: 13, color: AppColors.success, w: FontWeight.w600))),
            ]),
          ),
          const SizedBox(height: 18),
          PillButton('Cancel booking', kind: PillKind.danger, onTap: cancel),
          const SizedBox(height: 10),
          PillButton('Keep booking', kind: PillKind.secondary, onTap: () => Navigator.of(context).pop()),
        ]),
      ),
    );
  }

  Widget _line(String k, String v, {bool accent = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Expanded(child: Text(k, style: T.caption(color: AppColors.text2))),
          Text(v,
              style: T.numeral(size: 13.5, w: FontWeight.w600, color: accent ? AppColors.brassText : AppColors.text)),
        ]),
      );
}
