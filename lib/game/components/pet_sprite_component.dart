import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../../models/pet_action.dart';
import '../../models/pet_state.dart';
import '../tamagotchi_game.dart';

class PetSpriteComponent extends SpriteAnimationGroupComponent<PetAction>
    with HasGameReference<TamagotchiGame> {
  PetState petState;

  PetSpriteComponent({required this.petState, super.position, super.size});

  @override
  Future<void> onLoad() async {
    final image = await game.images.load('tamagotchi_spritesheet.png');
    final sheet = SpriteSheet(image: image, srcSize: Vector2(32, 32));

    animations = {
      PetAction.feed: sheet.createAnimation(row: 1, stepTime: 0.15, to: 4),
      PetAction.play: sheet.createAnimation(row: 2, stepTime: 0.12, to: 6),
      PetAction.clean: sheet.createAnimation(row: 3, stepTime: 0.15, to: 4),
      PetAction.medicine: sheet.createAnimation(row: 4, stepTime: 0.2, to: 3),
      PetAction.toggleLight:
          sheet.createAnimation(row: 0, stepTime: 0.3, to: 2),
      PetAction.sleep: sheet.createAnimation(row: 5, stepTime: 0.5, to: 2),
    };

    current = PetAction.toggleLight;
  }

  void updateState(PetState newState) {
    petState = newState;
    if (!newState.isAlive) {
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
