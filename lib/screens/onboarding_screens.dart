import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../nav.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.graphite,
        body: Stack(fit: StackFit.expand, children: [
          Image.asset(img('hero-onboarding-palawan-catamaran'), fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x55000000), Color(0x00000000), Color(0xCC2B2A28), Color(0xF22B2A28)],
                stops: [0, 0.3, 0.68, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Image.asset('assets/brand/mark.png', width: 30, height: 30, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Boatingo', style: T.display(size: 22, color: Colors.white)),
                  const Spacer(),
                  TextButton(onPressed: Nav.signIn, child: Text('Skip', style: T.label(color: Colors.white))),
                ]),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(99)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const PulseDot(),
                    const SizedBox(width: 6),
                    Text('LIVE PACIFIC CHARTERS', style: T.overline(color: Colors.white)),
                  ]),
                ),
                const SizedBox(height: 16),
                Text('Book the boat.\nSee it live.', style: T.display(size: 40, color: Colors.white)),
                const SizedBox(height: 12),
                Text('Real-time availability from 400+ operators across Asia Pacific.',
                    style: T.body(color: Colors.white.withValues(alpha: 0.86))),
                const SizedBox(height: 22),
                Row(children: [
                  Container(
                      width: 22,
                      height: 5,
                      decoration: BoxDecoration(color: AppColors.brass, borderRadius: BorderRadius.circular(9))),
                  for (var i = 0; i < 2; i++)
                    Container(
                        margin: const EdgeInsets.only(left: 6),
                        width: 6,
                        height: 5,
                        decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(9))),
                ]),
                const SizedBox(height: 26),
                PillButton('Get started', light: true, icon: Icons.arrow_forward_rounded, onTap: Nav.signIn),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: Nav.signIn,
                    child:
                        Text('I already have an account', style: T.label(color: Colors.white.withValues(alpha: 0.86))),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      );
}

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void go() {
      ref.read(signedInProvider.notifier).state = true;
      Nav.home();
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
          Row(children: [
            const RoundIconButton(Icons.arrow_back_rounded),
            const Spacer(),
            Image.asset('assets/brand/mark.png', width: 26, height: 26),
            const SizedBox(width: 6),
            Text('Boatingo', style: T.display(size: 19)),
            const Spacer(),
            Text('Help', style: T.label(color: AppColors.text2)),
          ]),
          const SizedBox(height: 18),
          Stack(children: [
            Photo(img('hero-signin-marina-sunrise'), height: 150),
            const Positioned(left: 12, bottom: 12, child: LivePill(text: 'Charter fleet live')),
          ]),
          const SizedBox(height: 24),
          Text('Welcome aboard', style: T.display()),
          const SizedBox(height: 6),
          Text('Sign in to access your charters, live tracking and bookings.', style: T.body()),
          const SizedBox(height: 22),
          _field('Email', 'olivia.hart@gmail.com'),
          const SizedBox(height: 14),
          _field('Password', '••••••••••', trailing: Icons.visibility_outlined, extra: 'Forgot password?'),
          const SizedBox(height: 22),
          PillButton('Sign in', icon: Icons.arrow_forward_rounded, onTap: go),
          const SizedBox(height: 14),
          Row(children: [
            const Expanded(child: Divider(color: AppColors.hairline)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: T.caption())),
            const Expanded(child: Divider(color: AppColors.hairline)),
          ]),
          const SizedBox(height: 14),
          PillButton('Continue with Apple', kind: PillKind.secondary, icon: Icons.apple, trailing: false, onTap: go),
          const SizedBox(height: 10),
          PillButton('Continue with Google',
              kind: PillKind.secondary, icon: Icons.g_mobiledata_rounded, trailing: false, onTap: go),
          const SizedBox(height: 18),
          Center(child: Text('Booking confirmations arrive by email and SMS.', style: T.caption(size: 12))),
        ]),
      ),
    );
  }

  Widget _field(String label, String value, {IconData? trailing, String? extra}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label, style: T.label(size: 13, color: AppColors.text2)),
          const Spacer(),
          if (extra != null) Text(extra, style: T.label(size: 13, color: AppColors.brassText)),
        ]),
        const SizedBox(height: 6),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Row(children: [
            Expanded(child: Text(value, style: T.body(color: AppColors.text))),
            if (trailing != null) Icon(trailing, color: AppColors.text3, size: 20),
          ]),
        ),
      ]);
}
