# Menu Overlay Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Draw the `menuProvider` state (visibility, selected item, six labeled
options) on the Tamagotchi's LCD via a new Flame component, with text
localized through the existing (currently unused) `AppLocalizations`
infrastructure.

**Architecture:** Extend the Riverpod→Flame bridging pattern `GameScreen`
already uses for `petControllerProvider` and `flameActionProvider`: a new
`MenuOverlayComponent` lives in `TamagotchiGame.world`; `GameScreen` pushes
`menuProvider` changes and localized labels into the game via two new bridge
methods (`onMenuChanged`, `onLocaleChanged`).

**Tech Stack:** Flutter, Flame 1.38 (`Component`, `TextPaint`), Riverpod
(`flutter_riverpod`), generated `AppLocalizations` (ARB-based i18n),
`flame_test` for component tests.

## Global Constraints

- LCD logical resolution is fixed at `Constants.lcdWidth` × `Constants.lcdHeight`
  (160×144) — defined in `lib/utils/constants.dart`. All drawing coordinates
  in this plan use these constants, never raw literals.
- Menu label order must match `MenuItem.values` exactly: `food, light, play,
  medicine, status, game` (defined in `lib/providers/menu_provider.dart`).
- Colors (from the approved spec, `docs/superpowers/specs/2026-08-05-menu-overlay-design.md`):
  panel background `0xCC2C2C2C` (semi-transparent), selected-row highlight
  `0xFF9BBC0F`, selected-row text `0xFF0F380F`, unselected text `0xFF9BBC0F`.
- No new error handling is required anywhere in this plan (see spec's
  "Manejo de errores" section) — `MenuState` always has 6 valid items by
  construction, and `AppLocalizations.of(context)!` is safe because the
  delegate is already registered in `lib/app.dart` for all 3 supported
  locales.
- Out of scope (do not implement): replacing the placeholder spritesheet, an
  in-app language switcher, real icon assets, implementing the `status`/`game`
  menu actions.

---

### Task 1: Create `MenuOverlayComponent`

**Files:**
- Create: `lib/game/components/menu_overlay_component.dart`
- Test: `test/game/menu_overlay_component_test.dart`

**Interfaces:**
- Consumes: `MenuState`, `MenuItem` from `lib/providers/menu_provider.dart`
  (existing — `MenuState` has `items` (`List<MenuItem>`), `selectedIndex`
  (`int`), `isVisible` (`bool`); `MenuItem` is an enum with 6 values in this
  exact order: `food, light, play, medicine, status, game`). `Constants.lcdWidth`
  / `Constants.lcdHeight` (`int`) from `lib/utils/constants.dart`.
- Produces: `class MenuOverlayComponent extends Component` with public
  mutable fields `MenuState menuState` (default `const MenuState()`) and
  `List<String> labels` (default: `MenuItem.values.map((item) => item.name).toList()`),
  and two methods `void updateMenuState(MenuState state)` and
  `void updateLabels(List<String> newLabels)`. Task 2 depends on this exact
  class name, field names, and method signatures.

- [ ] **Step 1: Write the failing test**

Create `test/game/menu_overlay_component_test.dart`:

```dart
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/game/components/menu_overlay_component.dart';
import 'package:tamagotchi/providers/menu_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Canvas newCanvas() => Canvas(PictureRecorder());

  group('MenuOverlayComponent', () {
    test('starts hidden with enum-name fallback labels', () {
      final component = MenuOverlayComponent();

      expect(component.menuState.isVisible, false);
      expect(component.labels, MenuItem.values.map((e) => e.name).toList());
    });

    test('updateMenuState replaces the stored menu state', () {
      final component = MenuOverlayComponent();
      const newState = MenuState(selectedIndex: 2, isVisible: true);

      component.updateMenuState(newState);

      expect(component.menuState.isVisible, true);
      expect(component.menuState.selectedIndex, 2);
    });

    test('updateLabels replaces the stored labels', () {
      final component = MenuOverlayComponent();
      const newLabels = ['Comida', 'Luz', 'Jugar', 'Medicina', 'Estado', 'Juego'];

      component.updateLabels(newLabels);

      expect(component.labels, newLabels);
    });

    test('render does nothing when hidden (no exception, stays hidden)', () {
      final component = MenuOverlayComponent();

      expect(() => component.render(newCanvas()), returnsNormally);
    });

    test('render draws the menu without throwing when visible', () {
      final component = MenuOverlayComponent()
        ..updateMenuState(const MenuState(selectedIndex: 1, isVisible: true))
        ..updateLabels(const [
          'Comida',
          'Luz',
          'Jugar',
          'Medicina',
          'Estado',
          'Juego',
        ]);

      expect(() => component.render(newCanvas()), returnsNormally);
    });

    test('priority is high so it draws above other world components', () {
      final component = MenuOverlayComponent();

      expect(component.priority, 10);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/game/menu_overlay_component_test.dart`
Expected: FAIL — `Error: Error when reading 'lib/game/components/menu_overlay_component.dart': No such file or directory` (or an unresolved import error), because the component doesn't exist yet.

- [ ] **Step 3: Write minimal implementation**

Create `lib/game/components/menu_overlay_component.dart`:

```dart
/// Overlay visual del menú de opciones sobre la pantalla LCD.
///
/// Este archivo define [MenuOverlayComponent], el componente Flame que dibuja
/// el estado de `menuProvider` (Riverpod) sobre la pantalla LCD: la lista de
/// opciones, cuál está seleccionada y si el menú está visible. Es un
/// componente puramente reactivo: `TamagotchiGame` le empuja los cambios de
/// estado y de idioma; el componente nunca los origina.
library;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../providers/menu_provider.dart';
import '../../utils/constants.dart';

/// Dibuja la lista de opciones del menú sobre la pantalla LCD cuando está
/// visible.
///
/// Se agrega a `world` con [priority] alto para dibujarse siempre por encima
/// de `PixelGridComponent` y del sprite de la mascota, sin depender del
/// orden en que se insertaron. Mientras el menú está oculto, [render] no
/// dibuja nada.
class MenuOverlayComponent extends Component {
  /// Alto de cada línea de opción, en píxeles lógicos de la pantalla LCD.
  static const double _lineHeight = 18;

  /// Margen superior antes de la primera línea.
  static const double _topPadding = 16;

  /// Margen horizontal del panel y de la barra de selección.
  static const double _horizontalPadding = 8;

  /// Último estado del menú recibido desde Riverpod.
  MenuState menuState = const MenuState();

  /// Etiquetas localizadas, en el mismo orden que [MenuState.items].
  ///
  /// Antes de recibir el primer [updateLabels] (vía `AppLocalizations`),
  /// usa los nombres del enum como valor por defecto.
  List<String> labels = MenuItem.values.map((item) => item.name).toList();

  /// Pintura del texto de opciones no seleccionadas.
  final TextPaint _unselectedText = TextPaint(
    style: const TextStyle(
      color: Color(0xFF9BBC0F),
      fontFamily: 'monospace',
      fontSize: 10,
    ),
  );

  /// Pintura del texto de la opción seleccionada (sobre fondo invertido).
  final TextPaint _selectedText = TextPaint(
    style: const TextStyle(
      color: Color(0xFF0F380F),
      fontFamily: 'monospace',
      fontSize: 10,
    ),
  );

  /// Crea el overlay con prioridad de dibujado alta.
  MenuOverlayComponent() : super(priority: 10);

  /// Actualiza el estado del menú (visibilidad y selección).
  void updateMenuState(MenuState state) {
    menuState = state;
  }

  /// Actualiza las etiquetas de texto localizadas.
  void updateLabels(List<String> newLabels) {
    labels = newLabels;
  }

  /// Dibuja el panel semitransparente y la lista de opciones si el menú
  /// está visible; no hace nada si está oculto.
  @override
  void render(Canvas canvas) {
    if (!menuState.isVisible) return;

    final width = Constants.lcdWidth.toDouble();
    final height = Constants.lcdHeight.toDouble();

    // Panel de fondo semitransparente sobre toda la pantalla lógica.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = const Color(0xCC2C2C2C),
    );

    for (var i = 0; i < menuState.items.length; i++) {
      final rowY = _topPadding + i * _lineHeight;
      final isSelected = i == menuState.selectedIndex;

      if (isSelected) {
        canvas.drawRect(
          Rect.fromLTWH(
            _horizontalPadding,
            rowY,
            width - _horizontalPadding * 2,
            _lineHeight,
          ),
          Paint()..color = const Color(0xFF9BBC0F),
        );
      }

      (isSelected ? _selectedText : _unselectedText).render(
        canvas,
        labels[i],
        Vector2(_horizontalPadding * 2, rowY + 2),
      );
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/game/menu_overlay_component_test.dart`
Expected: PASS (6 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/game/components/menu_overlay_component.dart test/game/menu_overlay_component_test.dart
git commit -m "feat: add MenuOverlayComponent to render menu state on the LCD"
```

---

### Task 2: Wire `MenuOverlayComponent` into `TamagotchiGame`

**Files:**
- Modify: `lib/game/tamagotchi_game.dart`
- Modify: `test/game/tamagotchi_game_test.dart`

**Interfaces:**
- Consumes: `MenuOverlayComponent` (`updateMenuState`, `updateLabels`) from
  Task 1. `MenuState` from `lib/providers/menu_provider.dart`.
- Produces: `TamagotchiGame` constructor now requires
  `required MenuState initialMenuState` (in addition to the existing
  `required PetState initialState`). Two new public methods:
  `void onMenuChanged(MenuState newState)` and
  `void onLocaleChanged(List<String> labels)`. Task 3 depends on this exact
  constructor signature and these two method names.

- [ ] **Step 1: Write the failing test**

Replace the full contents of `test/game/tamagotchi_game_test.dart`:

```dart
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/game/components/menu_overlay_component.dart';
import 'package:tamagotchi/game/tamagotchi_game.dart';
import 'package:tamagotchi/models/pet_state.dart';
import 'package:tamagotchi/providers/menu_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TamagotchiGame', () {
    testWithGame<TamagotchiGame>(
      'loads with initial state',
      () => TamagotchiGame(
        initialState: PetState.initial(),
        initialMenuState: const MenuState(),
      ),
      (game) async {
        // PixelGridComponent + PetSpriteComponent + MenuOverlayComponent.
        expect(game.world.children.length, greaterThanOrEqualTo(3));
      },
    );

    testWithGame<TamagotchiGame>(
      'onMenuChanged forwards the new menu state to the overlay',
      () => TamagotchiGame(
        initialState: PetState.initial(),
        initialMenuState: const MenuState(),
      ),
      (game) async {
        const newState = MenuState(selectedIndex: 3, isVisible: true);

        game.onMenuChanged(newState);

        final overlay =
            game.world.children.whereType<MenuOverlayComponent>().single;
        expect(overlay.menuState.isVisible, true);
        expect(overlay.menuState.selectedIndex, 3);
      },
    );

    testWithGame<TamagotchiGame>(
      'onLocaleChanged forwards the new labels to the overlay',
      () => TamagotchiGame(
        initialState: PetState.initial(),
        initialMenuState: const MenuState(),
      ),
      (game) async {
        const newLabels = ['Comida', 'Luz', 'Jugar', 'Medicina', 'Estado', 'Juego'];

        game.onLocaleChanged(newLabels);

        final overlay =
            game.world.children.whereType<MenuOverlayComponent>().single;
        expect(overlay.labels, newLabels);
      },
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/game/tamagotchi_game_test.dart`
Expected: FAIL — compile error, `The named parameter 'initialMenuState' isn't defined` (constructor doesn't accept it yet) and `The method 'onMenuChanged' isn't defined for the type 'TamagotchiGame'`.

- [ ] **Step 3: Write minimal implementation**

In `lib/game/tamagotchi_game.dart`, add the import (after the existing
`pixel_grid_component.dart` import):

```dart
import 'components/menu_overlay_component.dart';
import '../providers/menu_provider.dart';
```

Add a field next to `_petSprite` (after line `late PetSpriteComponent _petSprite;`):

```dart
  /// Componente que dibuja el overlay del menú, creado durante [onLoad].
  late MenuOverlayComponent _menuOverlay;

  /// Último estado del menú recibido desde Riverpod.
  MenuState _initialMenuState;
```

Update the constructor to accept and store the initial menu state:

```dart
  TamagotchiGame({
    required PetState initialState,
    required MenuState initialMenuState,
  })  : _currentState = initialState,
        _initialMenuState = initialMenuState,
        super(
          camera: CameraComponent.withFixedResolution(
            width: Constants.lcdWidth.toDouble(),
            height: Constants.lcdHeight.toDouble(),
          ),
        );
```

Update `onLoad` to create and add the overlay, seeded with the initial menu
state:

```dart
  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(PixelGridComponent());

    _petSprite = PetSpriteComponent(
      petState: _currentState,
      position: Vector2(
        Constants.lcdWidth / 2 - 16,
        Constants.lcdHeight / 2 - 16,
      ),
      size: Vector2(32, 32),
    );
    world.add(_petSprite);

    _menuOverlay = MenuOverlayComponent()..updateMenuState(_initialMenuState);
    world.add(_menuOverlay);
  }
```

Add the two bridge methods after `onAction`:

```dart
  /// Punto de entrada "Riverpod → Flame" para cambios del menú.
  ///
  /// Empuja el nuevo estado del menú (visibilidad y selección) al overlay.
  void onMenuChanged(MenuState newState) {
    _menuOverlay.updateMenuState(newState);
  }

  /// Punto de entrada "Flutter → Flame" para cambios de idioma.
  ///
  /// Empuja las etiquetas localizadas de las opciones del menú al overlay,
  /// en el mismo orden que `MenuItem.values`.
  void onLocaleChanged(List<String> labels) {
    _menuOverlay.updateLabels(labels);
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/game/tamagotchi_game_test.dart`
Expected: PASS (3 tests)

Then run the full suite to confirm nothing else broke (`game_screen.dart`
still calls the old two-argument constructor at this point, so this is
expected to fail until Task 3 — run just the game tests, not the full
suite, to confirm this task in isolation):

Run: `flutter analyze lib/game/tamagotchi_game.dart`
Expected: one error in `lib/game/widgets/game_screen.dart` about the missing
`initialMenuState` argument — this is expected and resolved in Task 3. No
errors should be reported in `lib/game/tamagotchi_game.dart` itself.

- [ ] **Step 5: Commit**

```bash
git add lib/game/tamagotchi_game.dart test/game/tamagotchi_game_test.dart
git commit -m "feat: wire MenuOverlayComponent into TamagotchiGame"
```

---

### Task 3: Bridge `menuProvider` and locale from `GameScreen`

**Files:**
- Modify: `lib/game/widgets/game_screen.dart`

**Interfaces:**
- Consumes: `TamagotchiGame` constructor (`initialState`, `initialMenuState`)
  and methods `onMenuChanged(MenuState)`, `onLocaleChanged(List<String>)` from
  Task 2. `menuProvider` (`NotifierProvider<MenuNotifier, MenuState>`) from
  `lib/providers/menu_provider.dart`. `AppLocalizations.of(BuildContext)` from
  `lib/l10n/app_localizations.dart` (getters: `menuFood`, `menuLight`,
  `menuPlay`, `menuMedicine`, `menuStatus`, `menuGame`, all `String`).
- Produces: nothing new consumed by later tasks — this is the last task that
  touches production code.

This task has no dedicated new test file (see the spec's Testing section:
`game_screen.dart` has no test today, and the other two existing
`ref.listen` bridges in this file aren't tested directly either — this
follows the same, already-established precedent). Verification is via the
existing full test suite plus manual/device confirmation in Task 4.

- [ ] **Step 1: Add the required imports**

In `lib/game/widgets/game_screen.dart`, add two imports after the existing
`import '../../providers/pet_controller.dart';` line:

```dart
import '../../providers/menu_provider.dart';
import '../../l10n/app_localizations.dart';
```

- [ ] **Step 2: Read the initial menu state in `initState`**

Replace the existing `initState` method:

```dart
  @override
  void initState() {
    super.initState();
    final initialState = ref.read(petControllerProvider);
    _game = TamagotchiGame(initialState: initialState);
  }
```

with:

```dart
  @override
  void initState() {
    super.initState();
    final initialState = ref.read(petControllerProvider);
    final initialMenuState = ref.read(menuProvider);
    _game = TamagotchiGame(
      initialState: initialState,
      initialMenuState: initialMenuState,
    );
  }
```

- [ ] **Step 3: Push localized menu labels on `didChangeDependencies`**

Add a new override immediately after `initState` (before `build`):

```dart
  /// Empuja las etiquetas del menú localizadas al motor.
  ///
  /// Se ejecuta una vez al montar el widget y de nuevo si cambian las
  /// dependencias de [BuildContext] (por ejemplo, si cambia el locale del
  /// sistema en caliente). No se hace en [build] para no reenviar las
  /// etiquetas en cada reconstrucción no relacionada con el idioma.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _game.onLocaleChanged([
      l10n.menuFood,
      l10n.menuLight,
      l10n.menuPlay,
      l10n.menuMedicine,
      l10n.menuStatus,
      l10n.menuGame,
    ]);
  }
```

- [ ] **Step 4: Listen to `menuProvider` changes in `build`**

In the existing `build` method, add a third `ref.listen` call, after the
existing `flameActionProvider` listener and before `return GameWidget(...)`:

```dart
    // Sincroniza la visibilidad/selección del menú con el motor.
    ref.listen(menuProvider, (prev, next) {
      _game.onMenuChanged(next);
    });
```

The full `build` method should now read:

```dart
  @override
  Widget build(BuildContext context) {
    // Sincroniza los cambios de estado de la mascota con el motor.
    ref.listen(petControllerProvider, (prev, next) {
      _game.onStateChanged(next);
    });

    // Traslada los eventos de acción emitidos por el controlador al motor.
    ref.listen(flameActionProvider, (prev, next) {
      final action = next.lastAction;
      if (action != null) {
        _game.onAction(action);
      }
    });

    // Sincroniza la visibilidad/selección del menú con el motor.
    ref.listen(menuProvider, (prev, next) {
      _game.onMenuChanged(next);
    });

    return GameWidget(game: _game);
  }
```

- [ ] **Step 5: Run the full test suite**

Run: `flutter analyze`
Expected: `No issues found!`

Run: `flutter test`
Expected: all tests pass, including the pre-existing
`test/widget_test.dart` smoke test (unaffected — it builds the full app
tree, not `TamagotchiGame` directly) and the Task 1/Task 2 tests.

- [ ] **Step 6: Commit**

```bash
git add lib/game/widgets/game_screen.dart
git commit -m "feat: bridge menuProvider and locale into the Flame menu overlay"
```

---

### Task 4: Manual verification

**Files:** none (verification only, no code changes expected).

**Interfaces:** none.

- [ ] **Step 1: Run the full automated suite one more time**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` and all tests pass.

- [ ] **Step 2: Visually verify on a device or emulator, if one is available**

If a device/emulator is connected (`flutter devices` lists one), run the
app (`flutter run -d <device-id>`) and confirm, by tapping the on-screen A/B/C
buttons:
- Pressing A with the menu hidden shows a semi-transparent panel with 6
  text options and the first one highlighted.
- Pressing A again moves the highlight to the next option, wrapping around
  after the last one.
- Pressing C hides the panel.
- Pressing B while an option is highlighted hides the panel (and, for
  `food`/`light`/`play`/`medicine`, triggers the corresponding pet action —
  already covered by existing `PetController` tests, not re-verified here).

If no device/emulator is available, note this in the final report and skip
this step — Step 1's automated coverage is the required bar for this plan;
this step is best-effort visual confirmation.

- [ ] **Step 3: Report results**

No commit for this task (no files changed). Summarize in the final report:
automated suite status, and whether manual visual verification was
performed and what was observed.
