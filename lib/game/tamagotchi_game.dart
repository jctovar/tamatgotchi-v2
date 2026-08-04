import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../models/pet_action.dart';
import '../models/pet_state.dart';
import '../utils/constants.dart';
import 'components/pet_sprite_component.dart';
import 'components/pixel_grid_component.dart';

class TamagotchiGame extends FlameGame {
  late PetSpriteComponent _petSprite;
  PetState _currentState;

  TamagotchiGame({required PetState initialState})
      : _currentState = initialState,
        super(
          camera: CameraComponent.withFixedResolution(
            width: Constants.lcdWidth.toDouble(),
            height: Constants.lcdHeight.toDouble(),
          ),
        );

  @override
  Color backgroundColor() => const Color(0xFF9BBC0F);

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
  }

  void onStateChanged(PetState newState) {
    _currentState = newState;
    _petSprite.updateState(newState);
  }

  void onAction(PetAction action) {
    _petSprite.playOneShot(action);
  }
}
