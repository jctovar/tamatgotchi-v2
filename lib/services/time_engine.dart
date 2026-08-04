// lib/services/time_engine.dart
import 'dart:math';
import '../models/pet_state.dart';
import '../models/pet_stage.dart';
import '../utils/constants.dart';

abstract final class TimeEngine {
  static PetState applyDecay(PetState state, DateTime now) {
    if (!state.isAlive) return state.copyWith(lastUpdated: now);
    if (state.isSleeping) return state.copyWith(lastUpdated: now);

    final elapsed = now.difference(state.lastUpdated);
    final cappedHours =
        min(elapsed.inMinutes / 60.0, Constants.maxOfflineHours.toDouble());

    if (cappedHours <= 0) return state.copyWith(lastUpdated: now);

    final newHunger =
        (state.hunger - Constants.hungerDecayPerHour * cappedHours)
            .clamp(0.0, 100.0);
    final newHappiness =
        (state.happiness - Constants.happinessDecayPerHour * cappedHours)
            .clamp(0.0, 100.0);
    final newHealth =
        (state.health - Constants.healthDecayPerHour * cappedHours)
            .clamp(0.0, 100.0);

    final isDead = newHealth <= 0;
    final newAge = state.age + Duration(minutes: elapsed.inMinutes);
    final newStage = _calculateStage(newAge);

    return state.copyWith(
      hunger: newHunger,
      happiness: newHappiness,
      health: isDead ? 0.0 : newHealth,
      age: newAge,
      isAlive: !isDead,
      stage: newStage,
      lastUpdated: now,
    );
  }

  static PetStage _calculateStage(Duration age) {
    if (age < Constants.eggHatchTime) return PetStage.egg;
    if (age < Constants.babyToChild) return PetStage.baby;
    if (age < Constants.childToTeen) return PetStage.child;
    if (age < Constants.teenToAdult) return PetStage.teen;
    return PetStage.adult;
  }
}
