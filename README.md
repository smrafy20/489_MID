# Bangladesh Map

Flutter map demo that shows markers and a bottom info card with an expandable image. This README explains how to set up, build, and run the app on different platforms.

## Prerequisites
- Flutter SDK (stable). Install from https://flutter.dev
- A supported toolchain for your target platform(s):
  - Android: Android Studio, Android SDK, an emulator or a physical device with USB debugging
  - iOS: Xcode and CocoaPods (macOS only)
  - Web: Google Chrome
  - Windows desktop: Visual Studio with Desktop development with C++ workload (Windows only)

Verify your installation:
```
flutter doctor
```

## Get dependencies
From the project root (this folder):
```
flutter pub get
```

## Run the app (quick start)
List available devices and run on one of them:
```
flutter devices
flutter run -d <device_id>
```

### Common targets
- Web (Chrome):
```
flutter run -d chrome
```
- Android (emulator):
```
flutter emulators --launch <emulator_name>
flutter run -d <device_id>
```
- Windows desktop:
```
flutter config --enable-windows-desktop
flutter run -d windows
```
- iOS (on macOS):
```
open ios/Runner.xcworkspace   # first-time setup may require Xcode signing
flutter run -d ios
```

## Build release artifacts
- Android APK (release):
```
flutter build apk --release
```
- Android App Bundle (for Play Store):
```
flutter build appbundle
```
- iOS (archive via Xcode on macOS):
```
flutter build ios --release
```
- Web (static site in build/web):
```
flutter build web
```
- Windows desktop (release exe in build/windows):
```
flutter build windows
```

## Troubleshooting
- If dependencies or builds act up:
```
flutter clean
flutter pub get
```
- Accept Android licenses (if prompted):
```
flutter doctor --android-licenses
```
- Make sure a device is connected/available:
```
flutter devices
```

That’s it! If you need CI/CD or containerized builds, let me know your target platform and I’ll add an example workflow.
