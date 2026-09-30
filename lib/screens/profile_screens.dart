import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../nav.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(bookingsProvider).length + 2;
    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.fromLTRB(20, 10, 20, 24), children: [
        Row(children: [
          const SizedBox(width: 44),
          Expanded(child: Text('Profile', textAlign: TextAlign.center, style: T.title(size: 18))),
          RoundIconButton(Icons.settings_outlined, onTap: () {}),
        ]),
        const SizedBox(height: 16),
        AppCard(
          child: Column(children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.brass, AppColors.graphite])),
                child:
                    ClipOval(child: Image.asset(img('avatar-olivia-hart'), width: 74, height: 74, fit: BoxFit.cover)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(child: Text(kGuestName, overflow: TextOverflow.ellipsis, style: T.display(size: 22))),
                    const SizedBox(width: 8),
                    const Tag('Agent', color: AppColors.brassText, bg: AppColors.brassTint, icon: Icons.anchor_rounded),
                  ]),
                  Text('Member since 2025 - $trips trips', style: T.caption()),
                  const SizedBox(height: 6),
                  const Tag('Gold charter status'),
                ]),
              ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              for (final (v, l) in [('$trips', 'Charters'), ('Gold', 'Charter tier'), ('6', 'Saved yachts')])
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(14)),
                    child: Column(children: [
                      Text(v, style: T.numeral(size: 20, color: v == 'Gold' ? AppColors.brassText : AppColors.text)),
                      Text(l, style: T.caption(size: 11.5)),
                    ]),
                  ),
                ),
            ]),
          ]),
        ),
        const SizedBox(height: 22),
        const SectionHeader('Account + charters'),
        _group([
          _Row(Icons.person_outline_rounded, 'Personal details', sub: 'Passport, verification + contacts'),
          _Row(Icons.credit_card_rounded, 'Payment methods', trailing: 'Visa 4242'),
          _Row(Icons.notifications_none_rounded, 'Notifications', trailing: 'Email + SMS on', onTap: Nav.notifications),
          _Row(Icons.bookmark_border_rounded, 'Saved boats', trailing: '6'),
        ]),
        const SizedBox(height: 22),
        const SectionHeader('Preferences + fleet'),
        _group([
          _Row(Icons.payments_outlined, 'Currency', trailing: 'AUD (A\$)'),
          _Row(Icons.dashboard_customize_outlined, 'Operator console',
              sub: 'Live sync, capacity + fleet blocks', trailing: 'Agent', onTap: Nav.operatorConsole),
          _Row(Icons.help_outline_rounded, 'Help centre'),
          _Row(Icons.logout_rounded, 'Sign out', danger: true),
        ]),
      ]),
    );
  }

  Widget _group(List<Widget> rows) => AppCard(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(children: [
          for (final (i, r) in rows.indexed) ...[
            r,
            if (i < rows.length - 1) const Divider(color: AppColors.hairline, height: 1, indent: 60)
          ],
        ]),
      );
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.title, {this.sub, this.trailing, this.onTap, this.danger = false});
  final IconData icon;
  final String title;
  final String? sub;
  final String? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 20, color: danger ? AppColors.danger : AppColors.graphite),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: T.label(size: 15, w: FontWeight.w600, color: danger ? AppColors.danger : AppColors.text)),
                if (sub != null) Text(sub!, style: T.caption(size: 12)),
              ]),
            ),
            if (trailing != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.brassTint, borderRadius: BorderRadius.circular(99)),
                child: Text(trailing!, style: T.label(size: 12, color: AppColors.brassText, w: FontWeight.w600)),
              ),
            if (!danger) const Icon(Icons.chevron_right_rounded, color: AppColors.text3),
          ]),
        ),
      );
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weather = kNotifications.first;
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
          Row(children: [
            const RoundIconButton(Icons.arrow_back_rounded),
            Expanded(child: Text('Notifications', textAlign: TextAlign.center, style: T.title(size: 18))),
            const SizedBox(width: 44, child: Icon(Icons.done_all_rounded, color: AppColors.graphite)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            const ChoiceChipPill('All', selected: true),
            const SizedBox(width: 8),
            const ChoiceChipPill('Alerts'),
            const SizedBox(width: 8),
            const ChoiceChipPill('Bookings'),
            const Spacer(),
            Tag('${kNotifications.length - 1} unread', color: AppColors.brassText, bg: AppColors.brassTint),
          ]),
          const SizedBox(height: 16),
          AppCard(
            color: AppColors.warningTint,
            border: AppColors.warning.withValues(alpha: 0.35),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Tag('Weather cancellation',
                    icon: Icons.warning_amber_rounded, color: AppColors.warning, bg: Colors.white),
                const Spacer(),
                Text(weather.when, style: T.caption(size: 12)),
              ]),
              const SizedBox(height: 12),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Photo(weather.image!, radius: 12, width: 72, height: 72),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(weather.title, style: T.title(size: 16)),
                    const SizedBox(height: 4),
                    Text(weather.body, style: T.caption(color: AppColors.text2)),
                  ]),
                ),
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.credit_card_rounded, size: 18, color: AppColors.text2),
                  const SizedBox(width: 8),
                  Expanded(child: Text('A\$960 refunded to Visa 4242', style: T.label(size: 13))),
                  const Tag('Settled'),
                ]),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: SizedBox(
                        height: 46, child: PillButton('Rebook', icon: Icons.arrow_forward_rounded, onTap: () {}))),
                const SizedBox(width: 10),
                Expanded(
                    child:
                        SizedBox(height: 46, child: PillButton('View refund', kind: PillKind.secondary, onTap: () {}))),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Text('RECENT ACTIVITY', style: T.overline(color: AppColors.text2))),
            Text('Live sync', style: T.caption(size: 12))
          ]),
          const SizedBox(height: 10),
          for (final n in kNotifications.skip(1)) ...[
            AppCard(
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      color: n.kind == NotificationKind.confirmed ? AppColors.successTint : AppColors.surfaceAlt,
                      shape: BoxShape.circle),
                  child: Icon(
                    switch (n.kind) {
                      NotificationKind.seatOpened => Icons.event_seat_outlined,
                      NotificationKind.reminder => Icons.schedule_rounded,
                      _ => Icons.check_rounded
                    },
                    size: 19,
                    color: n.kind == NotificationKind.confirmed ? AppColors.success : AppColors.graphite,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(n.title, style: T.label(size: 14, w: FontWeight.w700))),
                      Text(n.when, style: T.caption(size: 11.5)),
                    ]),
                    const SizedBox(height: 3),
                    Text(n.body, style: T.caption(size: 12.5, color: AppColors.text2)),
                    if (n.kind == NotificationKind.seatOpened) ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        Text('Limited availability', style: T.label(size: 12, color: AppColors.brassText)),
                        const Spacer(),
                        Text('View boat', style: T.label(size: 12.5, w: FontWeight.w700)),
                        const Icon(Icons.arrow_forward_rounded, size: 15),
                      ]),
                    ],
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 12),
          ],
        ]),
      ),
    );
  }
}

class OperatorConsoleScreen extends ConsumerWidget {
  const OperatorConsoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(liveTickProvider);
    final engine = ref.read(engineProvider);
    final sync = ref.watch(syncProvider);
    final now = ref.read(clockProvider)();
    final fleet = ['lagoon380', 'bali46', 'prometheus', 'blue-horizon'].map(boatById).toList();
    final day = kToday;
    final cap = fleet.fold(0, (s, b) => s + engine.departuresFor(b.id, day).fold(0, (x, d) => x + d.capacity));
    final booked =
        fleet.fold(0, (s, b) => s + engine.departuresFor(b.id, day).fold(0, (x, d) => x + engine.booked(d.id)));
    final pct = cap == 0 ? 0.0 : booked / cap;
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
          Row(children: [
            const RoundIconButton(Icons.arrow_back_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Operator console', style: T.title(size: 19)),
                Text('Dream Yacht Charter', style: T.caption(size: 12)),
              ]),
            ),
            RoundIconButton(Icons.sync_rounded, onTap: () {
              for (final s in SyncSource.values) {
                ref.read(syncProvider.notifier).markSynced(s);
              }
            }),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: Text('FEED CONNECTIONS', style: T.overline(color: AppColors.text2))),
            const Icon(Icons.autorenew_rounded, size: 15, color: AppColors.brassText),
            Text(' Auto-sync on', style: T.label(size: 12, color: AppColors.brassText)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            for (final s in [SyncSource.nausys, SyncSource.ankor]) ...[
              Expanded(child: _SourceCard(source: s, boats: sync.boatsBySource[s]!, ago: sync.secondsAgo(s, now))),
              if (s == SyncSource.nausys) const SizedBox(width: 10),
            ],
          ]),
          const SizedBox(height: 10),
          _SourceCard(
              source: SyncSource.manual,
              boats: sync.boatsBySource[SyncSource.manual]!,
              ago: sync.secondsAgo(SyncSource.manual, now),
              wide: true),
          const SizedBox(height: 16),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text("TODAY'S FLEET CAPACITY", style: T.overline())),
                Tag(pct > 0.7 ? 'High demand' : 'Normal',
                    color: AppColors.brassText, bg: AppColors.brassTint, icon: Icons.trending_up_rounded),
              ]),
              const SizedBox(height: 10),
              Text.rich(TextSpan(children: [
                TextSpan(text: '$booked', style: T.numeral(size: 40)),
                TextSpan(text: ' / $cap', style: T.numeral(size: 24, color: AppColors.text3, w: FontWeight.w600)),
              ])),
              Text('seats booked today (${(pct * 100).round()}% load)', style: T.caption()),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: LinearProgressIndicator(
                    value: pct, minHeight: 9, backgroundColor: AppColors.surfaceAlt, color: AppColors.brass),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _mini(Icons.event_seat_outlined, '${cap - booked} seats', 'Available to sell')),
                Expanded(
                    child: _mini(
                        Icons.verified_outlined, '${engine.overbookedDepartures} overbookings', 'Enforced by engine')),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Text('Fleet live inventory', style: T.title(size: 18))),
            Text('Block = hide instantly', style: T.caption(size: 12)),
          ]),
          const SizedBox(height: 10),
          for (final b in fleet) ...[
            _FleetRow(boat: b),
            const SizedBox(height: 10),
          ],
        ]),
      ),
    );
  }

  Widget _mini(IconData i, String v, String l) => Row(children: [
        Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
            child: Icon(i, size: 18, color: AppColors.graphite)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(v, style: T.label(size: 13.5, w: FontWeight.w700)),
            Text(l, style: T.caption(size: 11)),
          ]),
        ),
      ]);
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.source, required this.boats, required this.ago, this.wide = false});
  final SyncSource source;
  final int boats;
  final int ago;
  final bool wide;
  @override
  Widget build(BuildContext context) {
    final live = source != SyncSource.manual;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        live
            ? const PulseDot()
            : Container(
                width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.text3, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(source.label, style: T.label(size: 15, w: FontWeight.w700)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(6)),
                child: Text('$boats boats', style: T.caption(size: 11)),
              ),
            ]),
            const SizedBox(height: 2),
            Text(live ? 'Connected - synced ${ago}s ago' : 'Operator calendar - updated ${ago ~/ 60} min ago',
                style: T.caption(size: 11.5)),
          ]),
        ),
      ]),
    );
  }
}

class _FleetRow extends ConsumerWidget {
  const _FleetRow({required this.boat});
  final Boat boat;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(liveTickProvider);
    final engine = ref.read(engineProvider);
    final blocked = engine.isBlocked(boat.id);
    final deps = engine.departuresFor(boat.id, kToday);
    final left = deps.fold(0, (s, d) => s + engine.seatsLeft(d.id));
    return AppCard(
      padding: const EdgeInsets.all(10),
      child: Row(children: [
        Photo(boat.image, radius: 12, width: 66, height: 58),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(
                  child: Text(boat.name.split(' - ').first,
                      overflow: TextOverflow.ellipsis, style: T.label(size: 15, w: FontWeight.w700))),
              const SizedBox(width: 6),
              blocked ? const Tag('Blocked', color: AppColors.warning, bg: AppColors.warningTint) : const Tag('Live'),
            ]),
            const SizedBox(height: 2),
            Text('${boat.berths > 0 ? '${boat.berths} berths - ' : ''}${boat.location.split(',').first}',
                style: T.caption(size: 12)),
            Text(blocked ? 'Hidden from all listings' : '$left seats left today - via ${boat.source.label}',
                style: T.caption(size: 12, color: blocked ? AppColors.warning : AppColors.text2, w: FontWeight.w600)),
          ]),
        ),
        Switch(
          value: !blocked,
          onChanged: (on) {
            engine.setBlocked(boat.id, !on);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 2),
              content: Text(on
                  ? '${boat.name.split(' - ').first} is back on sale'
                  : '${boat.name.split(' - ').first} blocked - removed from listings'),
            ));
          },
        ),
      ]),
    );
  }
}
