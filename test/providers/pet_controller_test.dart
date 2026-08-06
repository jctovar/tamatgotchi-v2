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

    test('clean increases health', () {
      final container2 = ProviderContainer(
        overrides: [
          petControllerProvider.overrideWith(() => _SickPetController()),
        ],
      );
      container2.read(petControllerProvider.notifier).clean();
      final state = container2.read(petControllerProvider);
      expect(state.health, greaterThan(50.0));
      container2.dispose();
    });

    test('clean has no effect when the pet is dead', () {
      final container2 = ProviderContainer(
        overrides: [
          petControllerProvider
              .overrideWith(() => _DeadPetController()),
        ],
      );
      final before = container2.read(petControllerProvider).health;
      container2.read(petControllerProvider.notifier).clean();
      final after = container2.read(petControllerProvider);
      expect(after.health, before);
      expect(after, same(container2.read(petControllerProvider)));
      container2.dispose();
    });

    test('sleep sets isSleeping to true', () {
      container.read(petControllerProvider.notifier).sleep();
      expect(container.read(petControllerProvider).isSleeping, true);
    });

    test('wake sets isSleeping to false without emitting an action', () {
      container.read(petControllerProvider.notifier).sleep();
      container.read(petControllerProvider.notifier).wake();
      expect(container.read(petControllerProvider).isSleeping, false);
    });
  });
}

class _SickPetController extends PetController {
  @override
  PetState build() => PetState.initial().copyWith(health: 50.0);
}

class _DeadPetController extends PetController {
  @override
  PetState build() => PetState.initial().copyWith(health: 0.0, isAlive: false);
}
