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

## Environment setup

Copy the provided `.env.example` file to `.env` and replace the placeholder
values with your actual keys before running or testing the project:

```bash
cp .env.example .env
# edit .env and supply real values
```

The `.env` file is required because it is referenced in `pubspec.yaml` under the
`flutter.assets` section, so Flutter needs it at build time.
