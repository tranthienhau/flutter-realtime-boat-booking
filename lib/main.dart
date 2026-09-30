import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'demo/autopilot.dart';
import 'nav.dart';
import 'screens/onboarding_screens.dart';
import 'theme/app_theme.dart';

/// `--dart-define=DEMO=true` walks the app hands-free (used for demo recordings).
const kDemo = bool.fromEnvironment('DEMO');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const ProviderScope(child: BoatingoApp()));
}

class BoatingoApp extends ConsumerStatefulWidget {
  const BoatingoApp({super.key, this.home});
  final Widget? home;

  @override
  ConsumerState<BoatingoApp> createState() => _BoatingoAppState();
}

class _BoatingoAppState extends ConsumerState<BoatingoApp> {
  @override
  void initState() {
    super.initState();
    if (kDemo) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Autopilot(ref).run());
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Boatingo',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        navigatorKey: navKey,
        home: widget.home ?? const OnboardingScreen(),
      );
}
