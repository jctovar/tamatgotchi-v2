// lib/services/time_engine.dart
/// Motor de tiempo: cálculo del decaimiento de estadísticas por tiempo transcurrido.
///
/// Este archivo contiene [TimeEngine], el componente que traduce el paso del
/// tiempo en cambios de estado. Es la pieza clave para que la mascota "viva"
/// aunque la aplicación esté cerrada: cuando la app vuelve a primer plano, se
/// compara la marca [PetState.lastUpdated] con la hora actual y se aplica el
/// decaimiento acumulado durante la ausencia.
///
/// En la arquitectura unidireccional, [TimeEngine] es una función pura: recibe
/// un [PetState] y una fecha, y devuelve un [PetState] nuevo sin efectos
/// secundarios ni mutaciones. Quien lo invoca (`PetController`) es responsable
/// de persistir el resultado.
library;

import 'dart:math';
import '../models/pet_state.dart';
import '../models/pet_stage.dart';
import '../utils/constants.dart';

/// Calculadora pura del decaimiento temporal y de la evolución por edad.
///
/// No guarda estado interno; todos sus métodos son estáticos y deterministas.
/// Se invoca en dos momentos:
///
/// * Al arrancar o reanudar la app, para aplicar el tiempo transcurrido en
///   segundo plano (`PetController._loadState` y `applyTimeDecay`).
/// * De forma puntual tras cualquier acción que deba recalcular la edad/etapa.
abstract final class TimeEngine {
  /// Aplica el decaimiento de estadísticas acumulado entre [PetState.lastUpdated]
  /// y [now], devolviendo un nuevo [PetState].
  ///
  /// Reglas que implementa:
  ///
  /// * Si la mascota está muerta o dormida, no decae ninguna estadística; solo
  ///   se actualiza [PetState.lastUpdated] para no "acumular" tiempo que luego
  ///   se aplicaría erróneamente al despertar o revivir.
  /// * El decaimiento de saciedad, felicidad y salud es lineal por hora, usando
  ///   las tasas de [Constants], y se limita al rango 0–100.
  /// * El tiempo de decaimiento se limita a [Constants.maxOfflineHours] horas,
  ///   pero la edad ([PetState.age]) avanza por el tiempo total transcurrido.
  /// * Si la salud resultante llega a 0, la mascota muere ([PetState.isAlive]
  ///   pasa a `false` y la salud se fija en 0).
  /// * La etapa evolutiva se recalcula a partir de la nueva edad.
  static PetState applyDecay(PetState state, DateTime now) {
    // Mascota muerta: ya no decae. Solo adelantamos la marca de tiempo para que
    // una futura lectura no intente aplicar decaimiento acumulado de nuevo.
    if (!state.isAlive) return state.copyWith(lastUpdated: now);
    // Mascota dormida: el sueño pausa el decaimiento. Igual que arriba, solo
    // actualizamos la marca de tiempo; el decaimiento se reanudará al despertar.
    if (state.isSleeping) return state.copyWith(lastUpdated: now);

    // Tiempo total transcurrido desde la última actualización.
    final elapsed = now.difference(state.lastUpdated);
    // Limitamos el decaimiento a un máximo de horas (p. ej. 24 h) para que una
    // ausencia muy larga no aniquile instantáneamente todas las estadísticas.
    // Nota: este límite solo afecta al decaimiento, NO a la edad (ver abajo).
    final cappedHours =
        min(elapsed.inMinutes / 60.0, Constants.maxOfflineHours.toDouble());

    // Sin tiempo transcurrido (o negativo): nada que decaer.
    if (cappedHours <= 0) return state.copyWith(lastUpdated: now);

    // Decaimiento lineal por hora, limitado al rango válido 0–100.
    final newHunger =
        (state.hunger - Constants.hungerDecayPerHour * cappedHours)
            .clamp(0.0, 100.0);
    final newHappiness =
        (state.happiness - Constants.happinessDecayPerHour * cappedHours)
            .clamp(0.0, 100.0);
    final newHealth =
        (state.health - Constants.healthDecayPerHour * cappedHours)
            .clamp(0.0, 100.0);

    // Comprobación de muerte: salud agotada.
    final isDead = newHealth <= 0;
    // La edad avanza por el tiempo TOTAL transcurrido, sin el límite de 24 h.
    // Así la mascota sigue evolucionando aunque el decaimiento esté acotado.
    final newAge = state.age + Duration(minutes: elapsed.inMinutes);
    final newStage = _calculateStage(newAge);

    return state.copyWith(
      hunger: newHunger,
      happiness: newHappiness,
      // Si ha muerto, forzamos la salud exactamente a 0.
      health: isDead ? 0.0 : newHealth,
      age: newAge,
      isAlive: !isDead,
      stage: newStage,
      lastUpdated: now,
    );
  }

  /// Determina la etapa evolutiva ([PetStage]) correspondiente a una [age].
  ///
  /// Compara la edad contra los umbrales definidos en [Constants] y devuelve la
  /// etapa más avanzada que la mascota ya ha alcanzado.
  static PetStage _calculateStage(Duration age) {
    if (age < Constants.eggHatchTime) return PetStage.egg;
    if (age < Constants.babyToChild) return PetStage.baby;
    if (age < Constants.childToTeen) return PetStage.child;
    if (age < Constants.teenToAdult) return PetStage.teen;
    return PetStage.adult;
  }
}
