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
        // PetSpriteComponent decodes the spritesheet asynchronously, so wait
        // for all pending component-tree operations to materialize before
        // asserting on the mounted children.
        await game.ready();

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

        // Wait for the initial world components (including the async
        // spritesheet load) to fully mount before querying the tree.
        await game.ready();

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

        // Wait for the initial world components (including the async
        // spritesheet load) to fully mount before querying the tree.
        await game.ready();

        game.onLocaleChanged(newLabels);

        final overlay =
            game.world.children.whereType<MenuOverlayComponent>().single;
        expect(overlay.labels, newLabels);
      },
    );
  });
}
