import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/providers/menu_provider.dart';

void main() {
  group('MenuNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('estado inicial: primera opcion seleccionada y menu oculto', () {
      final state = container.read(menuProvider);

      expect(state.selectedIndex, 0);
      expect(state.isVisible, false);
      expect(state.currentItem, MenuItem.food);
      expect(state.items, MenuItem.values);
    });

    test('next avanza a la siguiente opcion', () {
      container.read(menuProvider.notifier).next();

      final state = container.read(menuProvider);
      expect(state.selectedIndex, 1);
      expect(state.currentItem, MenuItem.light);
    });

    test('next vuelve al inicio de forma circular tras la ultima opcion', () {
      final notifier = container.read(menuProvider.notifier);
      for (var i = 0; i < MenuItem.values.length; i++) {
        notifier.next();
      }

      final state = container.read(menuProvider);
      expect(state.selectedIndex, 0);
      expect(state.currentItem, MenuItem.food);
    });

    test('next preserva la visibilidad del menu', () {
      final notifier = container.read(menuProvider.notifier);
      notifier.toggle();
      notifier.next();

      expect(container.read(menuProvider).isVisible, true);
    });

    test('toggle muestra el menu si estaba oculto', () {
      container.read(menuProvider.notifier).toggle();

      expect(container.read(menuProvider).isVisible, true);
    });

    test('toggle oculta el menu si estaba visible', () {
      final notifier = container.read(menuProvider.notifier);
      notifier.toggle();
      notifier.toggle();

      expect(container.read(menuProvider).isVisible, false);
    });

    test('hide oculta el menu aunque ya este oculto', () {
      container.read(menuProvider.notifier).hide();

      expect(container.read(menuProvider).isVisible, false);
    });

    test('hide oculta un menu visible sin alterar la seleccion', () {
      final notifier = container.read(menuProvider.notifier);
      notifier.toggle();
      notifier.next();
      notifier.hide();

      final state = container.read(menuProvider);
      expect(state.isVisible, false);
      expect(state.selectedIndex, 1);
    });
  });

  group('MenuState.copyWith', () {
    test('conserva los valores no especificados', () {
      const state = MenuState(selectedIndex: 2, isVisible: true);

      final copy = state.copyWith();

      expect(copy.selectedIndex, 2);
      expect(copy.isVisible, true);
      expect(copy.items, state.items);
    });

    test('sobrescribe solo los campos indicados', () {
      const state = MenuState();

      final copy = state.copyWith(selectedIndex: 3, isVisible: true);

      expect(copy.selectedIndex, 3);
      expect(copy.isVisible, true);
    });
  });
}
