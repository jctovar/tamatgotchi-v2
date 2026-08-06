// test/game/components/pet_sprite_component_test.dart
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/game/components/pet_sprite_component.dart';
import 'package:tamagotchi/game/tamagotchi_game.dart';
import 'package:tamagotchi/models/pet_action.dart';
import 'package:tamagotchi/models/pet_state.dart';
import 'package:tamagotchi/providers/menu_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TamagotchiGame gameWith(PetState state) => TamagotchiGame(
        initialState: state,
        initialMenuState: const MenuState(),
      );

  group('PetSpriteComponent', () {
    testWithGame<TamagotchiGame>(
      'updateState switches to the sleep animation when sleeping',
      () => gameWith(PetState.initial()),
      (game) async {
        await game.ready();
        game.onStateChanged(
          PetState.initial().copyWith(isSleeping: true),
        );
        final sprite =
            game.world.children.whereType<PetSpriteComponent>().single;
        expect(sprite.current, PetAction.sleep);
      },
    );

    testWithGame<TamagotchiGame>(
      'updateState does not change the animation when the pet is dead',
      () => gameWith(
        PetState.initial().copyWith(health: 0.0, isAlive: false),
      ),
      (game) async {
        await game.ready();
        final sprite =
            game.world.children.whereType<PetSpriteComponent>().single;
        sprite.playOneShot(PetAction.play);
        sprite.updateState(
          PetState.initial().copyWith(health: 0.0, isAlive: false),
        );
        expect(sprite.current, PetAction.play);
      },
    );

    testWithGame<TamagotchiGame>(
      'returnToBase returns to the sleep animation when sleeping',
      () => gameWith(PetState.initial().copyWith(isSleeping: true)),
      (game) async {
        await game.ready();
        final sprite =
            game.world.children.whereType<PetSpriteComponent>().single;
        sprite.playOneShot(PetAction.feed);
        sprite.returnToBase();
        expect(sprite.current, PetAction.sleep);
      },
    );

    testWithGame<TamagotchiGame>(
      'returnToBase returns to the idle animation when awake',
      () => gameWith(PetState.initial()),
      (game) async {
        await game.ready();
        final sprite =
            game.world.children.whereType<PetSpriteComponent>().single;
        sprite.playOneShot(PetAction.feed);
        sprite.returnToBase();
        expect(sprite.current, PetAction.toggleLight);
      },
    );

    testWithGame<TamagotchiGame>(
      'playOneShot switches to the given animation',
      () => gameWith(PetState.initial()),
      (game) async {
        await game.ready();
        final sprite =
            game.world.children.whereType<PetSpriteComponent>().single;
        sprite.playOneShot(PetAction.feed);
        expect(sprite.current, PetAction.feed);
      },
    );
  });
}