import 'package:freezed_annotation/freezed_annotation.dart';
import 'pet_stage.dart';

part 'pet_state.freezed.dart';
part 'pet_state.g.dart';

class _DurationConverter implements JsonConverter<Duration, int> {
  const _DurationConverter();

  @override
  Duration fromJson(int json) => Duration(microseconds: json);

  @override
  int toJson(Duration object) => object.inMicroseconds;
}

@freezed
abstract class PetState with _$PetState {
  const PetState._();

  const factory PetState({
    required double hunger,
    required double happiness,
    required double health,
    required double weight,
    @_DurationConverter() required Duration age,
    required bool isAlive,
    required bool isSleeping,
    required bool isLightOn,
    required DateTime lastUpdated,
    required PetStage stage,
  }) = _PetState;

  factory PetState.initial() => PetState(
        hunger: 100.0,
        happiness: 100.0,
        health: 100.0,
        weight: 5.0,
        age: Duration.zero,
        isAlive: true,
        isSleeping: false,
        isLightOn: true,
        lastUpdated: DateTime.now(),
        stage: PetStage.egg,
      );

  factory PetState.fromJson(Map<String, dynamic> json) =>
      _$PetStateFromJson(json);

  double get clampedHunger => hunger.clamp(0.0, 100.0);
  double get clampedHappiness => happiness.clamp(0.0, 100.0);
  double get clampedHealth => health.clamp(0.0, 100.0);
}
