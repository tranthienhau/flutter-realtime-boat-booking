import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../nav.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Availability bucket for a day, used by the 7-day strip and the calendar.
enum DayAvail { available, limited, full }

DayAvail dayAvail(WidgetRef ref, String boatId, DateTime day, int guests) {
  final e = ref.read(engineProvider);
  final best = e.departuresFor(boatId, day).fold(0, (m, d) => e.seatsLeft(d.id) > m ? e.seatsLeft(d.id) : m);
  if (best < guests || best == 0) return DayAvail.full;
  return best <= 3 ? DayAvail.limited : DayAvail.available;
}

Color availColor(DayAvail a) => switch (a) {
      DayAvail.available => AppColors.success,
      DayAvail.limited => AppColors.brass,
      DayAvail.full => AppColors.text3,
    };

class BoatDetailScreen extends ConsumerWidget {
  const BoatDetailScreen({super.key, required this.boatId});
  final String boatId;

  void _check(WidgetRef ref, [DateTime? day]) {
    final c = ref.read(checkoutProvider);
    final n = ref.read(checkoutProvider.notifier);
    if (c.boatId != boatId || day != null) n.start(boatId, day ?? kTripDay);
    Nav.availability();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(liveTickProvider);
    final b = boatById(boatId);
    final days = List.generate(7, (i) => kToday.add(Duration(days: i)));
    final specs = [
      (Icons.straighten_rounded, 'Length', '${b.lengthM} m'),
      (Icons.bed_outlined, 'Cabins', '${b.cabins} cabins'),
      (Icons.king_bed_outlined, 'Berths', '${b.berths} berths'),
      (Icons.groups_2_outlined, 'Capacity', '${b.capacity} guests'),
      (Icons.event_outlined, 'Year', '${b.year}'),
      (Icons.verified_outlined, 'Crew', b.skipperIncluded ? 'Skipper incl.' : 'Bareboat'),
    ];
    return Scaffold(
      body: Stack(children: [
        ListView(padding: EdgeInsets.zero, children: [
          SizedBox(
            height: 340,
            child: Stack(fit: StackFit.expand, children: [
              Image.asset(b.image, fit: BoxFit.cover),
              const DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x66000000), Color(0x00000000)],
                          stops: [0, 0.35]))),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const RoundIconButton(Icons.arrow_back_rounded),
                      const Spacer(),
                      RoundIconButton(Icons.ios_share_rounded, onTap: () {}),
                      const SizedBox(width: 10),
                      RoundIconButton(Icons.favorite_border_rounded, onTap: () {}),
                    ]),
                    const SizedBox(height: 12),
                    LivePill(source: b.source == SyncSource.manual ? null : b.source),
                    const Spacer(),
                    Row(children: [
                      for (var i = 0; i < 5; i++)
                        Container(
                            margin: const EdgeInsets.only(right: 5),
                            width: i == 0 ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                                color: i == 0 ? Colors.white : Colors.white54, borderRadius: BorderRadius.circular(9))),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(99)),
                        child: Text('1 / 24', style: T.label(size: 12, color: Colors.white)),
                      ),
                    ]),
                  ]),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text('${b.kind.label.toUpperCase()}  -  ${b.operator.toUpperCase()}',
                        style: T.overline(color: AppColors.brassText))),
                const Tag('Charter verified',
                    icon: Icons.verified_outlined, color: AppColors.brassText, bg: AppColors.brassTint),
              ]),
              const SizedBox(height: 8),
              Text(b.name, style: T.display(size: 30)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.place_outlined, size: 16, color: AppColors.text2),
                const SizedBox(width: 4),
                Expanded(child: Text(b.location, style: T.caption(color: AppColors.text2))),
                const Icon(Icons.star_rounded, size: 17, color: AppColors.brass),
                Text(' ${b.rating} ', style: T.label(w: FontWeight.w700)),
                Text('(${b.reviews} reviews)', style: T.caption(size: 12)),
              ]),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(child: Text('Vessel specifications', style: T.title(size: 18))),
                Text('Direct from ${b.source.label}', style: T.caption(size: 12)),
              ]),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.98,
                children: [
                  for (final (icon, k, v) in specs)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: k == 'Crew' ? AppColors.brassTint : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: k == 'Crew' ? AppColors.brass.withValues(alpha: 0.5) : AppColors.hairline),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(icon, size: 20, color: AppColors.text2),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(k, style: T.caption(size: 11.5)),
                              Text(v, style: T.label(size: 13.5, w: FontWeight.w700)),
                            ]),
                          ]),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('Next 7 days', style: T.title(size: 18)),
                    const SizedBox(width: 8),
                    const Tag('Live sync', color: AppColors.brassText, bg: AppColors.brassTint),
                    const Spacer(),
                    Text('Tap to book', style: T.caption(size: 12)),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    for (final d in days)
                      Expanded(child: _DayCell(day: d, avail: dayAvail(ref, b.id, d, 1), onTap: () => _check(ref, d))),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    for (final a in DayAvail.values) ...[
                      Container(
                          width: 8, height: 8, decoration: BoxDecoration(color: availColor(a), shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text(
                          switch (a) {
                            DayAvail.available => 'Available',
                            DayAvail.limited => 'Limited',
                            DayAvail.full => 'Full'
                          },
                          style: T.caption(size: 12)),
                      const SizedBox(width: 14),
                    ],
                  ]),
                ]),
              ),
              const SizedBox(height: 22),
              Text('About this boat', style: T.title(size: 18)),
              const SizedBox(height: 8),
              Text(b.description, style: T.body(size: 15)),
            ]),
          ),
        ]),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            decoration:
                const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.hairline))),
            child: SafeArea(
              top: false,
              child: Row(children: [
                Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('from', style: T.caption(size: 12)),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: money(b.currency, b.pricePerGuest), style: T.numeral(size: 22)),
                    TextSpan(text: ' / guest', style: T.caption(size: 12)),
                  ])),
                ]),
                const SizedBox(width: 16),
                Expanded(child: PillButton('Check availability', onTap: () => _check(ref))),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.avail, required this.onTap});
  final DateTime day;
  final DayAvail avail;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final full = avail == DayAvail.full;
    return GestureDetector(
      onTap: full ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2.5),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: switch (avail) {
            DayAvail.available => AppColors.graphite,
            DayAvail.limited => AppColors.brassTint,
            DayAvail.full => AppColors.surfaceAlt
          },
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Text(DateFormat('EEE').format(day).toUpperCase(),
              style: T.caption(
                  size: 10, color: avail == DayAvail.available ? Colors.white70 : AppColors.text3, w: FontWeight.w700)),
          const SizedBox(height: 3),
          Text('${day.day}',
              style: T
                  .numeral(
                      size: 16,
                      color: avail == DayAvail.available
                          ? Colors.white
                          : full
                              ? AppColors.text3
                              : AppColors.graphite)
                  .copyWith(
                    decoration: full ? TextDecoration.lineThrough : null,
                  )),
          const SizedBox(height: 4),
          Container(width: 5, height: 5, decoration: BoxDecoration(color: availColor(avail), shape: BoxShape.circle)),
        ]),
      ),
    );
  }
}

class AvailabilityScreen extends ConsumerWidget {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(liveTickProvider);
    final c = ref.watch(checkoutProvider);
    final n = ref.read(checkoutProvider.notifier);
    final engine = ref.read(engineProvider);
    final b = boatById(c.boatId);
    final deps = engine.departuresFor(b.id, c.date).toList();
    final selected = c.departureId == null ? null : engine.departure(c.departureId!);
    final selLeft = selected == null ? 0 : engine.seatsLeft(selected.id);
    final canHold = selected != null && selLeft >= c.guests;

    void hold() {
      switch (n.holdSeats()) {
        case HoldOutcome.held:
          Nav.checkout();
        case HoldOutcome.lostRace:
          Nav.lastSeatTaken();
        case HoldOutcome.notEnough:
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Not enough seats left for your party.')));
      }
    }

    return SheetScaffold(
      backdrop: b.image,
      top: 64,
      child: Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 10, 20, 16), children: [
            Row(children: [
              Photo(b.image, radius: 12, width: 46, height: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${destinationById(b.destinationId).name.toUpperCase()} CHARTER', style: T.overline()),
                  Text('Choose a departure', style: T.title()),
                ]),
              ),
              RoundIconButton(Icons.close_rounded, onTap: Nav.pop),
            ]),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const PulseDot(),
                const SizedBox(width: 8),
                Text('Availability updates live', style: T.label(size: 13, w: FontWeight.w600)),
                const Spacer(),
                _SyncedAgo(source: b.source),
              ]),
            ),
            const SizedBox(height: 14),
            _MonthCalendar(boatId: b.id, selected: c.date, guests: c.guests, onPick: n.selectDate),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: Text('Departures for ${dayLabel(c.date)}', style: T.title(size: 17))),
              Text('${deps.length} departures', style: T.caption(size: 12)),
            ]),
            const SizedBox(height: 10),
            for (final d in deps) ...[
              _SlotCard(
                  dep: d,
                  left: engine.seatsLeft(d.id),
                  selected: d.id == c.departureId,
                  guests: c.guests,
                  price: b.pricePerGuest,
                  currency: b.currency,
                  onTap: () => n.selectDeparture(d.id)),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            Text('Guests', style: T.title(size: 17)),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
              child: Column(children: [
                Row(children: [
                  Expanded(child: Text('Adults', style: T.label(w: FontWeight.w600))),
                  Stepper2(value: c.adults, min: 1, onChanged: n.setAdults)
                ]),
                const Divider(color: AppColors.hairline),
                Row(children: [
                  Expanded(child: Text('Children', style: T.label(w: FontWeight.w600))),
                  Stepper2(value: c.children, onChanged: n.setChildren)
                ]),
              ]),
            ),
          ]),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.hairline))),
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                const Icon(Icons.timer_outlined, size: 16, color: AppColors.text2),
                const SizedBox(width: 6),
                Text('Seats held for 10 min while you pay', style: T.caption(size: 12)),
                const Spacer(),
                Text('Total ', style: T.caption(size: 12)),
                Text(money(b.currency, b.pricePerGuest * c.guests), style: T.numeral(size: 15)),
              ]),
              const SizedBox(height: 10),
              PillButton('Hold seats for 10:00', icon: Icons.arrow_forward_rounded, onTap: canHold ? hold : null),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _SyncedAgo extends ConsumerWidget {
  const _SyncedAgo({required this.source});
  final SyncSource source;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(liveTickProvider);
    final s = ref.watch(syncProvider).secondsAgo(source, ref.read(clockProvider)());
    return Text('synced ${source.label} ${s}s ago', style: T.caption(size: 11.5));
  }
}

class _MonthCalendar extends ConsumerWidget {
  const _MonthCalendar({required this.boatId, required this.selected, required this.guests, required this.onPick});
  final String boatId;
  final DateTime selected;
  final int guests;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final first = DateTime(selected.year, selected.month, 1);
    final daysInMonth = DateTime(selected.year, selected.month + 1, 0).day;
    final lead = first.weekday - 1;
    return AppCard(
      child: Column(children: [
        Row(children: [
          Expanded(child: Text(DateFormat('MMMM yyyy').format(first), style: T.title(size: 17))),
          const Icon(Icons.chevron_left_rounded, color: AppColors.text3),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.graphite),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          for (final d in 'MTWTFSS'.split(''))
            Expanded(child: Center(child: Text(d, style: T.caption(size: 11.5, w: FontWeight.w700))))
        ]),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.92,
          children: [
            for (var i = 0; i < lead; i++) const SizedBox(),
            for (var day = 1; day <= daysInMonth; day++) _cell(ref, DateTime(selected.year, selected.month, day)),
          ],
        ),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (final (c, l) in [
            (AppColors.success, 'Available'),
            (AppColors.brass, 'Limited'),
            (AppColors.text3, 'Full / past')
          ]) ...[
            Container(width: 7, height: 7, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(l, style: T.caption(size: 11)),
            const SizedBox(width: 12),
          ],
        ]),
      ]),
    );
  }

  Widget _cell(WidgetRef ref, DateTime d) {
    final past = d.isBefore(kToday);
    final a = past ? DayAvail.full : dayAvail(ref, boatId, d, guests);
    final isSel = d.day == selected.day;
    final disabled = past || a == DayAvail.full;
    return GestureDetector(
      onTap: disabled ? null : () => onPick(d),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: isSel ? AppColors.graphite : Colors.transparent),
          child: Text('${d.day}',
              style: T
                  .numeral(
                      size: 14,
                      w: FontWeight.w600,
                      color: isSel
                          ? Colors.white
                          : disabled
                              ? AppColors.text3
                              : AppColors.text)
                  .copyWith(decoration: disabled && !past ? TextDecoration.lineThrough : null)),
        ),
        const SizedBox(height: 2),
        Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: past ? Colors.transparent : availColor(a))),
      ]),
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard(
      {required this.dep,
      required this.left,
      required this.selected,
      required this.guests,
      required this.price,
      required this.currency,
      required this.onTap});
  final Departure dep;
  final int left;
  final bool selected;
  final int guests;
  final int price;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final full = left <= 0;
    final last = !full && left <= 3;
    return Opacity(
      opacity: full ? 0.5 : 1,
      child: GestureDetector(
        onTap: full ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected && last ? AppColors.brassTint.withValues(alpha: 0.6) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? (last ? AppColors.brass : AppColors.graphite) : AppColors.hairline,
                width: selected ? 2 : 1),
          ),
          child: Row(children: [
            Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: selected ? AppColors.graphite : AppColors.text3),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(spacing: 0, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Text('${dep.time} ${dep.label}', style: T.label(size: 15, w: FontWeight.w700)),
                  const SizedBox(width: 6),
                  Text('${dep.durationHours.toString().replaceAll('.0', '')} h', style: T.caption(size: 12)),
                  if (last) ...[const SizedBox(width: 8), SeatsChip(left, compact: true)],
                ]),
                const SizedBox(height: 4),
                Text(full ? 'Full' : '$left of ${dep.capacity} seats left',
                    style: T.caption(
                        size: 12.5,
                        color: full
                            ? AppColors.text3
                            : last
                                ? AppColors.brassText
                                : AppColors.success,
                        w: FontWeight.w600)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(money(currency, price), style: T.numeral(size: 16)),
              Text('/ guest', style: T.caption(size: 11)),
            ]),
          ]),
        ),
      ),
    );
  }
}
