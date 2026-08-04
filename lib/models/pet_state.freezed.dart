// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pet_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PetState {

 double get hunger; double get happiness; double get health; double get weight;@_DurationConverter() Duration get age; bool get isAlive; bool get isSleeping; bool get isLightOn; DateTime get lastUpdated; PetStage get stage;
/// Create a copy of PetState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PetStateCopyWith<PetState> get copyWith => _$PetStateCopyWithImpl<PetState>(this as PetState, _$identity);

  /// Serializes this PetState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PetState&&(identical(other.hunger, hunger) || other.hunger == hunger)&&(identical(other.happiness, happiness) || other.happiness == happiness)&&(identical(other.health, health) || other.health == health)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.age, age) || other.age == age)&&(identical(other.isAlive, isAlive) || other.isAlive == isAlive)&&(identical(other.isSleeping, isSleeping) || other.isSleeping == isSleeping)&&(identical(other.isLightOn, isLightOn) || other.isLightOn == isLightOn)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.stage, stage) || other.stage == stage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hunger,happiness,health,weight,age,isAlive,isSleeping,isLightOn,lastUpdated,stage);

@override
String toString() {
  return 'PetState(hunger: $hunger, happiness: $happiness, health: $health, weight: $weight, age: $age, isAlive: $isAlive, isSleeping: $isSleeping, isLightOn: $isLightOn, lastUpdated: $lastUpdated, stage: $stage)';
}


}

/// @nodoc
abstract mixin class $PetStateCopyWith<$Res>  {
  factory $PetStateCopyWith(PetState value, $Res Function(PetState) _then) = _$PetStateCopyWithImpl;
@useResult
$Res call({
 double hunger, double happiness, double health, double weight,@_DurationConverter() Duration age, bool isAlive, bool isSleeping, bool isLightOn, DateTime lastUpdated, PetStage stage
});




}
/// @nodoc
class _$PetStateCopyWithImpl<$Res>
    implements $PetStateCopyWith<$Res> {
  _$PetStateCopyWithImpl(this._self, this._then);

  final PetState _self;
  final $Res Function(PetState) _then;

/// Create a copy of PetState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hunger = null,Object? happiness = null,Object? health = null,Object? weight = null,Object? age = null,Object? isAlive = null,Object? isSleeping = null,Object? isLightOn = null,Object? lastUpdated = null,Object? stage = null,}) {
  return _then(_self.copyWith(
hunger: null == hunger ? _self.hunger : hunger // ignore: cast_nullable_to_non_nullable
as double,happiness: null == happiness ? _self.happiness : happiness // ignore: cast_nullable_to_non_nullable
as double,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as double,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as Duration,isAlive: null == isAlive ? _self.isAlive : isAlive // ignore: cast_nullable_to_non_nullable
as bool,isSleeping: null == isSleeping ? _self.isSleeping : isSleeping // ignore: cast_nullable_to_non_nullable
as bool,isLightOn: null == isLightOn ? _self.isLightOn : isLightOn // ignore: cast_nullable_to_non_nullable
as bool,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as PetStage,
  ));
}

}


/// Adds pattern-matching-related methods to [PetState].
extension PetStatePatterns on PetState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PetState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PetState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PetState value)  $default,){
final _that = this;
switch (_that) {
case _PetState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PetState value)?  $default,){
final _that = this;
switch (_that) {
case _PetState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double hunger,  double happiness,  double health,  double weight, @_DurationConverter()  Duration age,  bool isAlive,  bool isSleeping,  bool isLightOn,  DateTime lastUpdated,  PetStage stage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PetState() when $default != null:
return $default(_that.hunger,_that.happiness,_that.health,_that.weight,_that.age,_that.isAlive,_that.isSleeping,_that.isLightOn,_that.lastUpdated,_that.stage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double hunger,  double happiness,  double health,  double weight, @_DurationConverter()  Duration age,  bool isAlive,  bool isSleeping,  bool isLightOn,  DateTime lastUpdated,  PetStage stage)  $default,) {final _that = this;
switch (_that) {
case _PetState():
return $default(_that.hunger,_that.happiness,_that.health,_that.weight,_that.age,_that.isAlive,_that.isSleeping,_that.isLightOn,_that.lastUpdated,_that.stage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double hunger,  double happiness,  double health,  double weight, @_DurationConverter()  Duration age,  bool isAlive,  bool isSleeping,  bool isLightOn,  DateTime lastUpdated,  PetStage stage)?  $default,) {final _that = this;
switch (_that) {
case _PetState() when $default != null:
return $default(_that.hunger,_that.happiness,_that.health,_that.weight,_that.age,_that.isAlive,_that.isSleeping,_that.isLightOn,_that.lastUpdated,_that.stage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PetState extends PetState {
  const _PetState({required this.hunger, required this.happiness, required this.health, required this.weight, @_DurationConverter() required this.age, required this.isAlive, required this.isSleeping, required this.isLightOn, required this.lastUpdated, required this.stage}): super._();
  factory _PetState.fromJson(Map<String, dynamic> json) => _$PetStateFromJson(json);

@override final  double hunger;
@override final  double happiness;
@override final  double health;
@override final  double weight;
@override@_DurationConverter() final  Duration age;
@override final  bool isAlive;
@override final  bool isSleeping;
@override final  bool isLightOn;
@override final  DateTime lastUpdated;
@override final  PetStage stage;

/// Create a copy of PetState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PetStateCopyWith<_PetState> get copyWith => __$PetStateCopyWithImpl<_PetState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PetStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PetState&&(identical(other.hunger, hunger) || other.hunger == hunger)&&(identical(other.happiness, happiness) || other.happiness == happiness)&&(identical(other.health, health) || other.health == health)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.age, age) || other.age == age)&&(identical(other.isAlive, isAlive) || other.isAlive == isAlive)&&(identical(other.isSleeping, isSleeping) || other.isSleeping == isSleeping)&&(identical(other.isLightOn, isLightOn) || other.isLightOn == isLightOn)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.stage, stage) || other.stage == stage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hunger,happiness,health,weight,age,isAlive,isSleeping,isLightOn,lastUpdated,stage);

@override
String toString() {
  return 'PetState(hunger: $hunger, happiness: $happiness, health: $health, weight: $weight, age: $age, isAlive: $isAlive, isSleeping: $isSleeping, isLightOn: $isLightOn, lastUpdated: $lastUpdated, stage: $stage)';
}


}

/// @nodoc
abstract mixin class _$PetStateCopyWith<$Res> implements $PetStateCopyWith<$Res> {
  factory _$PetStateCopyWith(_PetState value, $Res Function(_PetState) _then) = __$PetStateCopyWithImpl;
@override @useResult
$Res call({
 double hunger, double happiness, double health, double weight,@_DurationConverter() Duration age, bool isAlive, bool isSleeping, bool isLightOn, DateTime lastUpdated, PetStage stage
});




}
/// @nodoc
class __$PetStateCopyWithImpl<$Res>
    implements _$PetStateCopyWith<$Res> {
  __$PetStateCopyWithImpl(this._self, this._then);

  final _PetState _self;
  final $Res Function(_PetState) _then;

/// Create a copy of PetState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hunger = null,Object? happiness = null,Object? health = null,Object? weight = null,Object? age = null,Object? isAlive = null,Object? isSleeping = null,Object? isLightOn = null,Object? lastUpdated = null,Object? stage = null,}) {
  return _then(_PetState(
hunger: null == hunger ? _self.hunger : hunger // ignore: cast_nullable_to_non_nullable
as double,happiness: null == happiness ? _self.happiness : happiness // ignore: cast_nullable_to_non_nullable
as double,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as double,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as Duration,isAlive: null == isAlive ? _self.isAlive : isAlive // ignore: cast_nullable_to_non_nullable
as bool,isSleeping: null == isSleeping ? _self.isSleeping : isSleeping // ignore: cast_nullable_to_non_nullable
as bool,isLightOn: null == isLightOn ? _self.isLightOn : isLightOn // ignore: cast_nullable_to_non_nullable
as bool,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as PetStage,
  ));
}


}

// dart format on
