import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/pet_state.dart';
import 'package:tamagotchi/models/pet_stage.dart';

void main() {
  group('PetState', () {
    test('creates default state with full stats', () {
      final state = PetState.initial();
      expect(state.hunger, 100.0);
      expect(state.happiness, 100.0);
      expect(state.health, 100.0);
      expect(state.weight, 5.0);
      expect(state.age, Duration.zero);
      expect(state.isAlive, true);
      expect(state.isSleeping, false);
      expect(state.isLightOn, true);
      expect(state.stage, PetStage.egg);
    });

    test('copyWith preserves unchanged fields', () {
      final state = PetState.initial();
      final updated = state.copyWith(hunger: 50.0);
      expect(updated.hunger, 50.0);
      expect(updated.happiness, 100.0);
      expect(updated.isAlive, true);
    });

    test('stats clamp between 0 and 100', () {
      final state = PetState.initial().copyWith(hunger: 150.0);
      expect(state.clampedHunger, 100.0);
    });

    test('clampedHappiness clamps between 0 and 100', () {
      final over = PetState.initial().copyWith(happiness: 150.0);
      final under = PetState.initial().copyWith(happiness: -10.0);
      expect(over.clampedHappiness, 100.0);
      expect(under.clampedHappiness, 0.0);
    });

    test('clampedHealth clamps between 0 and 100', () {
      final over = PetState.initial().copyWith(health: 150.0);
      final under = PetState.initial().copyWith(health: -10.0);
      expect(over.clampedHealth, 100.0);
      expect(under.clampedHealth, 0.0);
    });

    test('toJson/fromJson roundtrip preserves all fields', () {
      final state = PetState.initial().copyWith(age: const Duration(hours: 3));
      final json = state.toJson();
      final restored = PetState.fromJson(json);
      expect(restored.age, const Duration(hours: 3));
      expect(restored.hunger, state.hunger);
      expect(restored.stage, state.stage);
    });
  });
}
