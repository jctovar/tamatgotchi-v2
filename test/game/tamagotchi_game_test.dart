import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/game/tamagotchi_game.dart';
import 'package:tamagotchi/models/pet_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
