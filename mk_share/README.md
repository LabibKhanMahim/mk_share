# mk_share

A new Flutter project created with FlutLab - https://flutlab.io

## Getting Started

A few resources to get you started if this is your first Flutter project:

- https://flutter.dev/docs/get-started/codelab
- https://flutter.dev/docs/cookbook

For help getting started with Flutter, view our
https://flutter.dev/docs, which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Getting Started: FlutLab - Flutter Online IDE

- How to use FlutLab? Please, view our https://flutlab.io/docs
- Join the discussion and conversation on https://flutlab.io/residents
# Mk Share - Local File Sharing App

A cyberpunk-themed local file sharing app that works offline over the same Wi-Fi or hotspot.

## Features

- Send and receive files over local Wi-Fi or hotspot
- Cyberpunk/neon UI theme with animations
- QR code scanning for easy connection
- PIN protection for secure transfers
- Progress tracking for file transfers
- Resume support for interrupted downloads
- Works completely offline

## Requirements

- Flutter SDK (>=2.17.0)
- Android Studio (EXE installer version)
- Android SDK
- USB debugging enabled on your device

## Installation

1. Clone or download this project
2. Open the project in Android Studio or VS Code
3. Run `flutter pub get` to install dependencies
4. Connect your Android device with USB debugging enabled
5. Run `flutter run` to launch the app

## Building APK

1. Run `flutter build apk --release`
2. The APK will be located at `build/app/outputs/flutter-apk/app-release.apk`

## Project Structure
lib/
├── main.dart # App entry point
├── screens/
│ ├── splash_screen.dart # Splash screen with animations
│ ├── home_screen.dart # Main home screen
│ ├── send_screen.dart # Send files screen
│ └── receive_screen.dart # Receive files screen
├── services/
│ ├── local_server.dart # HTTP server for file sharing
│ └── file_transfer.dart # File transfer utilities
├── widgets/
│ ├── neon_button.dart # Neon-styled button
│ ├── progress_tile.dart # Progress indicator for transfers
│ └── animated_background.dart # Animated background effects
└── utils/
├── theme.dart # App theme and colors
└── network_utils.dart # Network utilities

## Customization

### Replacing Animations

1. Replace the Lottie animation file at `assets/animations/cyber_logo.json` with your own
2. Update the path in `lib/screens/splash_screen.dart` if you change the filename

### Updating Social Links

1. Open `lib/screens/home_screen.dart`
2. Find the `_buildSocialButton` method calls
3. Replace the URLs with your own social media links

### Changing App Name

1. Update the name in `android/app/src/main/AndroidManifest.xml`
2. Update the title in `lib/main.dart`

### Hotspot Implementation

The app includes placeholder code for hotspot creation and connection in `lib/utils/network_utils.dart`. To implement this feature:

1. Create platform channels in your Android project
2. Implement the necessary Android APIs for hotspot management
3. Connect the platform channels to your Flutter code

## Permissions

The app requires the following permissions:
- INTERNET
- ACCESS_NETWORK_STATE
- ACCESS_WIFI_STATE
- CHANGE_WIFI_STATE
- READ_EXTERNAL_STORAGE
- WRITE_EXTERNAL_STORAGE
- MANAGE_EXTERNAL_STORAGE
- FOREGROUND_SERVICE

## Troubleshooting

- If the app doesn't detect files, make sure you've granted storage permissions
- If file transfers fail, ensure both devices are on the same network
- For hotspot functionality, you'll need to implement the platform-specific code

## License

This project is licensed under the MIT License.
