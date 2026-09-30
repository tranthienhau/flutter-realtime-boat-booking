import 'package:boatingo/demo/autopilot.dart';
import 'package:boatingo/main.dart';
import 'package:boatingo/nav.dart';
import 'package:boatingo/state/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Runs the real app on a simulator and walks the same scripted flow as the
/// demo recording, capturing one PNG per screen into screenshots/.
/// Fixed pumps (not pumpAndSettle) because the live dots animate forever.
/// `--dart-define=SHOT_PREFIX=android-` keeps per-platform captures apart.
const kPrefix = String.fromEnvironment('SHOT_PREFIX');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture every screen of the booking flow', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [liveFeedEnabledProvider.overrideWithValue(false)],
      child: const BoatingoApp(),
    ));
    await binding.convertFlutterSurfaceToImage();
    await tester.pump(const Duration(seconds: 2));

    final container = ProviderScope.containerOf(navKey.currentContext!);
    for (final step in demoSteps()) {
      step.action(container);
      // Let the route transition finish and images decode.
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
      await tester.pump(const Duration(milliseconds: 200));
      await binding.takeScreenshot('$kPrefix${step.name}');
    }
  });
}
