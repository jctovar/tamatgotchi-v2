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
- The menu (`menuProvider`, lib/providers/menu_provider.dart) renders on the LCD via
  `MenuOverlayComponent` (lib/game/components/), following the same bridging pattern as pet
  state: `GameScreen` (`ref.listen`) pushes `MenuState` into `TamagotchiGame.onMenuChanged`, which
  forwards to the component. `GameScreen.didChangeDependencies` also pushes localized menu labels
  via `TamagotchiGame.onLocaleChanged`, reading `AppLocalizations.of(context)!` — this means any
  widget test that builds a bare `MaterialApp` around `GameScreen`/`HomeScreen` (instead of the
  real `TamagotchiApp`) **must** register `AppLocalizations.delegate` +
  `GlobalMaterialLocalizations.delegate` + `GlobalWidgetsLocalizations.delegate`, or it crashes
  with a null-check error on mount. See `test/ui/screens/home_screen_test.dart` for the pattern.
- Flame components with no async loading of their own (e.g. `MenuOverlayComponent`) should be
  plain eager fields (`final X _x = X();`), not `late` fields constructed in `onLoad()`. A `late`
  field there is only safe to touch after `onLoad()` completes, which trips up any caller that
  isn't itself gated on Flame's lifecycle (`TamagotchiGame.loaded`/`.ready()`) — `late` should be
  reserved for components like `PetSpriteComponent` that really do need `onLoad()`-time work
  (loading the spritesheet image).
- `assets/images/tamagotchi_spritesheet.png` is a **placeholder** (a small generated blob, Game
  Boy palette) — not final art. Real pixel art is still pending.

## Testing quirks
- Provider/service tests use `ProviderContainer()` with **no Flutter binding**. Mock
  SharedPreferences first: `SharedPreferences.setMockInitialValues({})`.
- `test/widget_test.dart` pumps the app, which embeds a Flame `GameWidget`: use single-frame
  `tester.pumpWidget(...)` — **never `pumpAndSettle`** (the game ticks continuously and will hang).
- `AudioService` intentionally guards on `ServicesBinding.instance` and lazy-inits the
  `AudioPlayer` so actions don't throw in binding-less tests. Don't remove that guard.
- `flame_test` must stay **2.x** — 1.x does not compile against flame 1.38.
- **`flame_test`'s `testWithGame`**: `game.children` is always just `{camera, world}` — it never
  reflects what you `world.add(...)`'d. Assert on `game.world.children` instead. If any of those
  components load something async in their own `onLoad()` (e.g. `PetSpriteComponent` decoding the
  spritesheet), `await game.ready()` before asserting — a single `game.update(0)` tick isn't
  enough for the tree to fully materialize.
- **`NotificationService` tests**: mock the `MethodChannel('dexterous.com/flutter/local_notifications')`
  (shared by every platform implementation, so no need to force `defaultTargetPlatform`) and call
  `NotificationService.init()` once per test file to load the `timezone` database — `tz.local` is
  `late` internally and throws if `initializeTimeZones()` never ran.
- **`AudioService`/`audioplayers` tests**: mocking `xyz.luan/audioplayers` (per-player calls) is
  not enough — the *first* `AudioPlayer()` construction also needs the global scope's channels
  mocked: `MethodChannel('xyz.luan/audioplayers.global')` and
  `EventChannel('xyz.luan/audioplayers.global/events')`, or a real, uncatchable
  `MissingPluginException` escapes through an unawaited internal `Future`. The per-player
  `EventChannel('xyz.luan/audioplayers/events/$playerId')` (random UUID, can't be pre-mocked) is
  safe to leave unmocked — it has its own `onError` handler.

## Version gotchas (verified against installed packages)
- **Flame 1.38:** `HasGameRef` is deprecated — use `HasGameReference` and the `.game` accessor.
  Components rendered through the camera go in `world.add(...)`; the LCD uses
  `CameraComponent.withFixedResolution(width: 160, height: 144)`.
- **flutter_local_notifications 17.x:** `zonedSchedule` requires a `TZDateTime` (package
  `timezone`, call `initializeTimeZones()` once) **and** the named
  `uiLocalNotificationDateInterpretation` argument. It also requires Android **core library
  desugaring** — `android/app/build.gradle.kts` needs `isCoreLibraryDesugaringEnabled = true` in
  `compileOptions` and a `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:...")`
  dependency, or `assembleDebug` fails outright. Already set up; don't remove it.
- **Asset paths:** Flame `images.load('x.png')` auto-prefixes `assets/images/`; audioplayers
  `AssetSource('audio/x.wav')` auto-prefixes `assets/`. Declare asset **directories** in pubspec —
  declaring a directory that doesn't exist breaks `flutter test`.

## Repo notes
- `.superpowers/` is git-ignored SDD scratch space (plan ledger/briefs) — don't commit it.
- `PLAN.md` is the original implementation plan (11 tasks, all complete).
- `docs/superpowers/specs/` and `docs/superpowers/plans/` hold approved design specs and
  implementation plans for later features (e.g. the menu overlay) — unlike `.superpowers/`, these
  **are** committed; they're the durable record of *why*, not scratch.
- Branch `main`; remote `origin` = github.com/jctovar/tamatgotchi-v2.
