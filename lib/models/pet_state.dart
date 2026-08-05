/// Modelo de estado inmutable de la mascota virtual (Tamagotchi).
///
/// Este archivo define [PetState], la estructura de datos central de toda la
/// aplicación y la única "fuente de verdad" que Riverpod almacena y distribuye.
/// Dentro de la arquitectura unidireccional, el estado fluye de la siguiente
/// manera:
///
/// 1. La UI (botones físicos A/B/C) invoca acciones del controlador.
/// 2. El controlador (`PetController`) muta este estado mediante `copyWith`.
/// 3. Riverpod propaga el nuevo [PetState] tanto a la UI reactiva como al
///    motor Flame, que lo usa para conducir sus animaciones.
///
/// Se construye con `freezed` para obtener inmutabilidad, igualdad por valor,
/// `copyWith` y serialización JSON (esta última usada por `PersistenceService`
/// para persistir en `SharedPreferences`).
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'pet_stage.dart';

part 'pet_state.freezed.dart';
part 'pet_state.g.dart';

/// Conversor JSON que serializa un [Duration] como un [int] de microsegundos.
///
/// `freezed`/`json_serializable` no serializan [Duration] de forma nativa; este
/// conversor permite que el campo [PetState.age] se guarde y se restaure desde
/// `SharedPreferences` sin pérdida de precisión (usando microsegundos).
class _DurationConverter implements JsonConverter<Duration, int> {
  /// Constructor constante, requerido por `json_serializable`.
  const _DurationConverter();

  /// Reconstruye un [Duration] a partir de su valor en microsegundos [json].
  @override
  Duration fromJson(int json) => Duration(microseconds: json);

  /// Serializa [object] como su cantidad total de microsegundos.
  @override
  int toJson(Duration object) => object.inMicroseconds;
}

/// Estado completo e inmutable de la mascota virtual en un instante dado.
///
/// Concentra toda la información que define a la mascota: sus estadísticas
/// vitales, su edad y etapa evolutiva, y varios interruptores (dormida, luz
/// encendida, viva). Al ser inmutable, cada cambio produce una instancia nueva
/// vía `copyWith`, lo que permite a Riverpod detectar la mutación y notificar a
/// la UI y al motor Flame sin efectos secundarios ocultos.
@freezed
abstract class PetState with _$PetState {
  /// Constructor privado que habilita getters de instancia en una clase
  /// `freezed` (de otro modo solo habría miembros estáticos/de fábrica).
  const PetState._();

  /// Constructor principal por defecto con todos los campos requeridos.
  ///
  /// * [hunger] Saciedad de la mascota (0–100).
  /// * [happiness] Felicidad de la mascota (0–100).
  /// * [health] Salud de la mascota (0–100). Si llega a 0, la mascota muere.
  /// * [weight] Peso en kilogramos; valor derivado de alimentar/jugar.
  /// * [age] Edad acumulada desde el nacimiento; determina la etapa evolutiva.
  /// * [isAlive] Indica si la mascota sigue viva.
  /// * [isSleeping] Indica si duerme (pausa el decaimiento de estadísticas).
  /// * [isLightOn] Indica si la luz de la pantalla está encendida.
  /// * [lastUpdated] Marca de tiempo del último cambio; base del decaimiento.
  /// * [stage] Etapa evolutiva actual (huevo, bebé, niño, adolescente, adulto).
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

  /// Crea el estado inicial de una mascota recién nacida.
  ///
  /// Todas las estadísticas al máximo, peso base de 5.0, edad cero, viva,
  /// despierta, con la luz encendida y en etapa de huevo ([PetStage.egg]).
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

  /// Deserializa un [PetState] desde un mapa [json].
  ///
  /// Generado por `json_serializable`; lo utiliza `PersistenceService.load`
  /// para restaurar el estado guardado al arrancar la aplicación.
  factory PetState.fromJson(Map<String, dynamic> json) =>
      _$PetStateFromJson(json);

  /// Saciedad limitada al rango válido 0–100, pensada para mostrar en la UI.
  double get clampedHunger => hunger.clamp(0.0, 100.0);

  /// Felicidad limitada al rango válido 0–100, pensada para mostrar en la UI.
  double get clampedHappiness => happiness.clamp(0.0, 100.0);

  /// Salud limitada al rango válido 0–100, pensada para mostrar en la UI.
  double get clampedHealth => health.clamp(0.0, 100.0);
}
