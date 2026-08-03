# Tamagotchi Flutter App - Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a virtual pet (Tamagotchi) app with retro LCD aesthetics, real-time stat decay, animations, notifications, and mini-games.

**Architecture:** Riverpod owns all state (single source of truth). Flame renders the LCD screen as a reactive view. Communication is unidirectional: UI → Riverpod (actions), Riverpod → Flame (state changes), Flame → Riverpod (animation-complete events). TimeEngine calculates offline stat decay on resume.

**Tech Stack:** Flutter 3.x, Dart 3.x, flutter_riverpod ^2.4.9, flame ^1.12.0, shared_preferences ^2.2.2, flutter_local_notifications ^17.0.0, audioplayers ^6.0.0, freezed ^2.4.6, flutter_localizations (SDK), timeago ^3.6.1, package_info_plus ^5.0.1

## Global Constraints

- Riverpod is the ONLY source of truth; Flame NEVER mutates state directly.
- Flame is a reactive view: listens to Riverpod, updates animations.
- Unidirectional communication: UI → Riverpod → Flame → Riverpod (events only).
- TimeEngine caps offline calculation at 24 hours.
- LCD viewport: FixedResolutionViewport 160x144 (Game Boy aspect ratio).
- All state mutations persist to SharedPreferences immediately.
- Target: 60 FPS on Flame rendering.
- Minimum 3 languages: ES, EN, JA.
- Dart 3.x with null safety; use freezed for immutable models.

## Reglas de Oro de la Arquitectura

1. **Riverpod es la única fuente de verdad:** Flame NUNCA modifica el estado directamente.
2. **Flame es un "view" reactivo:** Escucha cambios de Riverpod y actualiza animaciones.
3. **Comunicación unidireccional:**
   - UI → Riverpod: Acciones del usuario (botones)
   - Riverpod → Flame: Cambios de estado (animaciones)
   - Flame → Riverpod: Eventos de juego completados (ej: "animación de comer terminó")

---

## File Structure

```
lib/
├── main.dart                          # App entry, ProviderScope, MaterialApp
├── app.dart                           # MaterialApp config, theme, localization
├── models/
│   ├── pet_state.dart                 # Freezed PetState (hunger, happiness, etc.)
│   ├── pet_state.freezed.dart         # Generated
│   ├── pet_stage.dart                 # Enum: egg, baby, child, teen, adult
│   └── pet_action.dart                # Enum: feed, play, clean, medicine, sleep
├── services/
│   ├── time_engine.dart               # Delta-time decay calculator
│   ├── persistence_service.dart       # SharedPreferences read/write
│   └── notification_service.dart      # flutter_local_notifications wrapper
├── providers/
│   ├── pet_controller.dart            # Notifier<PetState> with actions
│   ├── flame_action_provider.dart     # ChangeNotifier for one-shot animations
│   └── menu_provider.dart             # LCD menu navigation state
├── game/
│   ├── tamagotchi_game.dart           # FlameGame subclass, camera, components
│   ├── components/
│   │   ├── pet_sprite_component.dart  # Animated sprite (idle, eat, sleep, etc.)
│   │   ├── status_icon_component.dart # HUD icons on LCD
│   │   └── pixel_grid_component.dart  # Background grid effect
│   └── widgets/
│       └── game_screen.dart           # ConsumerStatefulWidget hosting GameWidget
├── ui/
│   ├── screens/
│   │   ├── home_screen.dart           # Tamagotchi shell + LCD + buttons
│   │   ├── mini_game_screen.dart      # Bonfire RPG (optional)
│   │   └── about_screen.dart          # package_info_plus version display
│   └── widgets/
│       ├── tamagotchi_shell.dart      # CustomPaint device casing
│       ├── lcd_screen.dart            # Wraps game_screen with bezel
│       └── physical_button.dart       # A/B/C button with haptic feedback
├── l10n/
│   ├── app_es.arb
│   ├── app_en.arb
│   └── app_ja.arb
└── utils/
    └── constants.dart                 # Decay rates, thresholds, durations

test/
├── models/
│   └── pet_state_test.dart
├── services/
│   ├── time_engine_test.dart
│   └── persistence_service_test.dart
├── providers/
│   └── pet_controller_test.dart
└── game/
    └── tamagotchi_game_test.dart

assets/
├── sprites/
│   └── tamagotchi_spritesheet.png     # All animation frames
├── audio/
│   ├── beep.wav
│   ├── eat.wav
│   └── cry.wav
└── images/
    └── shell_background.png
```

---

## Task 1: Project Scaffolding & Dependencies

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/main.dart`
- Create: `lib/app.dart`
- Create: `lib/utils/constants.dart`
- Create: `analysis_options.yaml`

**Interfaces:**
- Produces: Runnable Flutter app with all dependencies resolved. `Constants` class with decay rates and thresholds.

- [ ] **Step 1: Create Flutter project**

```bash
flutter create tamagotchi --org com.example --platforms ios,android
cd tamagotchi
```

- [ ] **Step 2: Configure pubspec.yaml dependencies**

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  flame: ^1.12.0
  shared_preferences: ^2.2.2
  logger: ^2.0.2
  flutter_local_notifications: ^17.0.0
  audioplayers: ^6.0.0
  freezed_annotation: ^2.4.1
  timeago: ^3.6.1
  package_info_plus: ^5.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  freezed: ^2.4.6
  build_runner: ^2.4.7
  flame_test: ^1.12.0
```

- [ ] **Step 3: Run pub get and build_runner**

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Create constants.dart**

```dart
abstract final class Constants {
  static const int lcdWidth = 160;
  static const int lcdHeight = 144;

  static const double hungerDecayPerHour = 4.0;
  static const double happinessDecayPerHour = 3.0;
  static const double healthDecayPerHour = 1.5;

  static const double hungerWarningThreshold = 40.0;
  static const double healthWarningThreshold = 30.0;

  static const int maxOfflineHours = 24;

  static const Duration eggHatchTime = Duration(minutes: 5);
  static const Duration babyToChild = Duration(hours: 24);
  static const Duration childToTeen = Duration(hours: 72);
  static const Duration teenToAdult = Duration(hours: 168);
}
```

- [ ] **Step 5: Create main.dart and app.dart**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TamagotchiApp()));
}
```

```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'ui/screens/home_screen.dart';

class TamagotchiApp extends StatelessWidget {
  const TamagotchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tamagotchi',
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
```

- [ ] **Step 6: Verify app compiles**

```bash
flutter analyze
flutter test
```

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat: project scaffolding with dependencies and constants"
```

---

## Task 2: PetState Model (Freezed)

**Files:**
- Create: `lib/models/pet_state.dart`
- Create: `lib/models/pet_stage.dart`
- Create: `lib/models/pet_action.dart`
- Create: `test/models/pet_state_test.dart`

**Interfaces:**
- Produces: `PetState` (immutable, copyWith), `PetStage` enum, `PetAction` enum.
- Consumed by: Task 3 (TimeEngine), Task 4 (PetController), Task 6 (Flame components).

- [ ] **Step 1: Write failing test for PetState**

```dart
// test/models/pet_state_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/pet_state.dart';
import 'package:tamagotchi/models/pet_stage.dart';

void main() {
  group('PetState', () {
    test('creates default state with full stats', () {
      final state = PetState.initial();
      expect(state.hunger, 100.0);
      expect(state.happiness, 100.0);
      expect(state.health, 100.0);
      expect(state.weight, 5.0);
      expect(state.age, Duration.zero);
      expect(state.isAlive, true);
      expect(state.isSleeping, false);
      expect(state.isLightOn, true);
      expect(state.stage, PetStage.egg);
    });

    test('copyWith preserves unchanged fields', () {
      final state = PetState.initial();
      final updated = state.copyWith(hunger: 50.0);
      expect(updated.hunger, 50.0);
      expect(updated.happiness, 100.0);
      expect(updated.isAlive, true);
    });

    test('stats clamp between 0 and 100', () {
      final state = PetState.initial().copyWith(hunger: 150.0);
      expect(state.hunger, 100.0);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/models/pet_state_test.dart
```
Expected: FAIL — cannot find `package:tamagotchi/models/pet_state.dart`

- [ ] **Step 3: Implement PetStage and PetAction enums**

```dart
// lib/models/pet_stage.dart
enum PetStage { egg, baby, child, teen, adult }
```

```dart
// lib/models/pet_action.dart
enum PetAction { feed, play, clean, medicine, toggleLight, sleep }
```

- [ ] **Step 4: Implement PetState with freezed**

```dart
// lib/models/pet_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'pet_stage.dart';

part 'pet_state.freezed.dart';
part 'pet_state.g.dart';

@freezed
class PetState with _$PetState {
  const PetState._();

  const factory PetState({
    required double hunger,
    required double happiness,
    required double health,
    required double weight,
    required Duration age,
    required bool isAlive,
    required bool isSleeping,
    required bool isLightOn,
    required DateTime lastUpdated,
    required PetStage stage,
  }) = _PetState;

  factory PetState.initial() => PetState(
        hunger: 100.0,
        happiness: 100.0,
        health: 100.0,
        weight: 5.0,
        age: Duration.zero,
        isAlive: true,
        isSleeping: false,
        isLightOn: true,
        lastUpdated: DateTime.now(),
        stage: PetStage.egg,
      );

  factory PetState.fromJson(Map<String, dynamic> json) =>
      _$PetStateFromJson(json);

  double get clampedHunger => hunger.clamp(0.0, 100.0);
  double get clampedHappiness => happiness.clamp(0.0, 100.0);
  double get clampedHealth => health.clamp(0.0, 100.0);
}
```

- [ ] **Step 5: Run build_runner**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 6: Run tests**

```bash
flutter test test/models/pet_state_test.dart
```
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat: PetState model with freezed, PetStage and PetAction enums"
```

---

## Task 3: TimeEngine (Delta-Time Decay)

**Files:**
- Create: `lib/services/time_engine.dart`
- Create: `test/services/time_engine_test.dart`

**Interfaces:**
- Consumes: `PetState` (Task 2), `Constants` (Task 1).
- Produces: `TimeEngine.applyDecay(PetState state, DateTime now) → PetState` — returns new state with decayed stats and updated age/stage.

- [ ] **Step 1: Write failing tests**

```dart
// test/services/time_engine_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/pet_state.dart';
import 'package:tamagotchi/services/time_engine.dart';
import 'package:tamagotchi/utils/constants.dart';

void main() {
  group('TimeEngine', () {
    test('applies decay for 1 hour offline', () {
      final now = DateTime(2024, 1, 1, 12, 0);
      final state = PetState.initial().copyWith(
        lastUpdated: DateTime(2024, 1, 1, 11, 0),
      );

      final result = TimeEngine.applyDecay(state, now);

      expect(result.hunger, 100.0 - Constants.hungerDecayPerHour);
      expect(result.happiness, 100.0 - Constants.happinessDecayPerHour);
      expect(result.health, 100.0 - Constants.healthDecayPerHour);
    });

    test('caps offline time at 24 hours', () {
      final now = DateTime(2024, 1, 5, 12, 0);
      final state = PetState.initial().copyWith(
        lastUpdated: DateTime(2024, 1, 1, 12, 0),
      );

      final result = TimeEngine.applyDecay(state, now);

      final expectedHunger =
          (100.0 - Constants.hungerDecayPerHour * 24).clamp(0.0, 100.0);
      expect(result.hunger, expectedHunger);
    });

    test('pet dies when health reaches 0', () {
      final now = DateTime(2024, 1, 2, 12, 0);
      final state = PetState.initial().copyWith(
        health: 10.0,
        lastUpdated: DateTime(2024, 1, 1, 12, 0),
      );

      final result = TimeEngine.applyDecay(state, now);

      expect(result.isAlive, false);
      expect(result.health, 0.0);
    });

    test('does not decay while sleeping', () {
      final now = DateTime(2024, 1, 1, 14, 0);
      final state = PetState.initial().copyWith(
        isSleeping: true,
        lastUpdated: DateTime(2024, 1, 1, 12, 0),
      );

      final result = TimeEngine.applyDecay(state, now);

      expect(result.hunger, 100.0);
    });

    test('updates lastUpdated to now', () {
      final now = DateTime(2024, 1, 1, 15, 0);
      final state = PetState.initial().copyWith(
        lastUpdated: DateTime(2024, 1, 1, 12, 0),
      );

      final result = TimeEngine.applyDecay(state, now);

      expect(result.lastUpdated, now);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/services/time_engine_test.dart
```
Expected: FAIL — cannot find `time_engine.dart`

- [ ] **Step 3: Implement TimeEngine**

```dart
// lib/services/time_engine.dart
import 'dart:math';
import '../models/pet_state.dart';
import '../models/pet_stage.dart';
import '../utils/constants.dart';

abstract final class TimeEngine {
  static PetState applyDecay(PetState state, DateTime now) {
    if (!state.isAlive) return state.copyWith(lastUpdated: now);
    if (state.isSleeping) return state.copyWith(lastUpdated: now);

    final elapsed = now.difference(state.lastUpdated);
    final cappedHours =
        min(elapsed.inMinutes / 60.0, Constants.maxOfflineHours.toDouble());

    if (cappedHours <= 0) return state.copyWith(lastUpdated: now);

    final newHunger =
        (state.hunger - Constants.hungerDecayPerHour * cappedHours)
            .clamp(0.0, 100.0);
    final newHappiness =
        (state.happiness - Constants.happinessDecayPerHour * cappedHours)
            .clamp(0.0, 100.0);
    final newHealth =
        (state.health - Constants.healthDecayPerHour * cappedHours)
            .clamp(0.0, 100.0);

    final isDead = newHealth <= 0;
    final newAge = state.age + Duration(minutes: elapsed.inMinutes);
    final newStage = _calculateStage(newAge);

    return state.copyWith(
      hunger: newHunger,
      happiness: newHappiness,
      health: isDead ? 0.0 : newHealth,
      age: newAge,
      isAlive: !isDead,
      stage: newStage,
      lastUpdated: now,
    );
  }

  static PetStage _calculateStage(Duration age) {
    if (age < Constants.eggHatchTime) return PetStage.egg;
    if (age < Constants.babyToChild) return PetStage.baby;
    if (age < Constants.childToTeen) return PetStage.child;
    if (age < Constants.teenToAdult) return PetStage.teen;
    return PetStage.adult;
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/services/time_engine_test.dart
```
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: TimeEngine with delta-time decay, 24h cap, death check"
```

---

## Task 4: PersistenceService

**Files:**
- Create: `lib/services/persistence_service.dart`
- Create: `test/services/persistence_service_test.dart`

**Interfaces:**
- Consumes: `PetState` (Task 2).
- Produces: `PersistenceService.save(PetState)`, `PersistenceService.load() → PetState?`.

- [ ] **Step 1: Write failing test**

```dart
// test/services/persistence_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamagotchi/models/pet_state.dart';
import 'package:tamagotchi/services/persistence_service.dart';

void main() {
  group('PersistenceService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('save and load roundtrip', () async {
      final state = PetState.initial();
      await PersistenceService.save(state);

      final loaded = await PersistenceService.load();
      expect(loaded, isNotNull);
      expect(loaded!.hunger, state.hunger);
      expect(loaded.stage, state.stage);
    });

    test('load returns null when no data', () async {
      final loaded = await PersistenceService.load();
      expect(loaded, isNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/services/persistence_service_test.dart
```

- [ ] **Step 3: Implement PersistenceService**

```dart
// lib/services/persistence_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_state.dart';

abstract final class PersistenceService {
  static const _key = 'pet_state';

  static Future<void> save(PetState state) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.toJson());
    await prefs.setString(_key, json);
  }

  static Future<PetState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return PetState.fromJson(json);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/services/persistence_service_test.dart
```
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: PersistenceService with SharedPreferences JSON storage"
```

---

## Task 5: PetController (Riverpod Notifier)

**Files:**
- Create: `lib/providers/pet_controller.dart`
- Create: `lib/providers/flame_action_provider.dart`
- Create: `test/providers/pet_controller_test.dart`

**Interfaces:**
- Consumes: `PetState` (Task 2), `TimeEngine` (Task 3), `PersistenceService` (Task 4).
- Produces: `petControllerProvider` (NotifierProvider), `flameActionProvider` (ChangeNotifierProvider). Actions: `feed()`, `play()`, `clean()`, `useMedicine()`, `toggleLight()`, `sleep()`, `wake()`.

- [ ] **Step 1: Write failing tests**

```dart
// test/providers/pet_controller_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamagotchi/models/pet_state.dart';
import 'package:tamagotchi/providers/pet_controller.dart';

void main() {
  group('PetController', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('initial state is alive with full stats', () {
      final state = container.read(petControllerProvider);
      expect(state.isAlive, true);
      expect(state.hunger, 100.0);
    });

    test('feed increases hunger', () {
      container.read(petControllerProvider.notifier).feed();
      final state = container.read(petControllerProvider);
      expect(state.hunger, greaterThan(100.0 - 1));
    });

    test('play increases happiness and decreases hunger', () {
      container.read(petControllerProvider.notifier).play();
      final state = container.read(petControllerProvider);
      expect(state.happiness, 100.0);
      expect(state.hunger, lessThan(100.0));
    });

    test('toggleLight flips isLightOn', () {
      container.read(petControllerProvider.notifier).toggleLight();
      expect(container.read(petControllerProvider).isLightOn, false);
    });

    test('useMedicine increases health', () {
      final container2 = ProviderContainer(
        overrides: [
          petControllerProvider.overrideWith(() => _SickPetController()),
        ],
      );
      container2.read(petControllerProvider.notifier).useMedicine();
      final state = container2.read(petControllerProvider);
      expect(state.health, greaterThan(50.0));
      container2.dispose();
    });
  });
}

class _SickPetController extends PetController {
  @override
  PetState build() => PetState.initial().copyWith(health: 50.0);
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/providers/pet_controller_test.dart
```

- [ ] **Step 3: Implement FlameActionNotifier**

```dart
// lib/providers/flame_action_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_action.dart';

class FlameActionNotifier extends ChangeNotifier {
  PetAction? _lastAction;
  int _timestamp = 0;

  PetAction? get lastAction => _lastAction;
  int get timestamp => _timestamp;

  void trigger(PetAction action) {
    _lastAction = action;
    _timestamp = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }
}

final flameActionProvider =
    ChangeNotifierProvider<FlameActionNotifier>((ref) => FlameActionNotifier());
```

- [ ] **Step 4: Implement PetController**

```dart
// lib/providers/pet_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_action.dart';
import '../models/pet_state.dart';
import '../services/persistence_service.dart';
import '../services/time_engine.dart';
import 'flame_action_provider.dart';

final petControllerProvider = NotifierProvider<PetController, PetState>(
  PetController.new,
);

class PetController extends Notifier<PetState> {
  @override
  PetState build() {
    _loadState();
    return PetState.initial();
  }

  Future<void> _loadState() async {
    final saved = await PersistenceService.load();
    if (saved != null) {
      final updated = TimeEngine.applyDecay(saved, DateTime.now());
      state = updated;
    }
  }

  Future<void> _commit(PetState newState) async {
    state = newState;
    await PersistenceService.save(newState);
  }

  void feed() {
    if (!state.isAlive) return;
    _commit(state.copyWith(
      hunger: (state.hunger + 20).clamp(0.0, 100.0),
      weight: state.weight + 0.5,
      lastUpdated: DateTime.now(),
    ));
    ref.read(flameActionProvider).trigger(PetAction.feed);
  }

  void play() {
    if (!state.isAlive) return;
    _commit(state.copyWith(
      happiness: (state.happiness + 15).clamp(0.0, 100.0),
      hunger: (state.hunger - 5).clamp(0.0, 100.0),
      weight: (state.weight - 0.2).clamp(1.0, 50.0),
      lastUpdated: DateTime.now(),
    ));
    ref.read(flameActionProvider).trigger(PetAction.play);
  }

  void clean() {
    if (!state.isAlive) return;
    _commit(state.copyWith(
      health: (state.health + 5).clamp(0.0, 100.0),
      lastUpdated: DateTime.now(),
    ));
    ref.read(flameActionProvider).trigger(PetAction.clean);
  }

  void useMedicine() {
    if (!state.isAlive) return;
    _commit(state.copyWith(
      health: (state.health + 30).clamp(0.0, 100.0),
      lastUpdated: DateTime.now(),
    ));
    ref.read(flameActionProvider).trigger(PetAction.medicine);
  }

  void toggleLight() {
    _commit(state.copyWith(
      isLightOn: !state.isLightOn,
      lastUpdated: DateTime.now(),
    ));
    ref.read(flameActionProvider).trigger(PetAction.toggleLight);
  }

  void sleep() {
    _commit(state.copyWith(isSleeping: true, lastUpdated: DateTime.now()));
    ref.read(flameActionProvider).trigger(PetAction.sleep);
  }

  void wake() {
    _commit(state.copyWith(isSleeping: false, lastUpdated: DateTime.now()));
  }

  void applyTimeDecay() {
    final updated = TimeEngine.applyDecay(state, DateTime.now());
    state = updated;
    PersistenceService.save(updated);
  }
}
```

- [ ] **Step 5: Run tests**

```bash
flutter test test/providers/pet_controller_test.dart
```
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: PetController with Riverpod Notifier, FlameActionNotifier"
```

---

## Task 6: Flame Game & Pet Sprite Component

**Files:**
- Create: `lib/game/tamagotchi_game.dart`
- Create: `lib/game/components/pet_sprite_component.dart`
- Create: `lib/game/components/pixel_grid_component.dart`
- Create: `lib/game/widgets/game_screen.dart`
- Create: `test/game/tamagotchi_game_test.dart`

**Interfaces:**
- Consumes: `PetState` (Task 2), `petControllerProvider` (Task 5), `flameActionProvider` (Task 5), `Constants` (Task 1).
- Produces: `TamagotchiGame` (FlameGame), `GameScreen` widget that bridges Riverpod ↔ Flame.

- [ ] **Step 1: Create placeholder spritesheet asset**

Create `assets/sprites/` directory. Add a placeholder PNG (or generate a simple 6-frame strip: 32x32 per frame for idle, eat, happy, sleep, sick, dead).

Update `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/sprites/
    - assets/audio/
    - assets/images/
```

- [ ] **Step 2: Implement PixelGridComponent**

```dart
// lib/game/components/pixel_grid_component.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PixelGridComponent extends Component with HasGameRef {
  final Paint _paint = Paint()
    ..color = const Color(0x0A000000)
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke;

  @override
  void render(Canvas canvas) {
    final size = gameRef.size;
    for (double x = 0; x < size.x; x += 4) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), _paint);
    }
    for (double y = 0; y < size.y; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), _paint);
    }
  }
}
```

- [ ] **Step 3: Implement PetSpriteComponent**

```dart
// lib/game/components/pet_sprite_component.dart
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../../models/pet_action.dart';
import '../../models/pet_stage.dart';
import '../../models/pet_state.dart';

class PetSpriteComponent extends SpriteAnimationGroupComponent<PetAction> {
  PetState petState;

  PetSpriteComponent({required this.petState, super.position, super.size});

  @override
  Future<void> onLoad() async {
    final image = await gameRef.images.load('tamagotchi_spritesheet.png');
    final sheet = SpriteSheet(image: image, srcSize: Vector2(32, 32));

    animations = {
      PetAction.feed: sheet.createAnimation(row: 1, stepTime: 0.15, to: 4),
      PetAction.play: sheet.createAnimation(row: 2, stepTime: 0.12, to: 6),
      PetAction.clean: sheet.createAnimation(row: 3, stepTime: 0.15, to: 4),
      PetAction.medicine: sheet.createAnimation(row: 4, stepTime: 0.2, to: 3),
      PetAction.toggleLight: sheet.createAnimation(row: 0, stepTime: 0.3, to: 2),
      PetAction.sleep: sheet.createAnimation(row: 5, stepTime: 0.5, to: 2),
    };

    current = PetAction.toggleLight;
  }

  void updateState(PetState newState) {
    petState = newState;
    if (!newState.isAlive) {
      // Show dead frame (static)
      return;
    }
    if (newState.isSleeping) {
      current = PetAction.sleep;
    }
  }

  void playOneShot(PetAction action) {
    current = action;
  }

  void returnToBase() {
    if (petState.isSleeping) {
      current = PetAction.sleep;
    } else {
      current = PetAction.toggleLight;
    }
  }
}
```

- [ ] **Step 4: Implement TamagotchiGame**

```dart
// lib/game/tamagotchi_game.dart
import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import '../models/pet_state.dart';
import '../utils/constants.dart';
import 'components/pet_sprite_component.dart';
import 'components/pixel_grid_component.dart';

class TamagotchiGame extends FlameGame {
  late PetSpriteComponent _petSprite;
  PetState _currentState;

  TamagotchiGame({required PetState initialState})
      : _currentState = initialState;

  @override
  Color backgroundColor() => const Color(0xFF9BBC0F);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    add(PixelGridComponent());

    _petSprite = PetSpriteComponent(
      petState: _currentState,
      position: Vector2(Constants.lcdWidth / 2 - 16, Constants.lcdHeight / 2 - 16),
      size: Vector2(32, 32),
    );
    add(_petSprite);
  }

  void onStateChanged(PetState newState) {
    _currentState = newState;
    _petSprite.updateState(newState);
  }

  void onAction(PetAction action) {
    _petSprite.playOneShot(action);
  }
}
```

- [ ] **Step 5: Implement GameScreen widget (Riverpod ↔ Flame bridge)**

```dart
// lib/game/widgets/game_screen.dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/pet_action.dart';
import '../../providers/flame_action_provider.dart';
import '../../providers/pet_controller.dart';
import '../tamagotchi_game.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late TamagotchiGame _game;

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(petControllerProvider);
    _game = TamagotchiGame(initialState: initialState);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(petControllerProvider, (prev, next) {
      _game.onStateChanged(next);
    });

    ref.listen(flameActionProvider, (prev, next) {
      final action = next.lastAction;
      if (action != null) {
        _game.onAction(action);
      }
    });

    return GameWidget(game: _game);
  }
}
```

- [ ] **Step 6: Write basic game test**

```dart
// test/game/tamagotchi_game_test.dart
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/game/tamagotchi_game.dart';
import 'package:tamagotchi/models/pet_state.dart';

void main() {
  group('TamagotchiGame', () {
    testWithGame<TamagotchiGame>(
      'loads with initial state',
      () => TamagotchiGame(initialState: PetState.initial()),
      (game) async {
        expect(game.children.length, greaterThanOrEqualTo(2));
      },
    );
  });
}
```

- [ ] **Step 7: Run tests and analyze**

```bash
flutter test
flutter analyze
```

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "feat: Flame game with PetSprite, PixelGrid, GameScreen bridge"
```

---

## Task 7: UI Shell & Physical Buttons

**Files:**
- Create: `lib/ui/screens/home_screen.dart`
- Create: `lib/ui/widgets/tamagotchi_shell.dart`
- Create: `lib/ui/widgets/lcd_screen.dart`
- Create: `lib/ui/widgets/physical_button.dart`
- Create: `lib/providers/menu_provider.dart`

**Interfaces:**
- Consumes: `petControllerProvider` (Task 5), `GameScreen` (Task 6).
- Produces: Complete home screen with 3 physical buttons (A=Select, B=Confirm, C=Cancel/Status) and LCD menu navigation.

- [ ] **Step 1: Implement MenuProvider**

```dart
// lib/providers/menu_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MenuItem { food, light, play, medicine, status, game }

final menuProvider = NotifierProvider<MenuNotifier, MenuState>(
  MenuNotifier.new,
);

class MenuState {
  final List<MenuItem> items;
  final int selectedIndex;
  final bool isVisible;

  const MenuState({
    this.items = MenuItem.values,
    this.selectedIndex = 0,
    this.isVisible = false,
  });

  MenuItem get currentItem => items[selectedIndex];

  MenuState copyWith({int? selectedIndex, bool? isVisible}) => MenuState(
        items: items,
        selectedIndex: selectedIndex ?? this.selectedIndex,
        isVisible: isVisible ?? this.isVisible,
      );
}

class MenuNotifier extends Notifier<MenuState> {
  @override
  MenuState build() => const MenuState();

  void next() {
    final s = state;
    final nextIndex = (s.selectedIndex + 1) % s.items.length;
    state = s.copyWith(selectedIndex: nextIndex);
  }

  void toggle() {
    state = state.copyWith(isVisible: !state.isVisible);
  }

  void hide() {
    state = state.copyWith(isVisible: false);
  }
}
```

- [ ] **Step 2: Implement PhysicalButton widget**

```dart
// lib/ui/widgets/physical_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhysicalButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const PhysicalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = const Color(0xFF4A4A4A),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 3),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Implement TamagotchiShell and LcdScreen**

```dart
// lib/ui/widgets/lcd_screen.dart
import 'package:flutter/material.dart';
import '../../game/widgets/game_screen.dart';

class LcdScreen extends StatelessWidget {
  const LcdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 180,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1A1A1A), width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: const GameScreen(),
      ),
    );
  }
}
```

```dart
// lib/ui/widgets/tamagotchi_shell.dart
import 'package:flutter/material.dart';
import 'lcd_screen.dart';
import 'physical_button.dart';

class TamagotchiShell extends StatelessWidget {
  final VoidCallback onButtonA;
  final VoidCallback onButtonB;
  final VoidCallback onButtonC;

  const TamagotchiShell({
    super.key,
    required this.onButtonA,
    required this.onButtonB,
    required this.onButtonC,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LcdScreen(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PhysicalButton(label: 'A', onPressed: onButtonA),
              PhysicalButton(label: 'B', onPressed: onButtonB),
              PhysicalButton(label: 'C', onPressed: onButtonC),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Implement HomeScreen**

```dart
// lib/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/pet_action.dart';
import '../../providers/menu_provider.dart';
import '../../providers/pet_controller.dart';
import '../widgets/tamagotchi_shell.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: TamagotchiShell(
          onButtonA: () => _handleA(ref),
          onButtonB: () => _handleB(ref),
          onButtonC: () => _handleC(ref),
        ),
      ),
    );
  }

  void _handleA(WidgetRef ref) {
    final menu = ref.read(menuProvider);
    if (!menu.isVisible) {
      ref.read(menuProvider.notifier).toggle();
    } else {
      ref.read(menuProvider.notifier).next();
    }
  }

  void _handleB(WidgetRef ref) {
    final menu = ref.read(menuProvider);
    if (!menu.isVisible) return;

    final controller = ref.read(petControllerProvider.notifier);
    switch (menu.currentItem) {
      case MenuItem.food:
        controller.feed();
      case MenuItem.light:
        controller.toggleLight();
      case MenuItem.play:
        controller.play();
      case MenuItem.medicine:
        controller.useMedicine();
      case MenuItem.status:
        break;
      case MenuItem.game:
        break;
    }
    ref.read(menuProvider.notifier).hide();
  }

  void _handleC(WidgetRef ref) {
    ref.read(menuProvider.notifier).hide();
  }
}
```

- [ ] **Step 5: Run analyze and test**

```bash
flutter analyze
flutter test
```

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: HomeScreen with Tamagotchi shell, LCD, A/B/C buttons, menu"
```

---

## Task 8: App Lifecycle & Notifications

**Files:**
- Create: `lib/services/notification_service.dart`
- Modify: `lib/main.dart` (add WidgetsBindingObserver)
- Create: `lib/lifecycle_observer.dart`

**Interfaces:**
- Consumes: `petControllerProvider` (Task 5), `Constants` (Task 1).
- Produces: `NotificationService.scheduleWarnings(PetState)`, `NotificationService.cancelAll()`. `LifecycleObserver` handles pause/resume.

- [ ] **Step 1: Implement NotificationService**

```dart
// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/pet_state.dart';
import '../utils/constants.dart';

abstract final class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  static Future<void> scheduleWarnings(PetState state) async {
    await cancelAll();
    if (!state.isAlive) return;

    if (state.hunger < Constants.hungerWarningThreshold) {
      await _schedule(
        id: 1,
        title: 'Tamagotchi',
        body: 'Tu mascota tiene hambre!',
        delay: const Duration(minutes: 30),
      );
    }

    if (state.health < Constants.healthWarningThreshold) {
      await _schedule(
        id: 2,
        title: 'Tamagotchi',
        body: 'Tu mascota esta enferma!',
        delay: const Duration(minutes: 15),
      );
    }
  }

  static Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      DateTime.now().add(delay),
      const NotificationDetails(
        android: AndroidNotificationDetails('tamagotchi', 'Tamagotchi'),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
```

- [ ] **Step 2: Implement LifecycleObserver**

```dart
// lib/lifecycle_observer.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/pet_controller.dart';
import 'services/notification_service.dart';

class LifecycleObserver with WidgetsBindingObserver {
  final WidgetRef ref;

  LifecycleObserver(this.ref);

  void register() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        final petState = ref.read(petControllerProvider);
        NotificationService.scheduleWarnings(petState);
      case AppLifecycleState.resumed:
        NotificationService.cancelAll();
        ref.read(petControllerProvider.notifier).applyTimeDecay();
      default:
        break;
    }
  }
}
```

- [ ] **Step 3: Wire into main.dart**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const ProviderScope(child: TamagotchiApp()));
}
```

Update `HomeScreen` to `ConsumerStatefulWidget` and register `LifecycleObserver` in `initState`.

- [ ] **Step 4: Run analyze**

```bash
flutter analyze
```

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: lifecycle observer, local notifications on pause/resume"
```

---

## Task 9: Localization (ES, EN, JA)

**Files:**
- Create: `lib/l10n/app_es.arb`
- Create: `lib/l10n/app_en.arb`
- Create: `lib/l10n/app_ja.arb`
- Create: `l10n.yaml`
- Modify: `lib/app.dart` (add localizationsDelegates, supportedLocales)

**Interfaces:**
- Produces: `AppLocalizations` class with typed getters for all UI strings.

- [ ] **Step 1: Create l10n.yaml**

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

- [ ] **Step 2: Create ARB files**

```json
// lib/l10n/app_en.arb
{
  "@@locale": "en",
  "appTitle": "Tamagotchi",
  "hunger": "Hunger",
  "happiness": "Happiness",
  "health": "Health",
  "weight": "Weight",
  "age": "Age",
  "menuFood": "Food",
  "menuLight": "Light",
  "menuPlay": "Play",
  "menuMedicine": "Medicine",
  "menuStatus": "Status",
  "menuGame": "Game",
  "petDead": "Your pet has passed away...",
  "lastFed": "Last fed: {time}",
  "@lastFed": {
    "placeholders": {
      "time": { "type": "String" }
    }
  }
}
```

```json
// lib/l10n/app_es.arb
{
  "@@locale": "es",
  "appTitle": "Tamagotchi",
  "hunger": "Hambre",
  "happiness": "Felicidad",
  "health": "Salud",
  "weight": "Peso",
  "age": "Edad",
  "menuFood": "Comida",
  "menuLight": "Luz",
  "menuPlay": "Jugar",
  "menuMedicine": "Medicina",
  "menuStatus": "Estado",
  "menuGame": "Juego",
  "petDead": "Tu mascota ha fallecido...",
  "lastFed": "Ultima comida: {time}"
}
```

```json
// lib/l10n/app_ja.arb
{
  "@@locale": "ja",
  "appTitle": "たまごっち",
  "hunger": "おなか",
  "happiness": "しあわせ",
  "health": "けんこう",
  "weight": "たいじゅう",
  "age": "ねんれい",
  "menuFood": "ごはん",
  "menuLight": "ライト",
  "menuPlay": "あそぶ",
  "menuMedicine": "くすり",
  "menuStatus": "ステータス",
  "menuGame": "ゲーム",
  "petDead": "ペットは天国に旅立ちました...",
  "lastFed": "最後の食事: {time}"
}
```

- [ ] **Step 3: Generate localizations**

```bash
flutter gen-l10n
```

- [ ] **Step 4: Update app.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'ui/screens/home_screen.dart';

class TamagotchiApp extends StatelessWidget {
  const TamagotchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tamagotchi',
      theme: ThemeData.dark(useMaterial3: true),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('ja'),
      ],
      home: const HomeScreen(),
    );
  }
}
```

- [ ] **Step 5: Run analyze**

```bash
flutter analyze
```

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: i18n support for ES, EN, JA with ARB files"
```

---

## Task 10: Audio & Polish

**Files:**
- Create: `lib/services/audio_service.dart`
- Modify: `lib/providers/pet_controller.dart` (trigger sounds on actions)

**Interfaces:**
- Consumes: `PetAction` (Task 2).
- Produces: `AudioService.play(PetAction)` — plays corresponding retro sound effect.

- [ ] **Step 1: Add audio assets**

Place `beep.wav`, `eat.wav`, `cry.wav` in `assets/audio/`.

- [ ] **Step 2: Implement AudioService**

```dart
// lib/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';
import '../models/pet_action.dart';

abstract final class AudioService {
  static final _player = AudioPlayer();

  static Future<void> play(PetAction action) async {
    final file = switch (action) {
      PetAction.feed => 'audio/eat.wav',
      PetAction.play => 'audio/beep.wav',
      PetAction.clean => 'audio/beep.wav',
      PetAction.medicine => 'audio/beep.wav',
      PetAction.toggleLight => 'audio/beep.wav',
      PetAction.sleep => 'audio/beep.wav',
    };
    await _player.play(AssetSource(file));
  }
}
```

- [ ] **Step 3: Integrate into PetController actions**

Add `AudioService.play(action)` call after each `flameActionProvider.trigger()` in PetController.

- [ ] **Step 4: Run analyze and test**

```bash
flutter analyze
flutter test
```

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: retro audio effects via audioplayers"
```

---

## Task 11: About Screen & Package Info

**Files:**
- Create: `lib/ui/screens/about_screen.dart`
- Modify: `lib/providers/menu_provider.dart` (add navigation to about)

**Interfaces:**
- Consumes: `package_info_plus`.
- Produces: About screen showing version, build number.

- [ ] **Step 1: Implement AboutScreen**

```dart
// lib/ui/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final info = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Tamagotchi', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('v${info.version}+${info.buildNumber}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyze**

```bash
flutter analyze
```

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "feat: about screen with package_info_plus"
```

---

## Testing & Debugging Guide

### Probar Delta Time
1. Abre la app y alimenta a la mascota.
2. Minimiza la app.
3. Cambia la hora del sistema del emulador a 3 horas en el futuro.
4. Vuelve a abrir la app.
5. **Resultado esperado:** El hambre y la felicidad bajan drásticamente de golpe.

### Probar Notificaciones
1. Baja el hambre a < 40 (usa medicine/play repetidamente o edita estado).
2. Minimiza la app.
3. Espera el tiempo programado (30 min por defecto).
4. **Resultado esperado:** Llega la notificación al sistema.
5. Abre la app.
6. **Resultado esperado:** Las notificaciones pendientes se cancelan.

---

## Criterios de Aceptación

- [ ] La mascota evoluciona correctamente según edad y cuidados.
- [ ] Las notificaciones llegan cuando la app está cerrada y se cancelan al abrir.
- [ ] Flame renderiza animaciones suaves a 60 FPS sin lag.
- [ ] Riverpod mantiene el estado consistente entre reinicios de la app.
- [ ] Los botones A, B, C responden correctamente y navegan el menú.
- [ ] Soporte para 3 idiomas (ES, EN, JA).
- [ ] El tiempo transcurrido se calcula correctamente (respetando el límite de 24h).
- [ ] Audio retro suena en cada acción.

---

*Versión del Plan: 3.0*
