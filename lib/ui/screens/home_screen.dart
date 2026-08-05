import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lifecycle_observer.dart';
import '../../providers/menu_provider.dart';
import '../../providers/pet_controller.dart';
import '../widgets/tamagotchi_shell.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final LifecycleObserver _observer;

  @override
  void initState() {
    super.initState();
    _observer = LifecycleObserver(ref);
    _observer.register();
  }

  @override
  void dispose() {
    _observer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TamagotchiShell(
          onButtonA: _handleA,
          onButtonB: _handleB,
          onButtonC: _handleC,
        ),
      ),
    );
  }

  void _handleA() {
    final menu = ref.read(menuProvider);
    if (!menu.isVisible) {
      ref.read(menuProvider.notifier).toggle();
    } else {
      ref.read(menuProvider.notifier).next();
    }
  }

  void _handleB() {
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

  void _handleC() {
    ref.read(menuProvider.notifier).hide();
  }
}
