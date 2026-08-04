import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
