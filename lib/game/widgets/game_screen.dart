import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
