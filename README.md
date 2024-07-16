# Gym Management Flutter Project

This project aims to create a comprehensive mobile application using Flutter for managing gym operations and member interactions. The app provides a user-friendly interface for both gym administrators and members, facilitating efficient management of various aspects of a gym facility.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## DEV Commands

```
flutter clean
```
- **Purpose:** Removes the `build` directory and its contents in your Flutter project.
- **Explanation:** Useful for clearing build artifacts and ensuring a clean build environment without affecting your source code.

```
flutter pub get
```
  - **Purpose:** Fetches dependencies listed in your `pubspec.yaml` file and updates your `pubspec.lock` file.
  - **Explanation:** Ensures all necessary dependencies are installed and resolves version constraints after modifications to `pubspec.yaml`.

```
dart run build_runner build
```
  - **Purpose:** Generates code based on annotations in your Dart files using the `build_runner` package.
  - **Explanation:** Essential for tasks like JSON serialization, Hive type adapters, and other code generation tasks defined in your project.

```
flutter pub run flutter_launcher_icons
```
  - **Purpose:** Updates Flutter app launcher icons to custom icons specified in `pubspec.yaml`.
  - **Explanation:** Generates platform-specific launcher icons for Android and iOS based on custom icon paths specified in `pubspec.yaml`.

```
dart run flutter_native_splash:create --flutter_native_splash.yaml
```
  - **Purpose:** Generates native splash screens for your Flutter app.
  - **Explanation:** Uses configuration details from `flutter_native_splash.yaml` to create native splash screens (launch screens) for Android and iOS.

```
flutter build apk --build-name=1.0.0 --build-number=1 --split-per-abi
```
  - **Purpose:** Builds a release APK for your Flutter app targeting Android, splitting the APK by CPU architecture (ABI).
  - **Explanation:** Prepares your app for deployment by optimizing APK size and performance across different Android device architectures (`armeabi-v7a`, `arm64-v8a`, `x86`, `x86_64`).