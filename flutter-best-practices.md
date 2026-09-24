# Flutter App Development Best Practices

## Table of Contents

1. [Project Structure and Architecture](#1-project-structure-and-architecture)
2. [Widgets and UI](#2-widgets-and-ui)
3. [Performance](#3-performance)
4. [Code Quality](#4-code-quality)
5. [Networking and Data](#5-networking-and-data)
6. [Navigation](#6-navigation)
7. [Security](#7-security)
8. [Testing](#8-testing)
9. [Internationalization and Accessibility](#9-internationalization-and-accessibility)
10. [Environment and Configuration](#10-environment-and-configuration)
11. [CI/CD and Release](#11-cicd-and-release)
12. [Dependencies](#12-dependencies)

---

## 1. Project Structure and Architecture

- **Organize by feature**, not by type. `lib/features/auth/{data,domain,presentation}` scales better than `lib/screens`, `lib/models`, and so on.
- **Keep the layers separate.** UI goes in widgets, business logic in controllers, blocs or notifiers, and data access in repositories and services. Widgets shouldn't call APIs directly.
- **Choose one state management approach and stick with it.** Riverpod, Bloc/Cubit and Provider are all well supported. Mixing them causes confusion.
- **Use dependency injection** (Riverpod providers, `get_it`, or constructor injection) so you can swap and mock parts easily.
- **Use immutable models.** `freezed` or hand-written `copyWith` combined with `==` and `hashCode` works well.

Example feature-first layout:

```text
lib/
├── main.dart
├── app/                  # App widget, router, theme
├── core/                 # Shared utils, constants, errors, network client
└── features/
    └── auth/
        ├── data/         # DTOs, data sources, repository implementations
        ├── domain/       # Entities, repository interfaces, use cases
        └── presentation/ # Screens, widgets, controllers/blocs
```

## 2. Widgets and UI

- **Prefer `const` constructors** wherever you can. They skip rebuilds and cut allocations.
- **Split large `build` methods into small widget classes**, not helper methods that return widgets. Separate classes get their own element and can rebuild on their own.
- **Keep `build()` pure and cheap.** Don't do network calls, heavy computation or object creation (such as controllers) inside it.
- **Dispose what you create**: `TextEditingController`, `AnimationController`, `StreamSubscription`, `FocusNode`, `ScrollController`.
- **Check `mounted`** after an `await` before using `context` or calling `setState`.
- **Use `ListView.builder` or `SliverList`** for long or unbounded lists. Never build them with `Column` plus `map`.
- **Build responsive layouts** with `LayoutBuilder`, `MediaQuery.sizeOf(context)` and `Flexible`/`Expanded`, not hard-coded sizes.
- **Centralize theming** in `ThemeData`, using `ColorScheme` and `TextTheme`. Avoid hard-coded colors and font sizes, and support dark mode.

```dart
Future<void> _save() async {
  await repository.save(data);
  if (!mounted) return; // Guard context use after async gaps
  Navigator.of(context).pop();
}
```

## 3. Performance

- Profile in **profile mode** (`flutter run --profile`) with DevTools. Debug mode performance doesn't tell you much.
- Use **`RepaintBoundary`** around widgets that repaint often, and avoid `Opacity` and `ClipPath` in animations. Prefer `FadeTransition` and `AnimatedOpacity`.
- Keep rebuilds narrow with `Selector`, `select()` in Riverpod, `BlocSelector`, or `ValueListenableBuilder`.
- Move heavy work (JSON parsing of large payloads, image processing) off the UI thread with **`compute()` / `Isolate.run()`**.
- **Cache and size images** with `cached_network_image`, `cacheWidth` and `cacheHeight`, and use appropriately sized assets.
- Build tree-shaken releases, and use `--split-debug-info` plus `--obfuscate` for release builds.

## 4. Code Quality

- Turn on strict linting with `flutter_lints` or `very_good_analysis`, and fix analyzer warnings rather than ignoring them.
- Run `dart format` in CI and in a pre-commit hook.
- **Use null safety properly.** Avoid `!` unless you can guarantee the value isn't null, and prefer `?.`, `??` and early returns.
- Use `final` by default, and make classes and fields private (`_`) unless they need to be public.
- Name things consistently: `snake_case` files, `UpperCamelCase` types, `lowerCamelCase` members.
- Use code generation (`build_runner`, `json_serializable`, `freezed`) instead of hand-writing boilerplate.

## 5. Networking and Data

- Use `dio` or `http` behind a repository interface, with **typed models** and centralized error handling through interceptors.
- Model failures explicitly with a sealed `Result` or `Either` type, or sealed exception classes. Don't let raw exceptions reach the UI.
- Handle **loading, empty, error and success states** for every async screen, for example with `AsyncValue` in Riverpod.
- For local storage, use `shared_preferences` for small key-value data and `drift`, `isar`, `hive` or `sqflite` for structured data.
- Plan for **offline and poor connectivity**: timeouts, retries and cached responses.

## 6. Navigation

- Use **declarative routing** (`go_router` or `auto_route`) for deep links, web URLs and guarded routes.
- Keep route names and paths in one place, and pass IDs rather than whole objects wherever you can.

## 7. Security

- **Never hard-code secrets** in the app. Anything in the binary can be extracted. Keep sensitive keys on a backend.
- Store tokens with **`flutter_secure_storage`** (Keychain/Keystore), not `SharedPreferences`.
- Use HTTPS only, and consider certificate pinning for sensitive apps.
- Obfuscate release builds and validate all input on the server side too.
- Keep dependencies up to date (`flutter pub outdated`) and review third-party packages before adding them.

## 8. Testing

| Test type   | Purpose                                            | Tools                              |
|-------------|----------------------------------------------------|------------------------------------|
| Unit        | Business logic, repositories, state classes        | `test`, `mocktail` / `mockito`     |
| Widget      | UI behavior in isolation                           | `flutter_test` (`pumpWidget`, finders) |
| Golden      | Visual regressions                                 | Built-in goldens, `alchemist`      |
| Integration | Critical end-to-end user flows on device/emulator  | `integration_test`, `patrol`       |

- Mock dependencies and aim for meaningful coverage of the logic layers.

## 9. Internationalization and Accessibility

- Use `flutter_localizations` with ARB files (`gen-l10n`) from the start. Retrofitting later is painful.
- Add `Semantics` labels, make tap targets at least 48×48, support text scaling, and check color contrast.
- Test with TalkBack/VoiceOver and with large font settings.

## 10. Environment and Configuration

- Use **flavors** (dev/staging/prod) with `--dart-define` or `--dart-define-from-file` for per-environment config.
- Keep platform-specific code isolated in platform channels or federated plugins.
- Pin the Flutter SDK version per project with **FVM** or `.tool-versions` so builds are reproducible.

## 11. CI/CD and Release

- Automate `analyze`, `format`, `test` and builds in CI (GitHub Actions, Codemagic, Bitrise).
- Automate signing and store uploads with **Fastlane** or Codemagic.
- Add crash reporting and analytics (Firebase Crashlytics or Sentry) and keep your symbol files for readable stack traces.
- Use semantic versioning and increment `version: x.y.z+build` in `pubspec.yaml` for every release.

Typical CI checks:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage
```

## 12. Dependencies

- **Keep packages to a minimum.** Check pub points, popularity, maintenance activity and platform support first.
- Commit `pubspec.lock` for apps (not for packages).
- Wrap third-party packages behind your own interfaces so you can replace them later.
