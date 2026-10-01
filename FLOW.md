# Regenerating screenshots and demo GIFs

## Screenshots (iOS simulator)

```sh
xcrun simctl boot "iPhone 17 Pro"
flutter pub get
flutter drive \
  --driver test_driver/integration_test.dart \
  --target integration_test/screenshot_test.dart \
  -d "iPhone 17 Pro"
```

## Screenshots (Android device or emulator)

```sh
flutter drive \
  --driver test_driver/integration_test.dart \
  --target integration_test/screenshot_test.dart \
  -d <device-id> --dart-define=SHOT_PREFIX=android-
```

How it works:
- `test_driver/integration_test.dart` uses `integrationDriver(onScreenshot:)` to write each PNG
  into `screenshots/`.
- `integration_test/screenshot_test.dart` runs the real app with the operator feed turned off
  (deterministic) and walks `demoSteps()` from `lib/demo/autopilot.dart`, the same script the
  demo recording uses. It calls `binding.convertFlutterSurfaceToImage()` once, then
  `binding.takeScreenshot()` per step, using fixed `pump(Duration)` (not `pumpAndSettle`)
  because the live dots animate forever.

## Demo GIFs

The app has a hands-free autopilot: `--dart-define=DEMO=true` walks the whole flow
(about 30 s) after launch.

iOS:

```sh
flutter build ios --simulator --debug --dart-define=DEMO=true
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
xcrun simctl io booted recordVideo --codec h264 --force /tmp/ios-demo.mp4 &
xcrun simctl launch booted com.tranthienhau.boatingo
# wait ~33 s, then Ctrl-C the recorder
```

Android:

```sh
flutter build apk --release --dart-define=DEMO=true
adb install -r build/app/outputs/flutter-apk/app-release.apk
adb shell screenrecord --time-limit 34 --size 540x1200 /sdcard/ademo.mp4 &
adb shell am start -n com.tranthienhau.boatingo/.MainActivity
sleep 36 && adb pull /sdcard/ademo.mp4 /tmp/ademo.mp4
```

Convert (trim the launch second, 10 fps, 280 px, 96 colours keeps each GIF under 3 MB):

```sh
ffmpeg -y -ss 2.2 -t 31 -i in.mp4 -vf "fps=10,scale=280:-1:flags=lanczos,palettegen=max_colors=96:stats_mode=diff" /tmp/pal.png
ffmpeg -y -ss 2.2 -t 31 -i in.mp4 -i /tmp/pal.png -lavfi "fps=10,scale=280:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" screenshots/demo.gif
```
