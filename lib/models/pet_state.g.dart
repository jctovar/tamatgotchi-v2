// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PetState _$PetStateFromJson(Map<String, dynamic> json) => _PetState(
  hunger: (json['hunger'] as num).toDouble(),
  happiness: (json['happiness'] as num).toDouble(),
  health: (json['health'] as num).toDouble(),
  weight: (json['weight'] as num).toDouble(),
  age: const _DurationConverter().fromJson((json['age'] as num).toInt()),
  isAlive: json['isAlive'] as bool,
  isSleeping: json['isSleeping'] as bool,
  isLightOn: json['isLightOn'] as bool,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  stage: $enumDecode(_$PetStageEnumMap, json['stage']),
);

Map<String, dynamic> _$PetStateToJson(_PetState instance) => <String, dynamic>{
  'hunger': instance.hunger,
  'happiness': instance.happiness,
  'health': instance.health,
  'weight': instance.weight,
  'age': const _DurationConverter().toJson(instance.age),
  'isAlive': instance.isAlive,
  'isSleeping': instance.isSleeping,
  'isLightOn': instance.isLightOn,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'stage': _$PetStageEnumMap[instance.stage]!,
};

const _$PetStageEnumMap = {
  PetStage.egg: 'egg',
  PetStage.baby: 'baby',
  PetStage.child: 'child',
  PetStage.teen: 'teen',
  PetStage.adult: 'adult',
};
