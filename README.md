# parkit_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Development Setup

### Prerequisites

- **Flutter SDK** – clone the repository with `git clone https://github.com/flutter/flutter.git -b stable` or download it from the [official site](https://docs.flutter.dev/get-started/install).
- **Android SDK** – install via Android Studio or command line tools.

After installing Flutter, add the `flutter/bin` directory to your `PATH` so the `flutter` command is available globally.

### Install Dependencies

Run the following command in the project directory to fetch all packages:

```bash
flutter pub get
```

### Running Tests

Execute the test suite with:

```bash
flutter test
```

### Environment Variables

Copy `.env.example` to `.env` and fill in the required values. The app loads environment variables from `.env` during startup.
