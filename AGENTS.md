# AGENTS.md

Flutter virtual-pet app ("Tamagotchi"). Package `tamagotchi`, single package (not a monorepo).
Toolchain verified on Flutter 3.44.8 / Dart 3.12.2. User docs (`README.md`, `manual.md`) and code
comments are in **Spanish**; keep identifiers in English, comments/docs in Spanish.

## Commands
```bash
flutter pub get
flutter test                                   # full suite
flutter test test/services/time_engine_test.dart            # single file
flutter test --plain-name "applies decay for 1 hour offline" # single test by name
flutter analyze                                # must stay "No issues found"
flutter gen-l10n                               # after editing lib/l10n/*.arb
dart run build_runner build --delete-conflicting-outputs    # after editing freezed models
```
Verification order: `flutter analyze` → `flutter test`. There is no CI, no formatter config, and no
typecheck step separate from `analyze`.

## Generated code — never hand-edit
- `lib/models/*.freezed.dart`, `lib/models/*.g.dart` → regenerate with `build_runner`.
- `lib/l10n/app_localizations*.dart` → regenerate with `flutter gen-l10n`.
- `pubspec.yaml` needs `flutter: generate: true` for gen-l10n to run.
- **Flutter 3.44 removed the `flutter_gen` synthetic package.** Import localizations as
  `package:tamagotchi/l10n/app_localizations.dart` — never `package:flutter_gen/...`.

## Architecture (not obvious from filenames)
- **Riverpod is the only source of truth.** Flame (`lib/game/`) is a read-only reactive view; it
  never mutates state. Flow: UI → `PetController` (lib/providers/pet_controller.dart) → state
  change → Flame. One-shot animations go through `flameActionProvider`.
- Every state mutation persists immediately via `PersistenceService` (SharedPreferences).
- Offline stat decay is computed by `TimeEngine` (lib/services/time_engine.dart), capped at 24h.
  The cap applies to **stat decay only** — `age` still advances by the full elapsed time. This is
  intentional; don't "fix" it.
- Gameplay tuning constants (decay rates, thresholds, stage durations) live in
  `lib/utils/constants.dart`.

## Testing quirks
- Provider/service tests use `ProviderContainer()` with **no Flutter binding**. Mock
  SharedPreferences first: `SharedPreferences.setMockInitialValues({})`.
- `test/widget_test.dart` pumps the app, which embeds a Flame `GameWidget`: use single-frame
  `tester.pumpWidget(...)` — **never `pumpAndSettle`** (the game ticks continuously and will hang).
- `AudioService` intentionally guards on `ServicesBinding.instance` and lazy-inits the
  `AudioPlayer` so actions don't throw in binding-less tests. Don't remove that guard.
- `flame_test` must stay **2.x** — 1.x does not compile against flame 1.38.

## Version gotchas (verified against installed packages)
- **Flame 1.38:** `HasGameRef` is deprecated — use `HasGameReference` and the `.game` accessor.
  Components rendered through the camera go in `world.add(...)`; the LCD uses
  `CameraComponent.withFixedResolution(width: 160, height: 144)`.
- **flutter_local_notifications 17.x:** `zonedSchedule` requires a `TZDateTime` (package
  `timezone`, call `initializeTimeZones()` once) **and** the named
  `uiLocalNotificationDateInterpretation` argument.
- **Asset paths:** Flame `images.load('x.png')` auto-prefixes `assets/images/`; audioplayers
  `AssetSource('audio/x.wav')` auto-prefixes `assets/`. Declare asset **directories** in pubspec —
  declaring a directory that doesn't exist breaks `flutter test`.

## Repo notes
- `.superpowers/` is git-ignored SDD scratch space (plan ledger/briefs) — don't commit it.
- `PLAN.md` is the original implementation plan (11 tasks, all complete).
- Branch `main`; remote `origin` = github.com/jctovar/tamatgotchi-v2.
