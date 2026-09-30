import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../nav.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = ref.watch(searchProvider);
    final hits = ref.watch(searchResultsProvider);
    final dest = destinationById(q.destinationId);
    final notifier = ref.read(searchProvider.notifier);
    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.fromLTRB(20, 10, 20, 24), children: [
        Row(children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration:
                  BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99), boxShadow: kCardShadow),
              child: Row(children: [
                const Icon(Icons.search_rounded, size: 20, color: AppColors.graphite),
                const SizedBox(width: 10),
                Expanded(
                    child: Text('${dest.name} - ${dayLabel(q.date)} - ${q.guests} guests',
                        overflow: TextOverflow.ellipsis, style: T.label(w: FontWeight.w600))),
                const Icon(Icons.edit_outlined, size: 18, color: AppColors.text3),
              ]),
            ),
          ),
          const SizedBox(width: 10),
          RoundIconButton(Icons.tune_rounded, onTap: () {}),
        ]),
        const SizedBox(height: 14),
        SizedBox(
          height: 40,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final d in kDestinations)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChipPill(d.name,
                    selected: d.id == q.destinationId, onTap: () => notifier.state = q.copyWith(destinationId: d.id)),
              ),
          ]),
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.text2),
              const SizedBox(width: 10),
              Expanded(child: Text(longDay(q.date), style: T.label(w: FontWeight.w600))),
              _iconBtn(Icons.chevron_left_rounded,
                  () => notifier.state = q.copyWith(date: q.date.subtract(const Duration(days: 1)))),
              _iconBtn(Icons.chevron_right_rounded,
                  () => notifier.state = q.copyWith(date: q.date.add(const Duration(days: 1)))),
            ]),
            const Divider(color: AppColors.hairline, height: 14),
            Row(children: [
              const Icon(Icons.group_outlined, size: 18, color: AppColors.text2),
              const SizedBox(width: 10),
              Expanded(child: Text('Guests', style: T.label(w: FontWeight.w600))),
              Stepper2(value: q.guests, min: 1, onChanged: (v) => notifier.state = q.copyWith(guests: v)),
            ]),
            const Divider(color: AppColors.hairline, height: 14),
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Only show boats with space', style: T.label(w: FontWeight.w600)),
                  Text('Instant confirmation available', style: T.caption(size: 12)),
                ]),
              ),
              Switch(value: q.onlyAvailable, onChanged: (v) => notifier.state = q.copyWith(onlyAvailable: v)),
            ]),
          ]),
        ),
        const SizedBox(height: 18),
        if (hits.isEmpty)
          _Empty(q: q)
        else ...[
          Text('${hits.length} ${hits.length == 1 ? 'boat' : 'boats'} with space', style: T.title(size: 22)),
          const SizedBox(height: 6),
          const Align(alignment: Alignment.centerLeft, child: LivePill()),
          const SizedBox(height: 14),
          for (final h in hits) ...[
            _ResultCard(hit: h, guests: q.guests),
            const SizedBox(height: 16),
          ],
        ],
      ]),
    );
  }

  Widget _iconBtn(IconData i, VoidCallback f) =>
      IconButton(onPressed: f, icon: Icon(i, color: AppColors.graphite), visualDensity: VisualDensity.compact);
}

class _ResultCard extends ConsumerWidget {
  const _ResultCard({required this.hit, required this.guests});
  final SearchHit hit;
  final int guests;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = hit.boat;
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () {
        ref.read(checkoutProvider.notifier).start(b.id, ref.read(searchProvider).date);
        Nav.boat(b.id);
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 160,
          child: Stack(children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
                child: Image.asset(b.image, fit: BoxFit.cover),
              ),
            ),
            Positioned(left: 12, top: 12, child: LivePill(source: b.source == SyncSource.manual ? null : b.source)),
            const Positioned(right: 12, top: 12, child: Icon(Icons.favorite_border_rounded, color: Colors.white)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(b.name, style: T.display(size: 20))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(6)),
                child: Text(b.kind.label, style: T.caption(size: 11, color: AppColors.text2)),
              ),
              const Spacer(),
              const Icon(Icons.star_rounded, size: 16, color: AppColors.brass),
              Text(' ${b.rating}', style: T.label(size: 13, w: FontWeight.w600)),
            ]),
            Text('by ${b.operator}', style: T.caption()),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text('Departs', style: T.caption(size: 12)),
              for (final (d, _) in hit.departures)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColors.hairline), borderRadius: BorderRadius.circular(8)),
                  child: Text(d.time, style: T.numeral(size: 13, w: FontWeight.w600)),
                ),
              SeatsChip(hit.bestLeft, lastThreshold: guests),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Starting from', style: T.caption(size: 12)),
                Text.rich(TextSpan(children: [
                  TextSpan(text: money(b.currency, b.pricePerGuest), style: T.numeral(size: 20)),
                  TextSpan(text: ' / guest', style: T.caption(size: 12)),
                ])),
              ]),
              const Spacer(),
              SizedBox(
                  width: 112,
                  height: 42,
                  child: PillButton('Reserve', onTap: () {
                    ref.read(checkoutProvider.notifier).start(b.id, ref.read(searchProvider).date);
                    Nav.boat(b.id);
                  })),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _Empty extends ConsumerWidget {
  const _Empty({required this.q});
  final SearchQuery q;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.read(engineProvider);
    final nearby = [1, 2]
        .map((i) => q.date.add(Duration(days: i)))
        .map((d) => (d, runSearch(engine, q.copyWith(date: d, onlyAvailable: true)).length))
        .toList();
    final dest = destinationById(q.destinationId);
    return Column(children: [
      Photo(img('illustration-empty-dock'), height: 170),
      const SizedBox(height: 20),
      Text('Fully booked for this date', textAlign: TextAlign.center, style: T.display(size: 28)),
      const SizedBox(height: 8),
      Text('Every boat in ${dest.name} is at capacity for ${q.guests} guests on ${dayLabel(q.date)}.',
          textAlign: TextAlign.center, style: T.body()),
      const SizedBox(height: 20),
      const SectionHeader('Nearby dates with space'),
      Row(children: [
        for (final (d, n) in nearby) ...[
          Expanded(
            child: AppCard(
              onTap: () => ref.read(searchProvider.notifier).state = q.copyWith(date: d),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(dayLabel(d).substring(0, 6), style: T.title(size: 18))),
                  Container(
                      width: 8,
                      height: 8,
                      decoration:
                          BoxDecoration(color: n > 0 ? AppColors.success : AppColors.text3, shape: BoxShape.circle)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Text('Availability', style: T.caption(size: 12)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.brassTint, borderRadius: BorderRadius.circular(99)),
                    child: Text('$n boats', style: T.label(size: 12, w: FontWeight.w600)),
                  ),
                ]),
              ]),
            ),
          ),
          if (d != nearby.last.$1) const SizedBox(width: 12),
        ],
      ]),
      const SizedBox(height: 20),
      PillButton('Try nearby dates',
          icon: Icons.arrow_forward_rounded,
          onTap: () => ref.read(searchProvider.notifier).state =
              q.copyWith(date: nearby.firstWhere((x) => x.$2 > 0, orElse: () => nearby.first).$1)),
      const SizedBox(height: 10),
      PillButton('Notify me if a seat opens',
          kind: PillKind.secondary, icon: Icons.notifications_none_rounded, trailing: false, onTap: () {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('We will alert you the moment a seat opens.')));
      }),
    ]);
  }
}
