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
