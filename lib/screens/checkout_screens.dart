import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../nav.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(liveTickProvider);
    final c = ref.watch(checkoutProvider);
    final n = ref.read(checkoutProvider.notifier);
    final engine = ref.read(engineProvider);
    final b = boatById(c.boatId);
    final dep = engine.departure(c.departureId!)!;
    final hold = c.hold;
    final remaining = hold == null ? Duration.zero : hold.expiresAt.difference(ref.read(clockProvider)());
    final expired = hold == null || remaining.isNegative || engine.held(dep.id) == 0;
    final secs = max(0, remaining.inSeconds);
    final mmss = '${(secs ~/ 60).toString().padLeft(2, '0')}:${(secs % 60).toString().padLeft(2, '0')}';
    final subtotal = b.pricePerGuest * c.guests;

    void pay({bool ok = true}) {
      final booking = n.pay(paymentOk: ok);
      if (booking != null) {
        Nav.confirmed();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Payment declined. Your seats were released back to sale.')));
        Nav.pop();
      }
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) n.abandon();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          leading: const Padding(padding: EdgeInsets.only(left: 8), child: RoundIconButton(Icons.arrow_back_rounded)),
          title: Text('Checkout', style: T.title(size: 18)),
          actions: const [
            Padding(
                padding: EdgeInsets.only(right: 16), child: Icon(Icons.help_outline_rounded, color: AppColors.graphite))
          ],
        ),
        body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Column(children: [
              const LivePill(),
              const SizedBox(height: 16),
              SizedBox(
                width: 150,
                height: 150,
                child: CustomPaint(
                  painter: _RingPainter(expired ? 0 : secs / 600),
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(expired ? '00:00' : mmss, style: T.numeral(size: 34)),
                      Text('REMAINING', style: T.overline()),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text.rich(TextSpan(children: [
                TextSpan(
                    text: expired ? 'Hold expired, seats released' : 'Seats held for you',
                    style: T.label(w: FontWeight.w600)),
                if (!expired) TextSpan(text: '  -  ${c.guests} reserved', style: T.label(color: AppColors.brassText)),
              ])),
            ]),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Photo(b.image, radius: 12, width: 78, height: 70),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(b.name.split(' - ').first, style: T.display(size: 19))),
                      Tag('${c.guests} seats held',
                          color: AppColors.brassText, bg: AppColors.brassTint, icon: Icons.event_seat_outlined),
                    ]),
                    const SizedBox(height: 2),
                    Text('${destinationById(b.destinationId).name} - ${dayLabel(dep.date)}', style: T.caption()),
                    Text('${dep.time} ${dep.label} - ${c.guests} guests', style: T.caption()),
                  ]),
                ),
              ]),
              const Divider(color: AppColors.hairline, height: 28),
              _line('${dep.label} charter (${c.guests} x ${money(b.currency, b.pricePerGuest)})',
                  money(b.currency, subtotal)),
              const SizedBox(height: 6),
              _line('Marine park + wharfage levy', money(b.currency, 100)),
              const Divider(color: AppColors.hairline, height: 24),
              Row(children: [
                Text('Total due', style: T.title(size: 17)),
                const Spacer(),
                Text(money(b.currency, subtotal + 100), style: T.numeral(size: 24)),
              ]),
            ]),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Text('Lead guest', style: T.title(size: 17)),
            const Spacer(),
            Text('Primary contact', style: T.caption(size: 12))
          ]),
          const SizedBox(height: 10),
          _input('Full legal name', kGuestName, Icons.check_circle_rounded),
          const SizedBox(height: 10),
          _input('Mobile (SMS confirmation)', '+61 412 555 019', null),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 46,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.graphite, borderRadius: BorderRadius.circular(6)),
                child: Text('VISA', style: T.label(size: 12, color: Colors.white, w: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('Visa ending 4242', style: T.label(w: FontWeight.w600))),
              Text('Change', style: T.label(size: 13, color: AppColors.brassText)),
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.schedule_rounded, size: 18, color: AppColors.text2),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('If payment fails or the timer ends, your seats are released to other guests.',
                      style: T.caption(color: AppColors.text2))),
            ]),
          ),
          const SizedBox(height: 18),
          PillButton(expired ? 'Hold expired' : 'Pay ${money(b.currency, subtotal + 100)}',
              icon: Icons.lock_outline_rounded, onTap: expired ? null : () => pay()),
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed: expired ? null : () => pay(ok: false),
              child: Text('Simulate declined card', style: T.caption(size: 12, color: AppColors.text3)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _line(String k, String v) => Row(children: [
        Expanded(child: Text(k, style: T.caption(color: AppColors.text2))),
        Text(v, style: T.numeral(size: 14, w: FontWeight.w600)),
      ]);

  Widget _input(String label, String value, IconData? icon) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: T.caption(size: 12)),
        const SizedBox(height: 5),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(color: AppColors.hairline)),
          child: Row(children: [
            Expanded(child: Text(value, style: T.body(color: AppColors.text))),
            if (icon != null) Icon(icon, color: AppColors.success, size: 20),
          ]),
        ),
      ]);
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 8;
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = AppColors.brassTint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9);
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = AppColors.brass
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class LastSeatTakenScreen extends ConsumerWidget {
  const LastSeatTakenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(liveTickProvider);
    final c = ref.watch(checkoutProvider);
    final n = ref.read(checkoutProvider.notifier);
    final engine = ref.read(engineProvider);
    final lost = engine.departure(c.lostDepartureId ?? c.departureId!)!;
    final alts = n.alternatives();

    void take(Departure d) {
      n.switchTo(d);
      if (n.holdSeats() == HoldOutcome.held) {
        Navigator.of(context).pop();
        Nav.checkout();
      }
    }

    return SheetScaffold(
      backdrop: boatById(c.boatId).image,
      top: 150,
      child: ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 24), children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(color: AppColors.warningTint, shape: BoxShape.circle),
            child: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 32),
          ),
        ),
        const SizedBox(height: 14),
        Text('No seats available', textAlign: TextAlign.center, style: T.display(size: 28)),
        const SizedBox(height: 8),
        Text('Someone just booked the last seats on the ${lost.time} ${lost.label} departure. You were not charged.',
            textAlign: TextAlign.center, style: T.body(size: 15)),
        const SizedBox(height: 8),
        Center(
            child: Text('Booked on Nausys at the same moment - our system let exactly one booking through.',
                textAlign: TextAlign.center, style: T.caption(size: 12))),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: Text('Still available right now', style: T.title(size: 16))),
          const LivePill(),
        ]),
        const SizedBox(height: 10),
        for (final (i, (d, left)) in alts.indexed) ...[
          _AltRow(dep: d, left: left, best: i == 0, onTap: () => take(d)),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),
        if (alts.isNotEmpty)
          PillButton('Book ${alts.first.$1.time} instead',
              icon: Icons.arrow_forward_rounded, onTap: () => take(alts.first.$1)),
        const SizedBox(height: 6),
        Center(
            child: TextButton(
                onPressed: Nav.pop, child: Text('Back to calendar', style: T.label(color: AppColors.text2)))),
      ]),
    );
  }
}

class _AltRow extends StatelessWidget {
  const _AltRow({required this.dep, required this.left, required this.best, required this.onTap});
  final Departure dep;
  final int left;
  final bool best;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final b = boatById(dep.boatId);
    final other = dep.boatId != 'lagoon380';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: best ? AppColors.brass : AppColors.hairline, width: best ? 2 : 1),
        ),
        child: Row(children: [
          if (other) ...[Photo(b.image, radius: 10, width: 48, height: 48), const SizedBox(width: 10)] else
            Icon(best ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: best ? AppColors.graphite : AppColors.text3),
          if (!other) const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                    child: Text(other ? b.name : '${dep.time} ${dep.label}',
                        overflow: TextOverflow.ellipsis, style: T.label(size: 14.5, w: FontWeight.w700))),
                if (best) ...[
                  const SizedBox(width: 6),
                  Text('BEST MATCH', style: T.overline(color: AppColors.brassText))
                ],
              ]),
              Text('${dayLabel(dep.date)}${other ? ' ${dep.time}' : ''} - ${b.location.split(',').first}',
                  style: T.caption(size: 12)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            SeatsChip(left, compact: true),
            const SizedBox(height: 4),
            Text('${money(b.currency, b.pricePerGuest)}/guest', style: T.caption(size: 11.5, color: AppColors.text)),
          ]),
        ]),
      ),
    );
  }
}

class BookingConfirmedScreen extends ConsumerWidget {
  const BookingConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(checkoutProvider).lastBooking!;
    final engine = ref.read(engineProvider);
    final dep = engine.departure(booking.departureId)!;
    final b = boatById(booking.boatId);
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
          Row(children: [
            Expanded(child: Text('Booking confirmed', style: T.title(size: 18))),
            RoundIconButton(Icons.close_rounded, onTap: Nav.backToRoot),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.brassTint, Color(0xFFFFFFFF)]),
              boxShadow: kCardShadow,
            ),
            child: Column(children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                    color: AppColors.graphite,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.brass, width: 3)),
                child: const Icon(Icons.check_rounded, color: AppColors.brass, size: 36),
              ),
              const SizedBox(height: 16),
              Text('You are on board', style: T.display(size: 30)),
              const SizedBox(height: 6),
              Text('Your charter is confirmed with ${b.operator}.',
                  textAlign: TextAlign.center, style: T.body(size: 15)),
              const SizedBox(height: 14),
              const Wrap(spacing: 8, children: [
                Tag('Email sent - olivia.h...', icon: Icons.check_rounded),
                Tag('SMS sent - +61...', icon: Icons.check_rounded),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('BOOKING REFERENCE', style: T.overline()),
                const Spacer(),
                const Tag('Verified booking',
                    icon: Icons.verified_outlined, color: AppColors.brassText, bg: AppColors.brassTint),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(booking.id, style: T.numeral(size: 24)))),
                OutlinedButton.icon(
                  onPressed: () => Clipboard.setData(ClipboardData(text: booking.id)),
                  icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.graphite),
                  label: Text('Copy', style: T.label(size: 13)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.hairline), shape: const StadiumBorder()),
                ),
              ]),
              const SizedBox(height: 4),
              Text('Unique ID issued by the inventory engine', style: T.caption(size: 12)),
            ]),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              SizedBox(
                height: 130,
                child: Stack(fit: StackFit.expand, children: [
                  ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
                      child: Image.asset(b.image, fit: BoxFit.cover)),
                  Positioned(
                      left: 14,
                      bottom: 12,
                      child: Text(b.name.split(' - ').first, style: T.display(size: 22, color: Colors.white))),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _row(Icons.calendar_today_outlined, '${dayLabel(dep.date)} - ${dep.time} ${dep.label}'),
                  _row(Icons.group_outlined,
                      '${booking.guests} guests - ${money(booking.currency, booking.total)} paid'),
                  _row(Icons.place_outlined, 'Abell Point Marina, Pier C'),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          PillButton('View booking', icon: Icons.confirmation_number_outlined, onTap: () {
            ref.read(tabProvider.notifier).state = 2;
            Nav.backToRoot();
            Nav.bookingDetail(booking.id);
          }),
          const SizedBox(height: 10),
          PillButton('Add to calendar',
              kind: PillKind.secondary, icon: Icons.event_available_outlined, trailing: false, onTap: () {}),
        ]),
      ),
    );
  }

  Widget _row(IconData i, String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Icon(i, size: 18, color: AppColors.text2),
          const SizedBox(width: 10),
          Expanded(child: Text(t, style: T.label(size: 14)))
        ]),
      );
}
