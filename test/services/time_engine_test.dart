// test/services/time_engine_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/pet_state.dart';
import 'package:tamagotchi/services/time_engine.dart';
import 'package:tamagotchi/utils/constants.dart';

void main() {
  group('TimeEngine', () {
    test('applies decay for 1 hour offline', () {
      final now = DateTime(2024, 1, 1, 12, 0);
      final state = PetState.initial().copyWith(
        lastUpdated: DateTime(2024, 1, 1, 11, 0),
      );

      final result = TimeEngine.applyDecay(state, now);

      expect(result.hunger, 100.0 - Constants.hungerDecayPerHour);
      expect(result.happiness, 100.0 - Constants.happinessDecayPerHour);
      expect(result.health, 100.0 - Constants.healthDecayPerHour);
    });

    test('caps offline time at 24 hours', () {
      final now = DateTime(2024, 1, 5, 12, 0);
      final state = PetState.initial().copyWith(
        lastUpdated: DateTime(2024, 1, 1, 12, 0),
      );

      final result = TimeEngine.applyDecay(state, now);

      final expectedHunger =
          (100.0 - Constants.hungerDecayPerHour * 24).clamp(0.0, 100.0);
      expect(result.hunger, expectedHunger);
    });

    test('pet dies when health reaches 0', () {
      final now = DateTime(2024, 1, 2, 12, 0);
      final state = PetState.initial().copyWith(
        health: 10.0,
        lastUpdated: DateTime(2024, 1, 1, 12, 0),
      );

      final result = TimeEngine.applyDecay(state, now);

      expect(result.isAlive, false);
      expect(result.health, 0.0);
    });

    test('does not decay while sleeping', () {
      final now = DateTime(2024, 1, 1, 14, 0);
      final state = PetState.initial().copyWith(
        isSleeping: true,
        lastUpdated: DateTime(2024, 1, 1, 12, 0),
      );

      final result = TimeEngine.applyDecay(state, now);

      expect(result.hunger, 100.0);
    });

    test('updates lastUpdated to now', () {
      final now = DateTime(2024, 1, 1, 15, 0);
      final state = PetState.initial().copyWith(
        lastUpdated: DateTime(2024, 1, 1, 12, 0),
      );

      final result = TimeEngine.applyDecay(state, now);

      expect(result.lastUpdated, now);
    });
  });
}
