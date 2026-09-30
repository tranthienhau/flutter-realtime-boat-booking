import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';

final _money = NumberFormat.decimalPattern('en_AU');
String money(String cur, int v) => '$cur${_money.format(v)}';
String dayLabel(DateTime d) => DateFormat('EEE d MMM').format(d);
String longDay(DateTime d) => DateFormat('EEE d MMM yyyy').format(d);

/// Pill button: graphite fill + white label (primary), outline (secondary),
/// red fill (danger). One spec reused on every screen.
class PillButton extends StatelessWidget {
  const PillButton(this.label,
      {super.key, this.onTap, this.icon, this.kind = PillKind.primary, this.trailing = true, this.light = false});
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final PillKind kind;
  final bool trailing;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final (bg, fg, border) = switch (kind) {
      PillKind.primary => light
          ? (Colors.white, AppColors.graphite, Colors.transparent)
          : (
              enabled ? AppColors.graphite : AppColors.disabled,
              enabled ? Colors.white : AppColors.text3,
              Colors.transparent
            ),
      PillKind.secondary => (
          Colors.transparent,
          light ? Colors.white : AppColors.graphite,
          light ? Colors.white : AppColors.graphite
        ),
      PillKind.danger => (AppColors.danger, Colors.white, Colors.transparent),
    };
    return Material(
      color: bg,
      shape: StadiumBorder(side: BorderSide(color: border, width: 1.5)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 54,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null && !trailing) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 8)],
            Text(label, style: T.label(size: 15, color: fg, w: FontWeight.w600)),
            if (icon != null && trailing) ...[const SizedBox(width: 8), Icon(icon, size: 20, color: fg)],
          ]),
        ),
      ),
    );
  }
}

enum PillKind { primary, secondary, danger }

class AppCard extends StatelessWidget {
  const AppCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16),
      this.onTap,
      this.color = AppColors.surface,
      this.border});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color color;
  final Color? border;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: kCardShadow,
          border: border == null ? null : Border.all(color: border!, width: 1.5),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.card),
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      );
}

/// White "Live" pill with a pulsing green dot + "synced Ns ago".
class LivePill extends ConsumerWidget {
  const LivePill({super.key, this.source, this.text});
  final SyncSource? source;
  final String? text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(liveTickProvider);
    final sync = ref.watch(syncProvider);
    final now = ref.read(clockProvider)();
    final s = source ?? SyncSource.nausys;
    final ago = sync.secondsAgo(s, now);
    final caption = text ?? (source == null ? 'synced ${ago}s ago' : 'synced from ${s.label} ${ago}s ago');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99), boxShadow: kCardShadow),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const PulseDot(),
        const SizedBox(width: 6),
        Text('Live', style: T.label(size: 12, w: FontWeight.w700)),
        const SizedBox(width: 6),
        Flexible(child: Text(caption, overflow: TextOverflow.ellipsis, style: T.caption(size: 11.5))),
      ]),
    );
  }
}

class PulseDot extends StatefulWidget {
  const PulseDot({super.key, this.color = AppColors.success});
  final Color color;
  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 12,
        height: 12,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => Stack(alignment: Alignment.center, children: [
            Container(
              width: 6 + 6 * _c.value,
              height: 6 + 6 * _c.value,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: widget.color.withValues(alpha: 0.35 * (1 - _c.value))),
            ),
            Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color)),
          ]),
        ),
      );
}

/// Brass "N seats left" chip; solid brass for last seats; grey for sold out.
class SeatsChip extends StatelessWidget {
  const SeatsChip(this.left, {super.key, this.lastThreshold = 3, this.compact = false});
  final int left;
  final int lastThreshold;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final sold = left <= 0;
    final last = !sold && left <= lastThreshold;
    final text = sold
        ? 'Sold out'
        : last
            ? (left == 1 ? 'Last seat' : 'Last $left seats')
            : '$left seats left';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 3 : 5),
      decoration: BoxDecoration(
        color: sold
            ? AppColors.surfaceAlt
            : last
                ? AppColors.brass
                : AppColors.brassTint,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (!sold) ...[
          Icon(Icons.event_seat_outlined, size: 13, color: last ? AppColors.graphite : AppColors.brassText),
          const SizedBox(width: 4)
        ],
        Text(text, style: T.label(size: 12, color: sold ? AppColors.text3 : AppColors.graphite, w: FontWeight.w600)),
      ]),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.color = AppColors.success, this.bg = AppColors.successTint, this.icon});
  final String text;
  final Color color;
  final Color bg;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4)
          ] else ...[
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          Text(text, style: T.label(size: 12, color: color, w: FontWeight.w600)),
        ]),
      );
}

class ChoiceChipPill extends StatelessWidget {
  const ChoiceChipPill(this.label, {super.key, this.selected = false, this.onTap, this.icon});
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Material(
        color: selected ? AppColors.graphite : AppColors.surfaceAlt,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(label, style: T.label(size: 13, color: selected ? Colors.white : AppColors.graphite)),
              if (icon != null) ...[
                const SizedBox(width: 4),
                Icon(icon, size: 16, color: selected ? Colors.white : AppColors.graphite)
              ],
            ]),
          ),
        ),
      );
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton(this.icon, {super.key, this.onTap, this.dark = false});
  final IconData icon;
  final VoidCallback? onTap;
  final bool dark;
  @override
  Widget build(BuildContext context) => Material(
        color: dark ? Colors.black.withValues(alpha: 0.28) : Colors.white,
        shape: const CircleBorder(),
        elevation: dark ? 0 : 1,
        shadowColor: Colors.black12,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap ?? () => Navigator.of(context).maybePop(),
          child: SizedBox(
              width: 44, height: 44, child: Icon(icon, size: 21, color: dark ? Colors.white : AppColors.graphite)),
        ),
      );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Expanded(child: Text(title.toUpperCase(), style: T.overline(color: AppColors.text2))),
          if (action != null)
            GestureDetector(
                onTap: onAction,
                child: Text(action!, style: T.label(size: 13, color: AppColors.brassText, w: FontWeight.w600))),
        ]),
      );
}

class Photo extends StatelessWidget {
  const Photo(this.asset, {super.key, this.radius = AppRadius.card, this.height, this.width, this.overlay = false});
  final String asset;
  final double radius;
  final double? height;
  final double? width;
  final bool overlay;
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          height: height,
          width: width,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(asset, fit: BoxFit.cover),
            if (overlay)
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0x262B2A28), Color(0xD92B2A28)],
                    stops: [0.3, 0.55, 1],
                  ),
                ),
              ),
          ]),
        ),
      );
}

/// Bottom-sheet look used by modal screens drawn over a dimmed photo.
class SheetScaffold extends StatelessWidget {
  const SheetScaffold({super.key, required this.backdrop, required this.child, this.top = 120});
  final String backdrop;
  final Widget child;
  final double top;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.graphite,
        body: Stack(children: [
          Positioned.fill(child: Opacity(opacity: 0.45, child: Image.asset(backdrop, fit: BoxFit.cover))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.35))),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: top,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(children: [
                const SizedBox(height: 10),
                Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(color: AppColors.hairline, borderRadius: BorderRadius.circular(9))),
                Expanded(child: child),
              ]),
            ),
          ),
        ]),
      );
}

/// Shared bottom tab bar: exactly Explore, Search, Bookings, Profile.
class BoatingoTabBar extends StatelessWidget {
  const BoatingoTabBar({super.key, required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;

  static const tabs = [
    ('Explore', Icons.explore_outlined),
    ('Search', Icons.manage_search_rounded),
    ('Bookings', Icons.confirmation_number_outlined),
    ('Profile', Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.hairline)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(tabs[i].$2, size: 24, color: i == index ? AppColors.graphite : AppColors.text3),
                      const SizedBox(height: 3),
                      Text(tabs[i].$1,
                          style: T.label(
                              size: 11.5,
                              color: i == index ? AppColors.graphite : AppColors.text3,
                              w: i == index ? FontWeight.w700 : FontWeight.w500)),
                      const SizedBox(height: 3),
                      Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: i == index ? AppColors.brass : Colors.transparent)),
                    ]),
                  ),
                ),
            ]),
          ),
        ),
      );
}

class Stepper2 extends StatelessWidget {
  const Stepper2({super.key, required this.value, required this.onChanged, this.min = 0});
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        _btn(Icons.remove, value > min ? () => onChanged(value - 1) : null),
        SizedBox(width: 34, child: Text('$value', textAlign: TextAlign.center, style: T.numeral(size: 17))),
        _btn(Icons.add, () => onChanged(value + 1)),
      ]);
  Widget _btn(IconData i, VoidCallback? f) => Material(
        color: AppColors.surfaceAlt,
        shape: const CircleBorder(),
        child: InkWell(
            customBorder: const CircleBorder(),
            onTap: f,
            child: SizedBox(
                width: 36,
                height: 36,
                child: Icon(i, size: 18, color: f == null ? AppColors.text3 : AppColors.graphite))),
      );
}
