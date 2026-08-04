// test/providers/pet_controller_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamagotchi/models/pet_state.dart';
import 'package:tamagotchi/providers/pet_controller.dart';

void main() {
  group('PetController', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('initial state is alive with full stats', () {
      final state = container.read(petControllerProvider);
      expect(state.isAlive, true);
      expect(state.hunger, 100.0);
    });

    test('feed increases hunger', () {
      container.read(petControllerProvider.notifier).feed();
      final state = container.read(petControllerProvider);
      expect(state.hunger, greaterThan(100.0 - 1));
    });

    test('play increases happiness and decreases hunger', () {
      container.read(petControllerProvider.notifier).play();
      final state = container.read(petControllerProvider);
      expect(state.happiness, 100.0);
      expect(state.hunger, lessThan(100.0));
    });

    test('toggleLight flips isLightOn', () {
      container.read(petControllerProvider.notifier).toggleLight();
      expect(container.read(petControllerProvider).isLightOn, false);
    });

    test('useMedicine increases health', () {
      final container2 = ProviderContainer(
        overrides: [
          petControllerProvider.overrideWith(() => _SickPetController()),
        ],
      );
      container2.read(petControllerProvider.notifier).useMedicine();
      final state = container2.read(petControllerProvider);
      expect(state.health, greaterThan(50.0));
      container2.dispose();
    });
  });
}

class _SickPetController extends PetController {
  @override
  PetState build() => PetState.initial().copyWith(health: 50.0);
}
