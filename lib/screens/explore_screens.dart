import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../nav.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Max seats left across a boat's departures on [day].
int bestLeft(WidgetRef ref, String boatId, DateTime day) {
  final e = ref.read(engineProvider);
  return e.departuresFor(boatId, day).fold(0, (m, d) => e.seatsLeft(d.id) > m ? e.seatsLeft(d.id) : m);
}

class ExploreHomeScreen extends ConsumerWidget {
  const ExploreHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(liveTickProvider);
    final prom = boatById('prometheus');
    final promLeft = bestLeft(ref, 'prometheus', kToday);
    final nearby = [boatById('lagoon380'), boatById('blue-horizon')];
    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.fromLTRB(20, 10, 20, 24), children: [
        Row(children: [
          ClipOval(child: Image.asset(img('avatar-olivia-hart'), width: 46, height: 46, fit: BoxFit.cover)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('CLUB MEMBER', style: T.overline(color: AppColors.brassText)),
              const SizedBox(height: 2),
              Text('Good morning, Olivia', style: T.title()),
            ]),
          ),
          Stack(children: [
            RoundIconButton(Icons.notifications_none_rounded, onTap: Nav.notifications),
            Positioned(
                right: 10,
                top: 10,
                child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AppColors.brass, shape: BoxShape.circle))),
          ]),
        ]),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: () => ref.read(tabProvider.notifier).state = 1,
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            decoration:
                BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99), boxShadow: kCardShadow),
            child: Row(children: [
              Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(color: AppColors.surfaceAlt, shape: BoxShape.circle),
                  child: const Icon(Icons.search_rounded, color: AppColors.graphite)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Where to?', style: T.label(w: FontWeight.w600)),
                  Text('Any date - Any guests', style: T.caption()),
                ]),
              ),
              Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(border: Border.all(color: AppColors.hairline), shape: BoxShape.circle),
                  child: const Icon(Icons.tune_rounded, size: 20, color: AppColors.graphite)),
            ]),
          ),
        ),
        const SizedBox(height: 24),
        SectionHeader('Popular destinations', action: 'View all ${kDestinations.length}'),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kDestinations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final d = kDestinations[i];
              return GestureDetector(
                onTap: () => Nav.destination(d.id),
                child: SizedBox(
                  width: 112,
                  child: Stack(children: [
                    Photo(d.image, radius: 18, overlay: true, height: 150, width: 112),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(d.name, style: T.label(size: 14, color: Colors.white, w: FontWeight.w700)),
                        Text('${d.boatCount} boats', style: T.caption(color: Colors.white70, size: 12)),
                      ]),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader('Exclusive charter', action: 'Sydney Harbour'),
        GestureDetector(
          onTap: () => Nav.boat(prom.id),
          child: SizedBox(
            height: 230,
            child: Stack(children: [
              Positioned.fill(child: Photo(prom.image, overlay: true)),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    gradient: LinearGradient(
                        colors: [AppColors.brass.withValues(alpha: 0.18), Colors.transparent],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight),
                  ),
                ),
              ),
              const Positioned(left: 14, top: 14, child: LivePill(source: SyncSource.ankor)),
              Positioned(
                  right: 14, top: 14, child: RoundIconButton(Icons.bookmark_border_rounded, dark: true, onTap: () {})),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(prom.name, style: T.display(size: 26, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('Sydney Harbour - 84ft Luxury Motor Yacht', style: T.caption(color: Colors.white70)),
                  const SizedBox(height: 10),
                  Row(children: [
                    SeatsChip(promLeft, lastThreshold: 2),
                    const Spacer(),
                    Text('from ', style: T.caption(color: Colors.white70)),
                    Text(money(prom.currency, prom.pricePerGuest), style: T.numeral(size: 20, color: Colors.white)),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader('Available today near you', action: 'Filter'),
        for (final b in nearby) ...[
          _NearbyRow(boat: b, left: bestLeft(ref, b.id, kToday)),
          const SizedBox(height: 12),
        ],
      ]),
    );
  }
}

class _NearbyRow extends StatelessWidget {
  const _NearbyRow({required this.boat, required this.left});
  final Boat boat;
  final int left;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(10),
        onTap: () => Nav.boat(boat.id),
        child: Row(children: [
          Photo(boat.image, radius: 14, width: 84, height: 72),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(boat.name, style: T.label(size: 15, w: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(boat.location, style: T.caption(size: 12)),
              const SizedBox(height: 8),
              SeatsChip(left, compact: true),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(money(boat.currency, boat.pricePerGuest), style: T.numeral(size: 16)),
            Text('/ guest', style: T.caption(size: 11)),
          ]),
        ]),
      );
}

class DestinationScreen extends ConsumerStatefulWidget {
  const DestinationScreen({super.key, required this.destinationId});
  final String destinationId;
  @override
  ConsumerState<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends ConsumerState<DestinationScreen> {
  BoatKind? _filter;

  @override
  Widget build(BuildContext context) {
    ref.watch(liveTickProvider);
    final engine = ref.read(engineProvider);
    final d = destinationById(widget.destinationId);
    final boats = kBoats
        .where((b) => b.destinationId == d.id && !engine.isBlocked(b.id) && (_filter == null || b.kind == _filter))
        .toList();
    final availableToday = kBoats.where((b) => b.destinationId == d.id && bestLeft(ref, b.id, kToday) > 0).length;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
          Row(children: [
            const RoundIconButton(Icons.arrow_back_rounded),
            Expanded(child: Text('${d.name}, ${d.country}', textAlign: TextAlign.center, style: T.title(size: 18))),
            RoundIconButton(Icons.tune_rounded, onTap: () {}),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: Stack(children: [
              Positioned.fill(child: Photo(d.image, overlay: true)),
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(99)),
                    child: Text(d.region.toUpperCase(), style: T.overline(color: Colors.white)),
                  ),
                  const SizedBox(height: 8),
                  Text('${d.name}, ${d.country}', style: T.display(size: 28, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('${d.boatCount} boats  -  $availableToday available today',
                      style: T.caption(color: Colors.white70)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final (label, kind) in [
                ('All', null),
                ('Catamaran', BoatKind.catamaran),
                ('Motor yacht', BoatKind.motorYacht),
                ('Phinisi', BoatKind.phinisi),
                ('Fast boat', BoatKind.fastBoat)
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChipPill(label, selected: _filter == kind, onTap: () => setState(() => _filter = kind)),
                ),
            ]),
          ),
          const SizedBox(height: 16),
          for (final b in boats) ...[
            _BoatListCard(boat: b, left: bestLeft(ref, b.id, kToday)),
            const SizedBox(height: 16),
          ],
        ]),
      ),
    );
  }
}

class _BoatListCard extends StatelessWidget {
  const _BoatListCard({required this.boat, required this.left});
  final Boat boat;
  final int left;

  @override
  Widget build(BuildContext context) {
    final sold = left <= 0;
    return Opacity(
      opacity: sold ? 0.55 : 1,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => Nav.boat(boat.id),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 170,
            child: Stack(children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
                  child: Image.asset(boat.image, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                  left: 12, top: 12, child: LivePill(source: boat.source == SyncSource.manual ? null : boat.source)),
              Positioned(right: 12, bottom: 12, child: SeatsChip(left)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(boat.name, style: T.title(size: 18))),
                const Icon(Icons.favorite_border_rounded, color: AppColors.text3),
              ]),
              const SizedBox(height: 2),
              Text('${boat.kind.label} by ${boat.operator}', style: T.caption()),
              const SizedBox(height: 12),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('STARTING RATE', style: T.overline()),
                  const SizedBox(height: 2),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: 'from ${money(boat.currency, boat.pricePerGuest)}', style: T.numeral(size: 17)),
                    TextSpan(text: ' / guest', style: T.caption(size: 12)),
                  ])),
                ]),
                const Spacer(),
                SizedBox(
                  width: 112,
                  height: 42,
                  child: Material(
                    color: sold ? AppColors.disabled : AppColors.graphite,
                    shape: const StadiumBorder(),
                    child: InkWell(
                      customBorder: const StadiumBorder(),
                      onTap: () => Nav.boat(boat.id),
                      child: Center(
                          child: Text(sold ? 'Sold out' : 'Reserve',
                              style: T.label(color: sold ? AppColors.text3 : Colors.white, w: FontWeight.w600))),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
