/// Constantes globales de configuración del juego.
///
/// Este archivo agrupa, en un único punto y como valores inmutables, todos los
/// parámetros de equilibrio y dimensionado del Tamagotchi: resolución de la
/// pantalla LCD, tasas de decaimiento de estadísticas, umbrales de aviso y los
/// tiempos que definen la evolución por edad. Centralizarlos aquí facilita
/// ajustar la dificultad y garantiza que `TimeEngine`, `NotificationService` y
/// el motor Flame usen exactamente los mismos valores.
///
/// Se declara como `abstract final class` para impedir su instanciación y
/// herencia, usándola únicamente como espacio de nombres estático.
library;

/// Espacio de nombres con todas las constantes del juego.
abstract final class Constants {
  /// Ancho lógico de la pantalla LCD, en píxeles (estilo Game Boy).
  static const int lcdWidth = 160;

  /// Alto lógico de la pantalla LCD, en píxeles (estilo Game Boy).
  static const int lcdHeight = 144;

  /// Puntos de saciedad que se pierden por hora (decaimiento del hambre).
  static const double hungerDecayPerHour = 4.0;

  /// Puntos de felicidad que se pierden por hora.
  static const double happinessDecayPerHour = 3.0;

  /// Puntos de salud que se pierden por hora.
  static const double healthDecayPerHour = 1.5;

  /// Umbral de saciedad por debajo del cual se programa un aviso de hambre.
  static const double hungerWarningThreshold = 40.0;

  /// Umbral de salud por debajo del cual se programa un aviso de enfermedad.
  static const double healthWarningThreshold = 30.0;

  /// Máximo de horas de decaimiento aplicadas al reanudar desde segundo plano.
  ///
  /// Las estadísticas solo decaen como mucho las horas indicadas por esta
  /// constante, aunque la edad de la mascota sí avanza por el tiempo total
  /// transcurrido.
  static const int maxOfflineHours = 24;

  /// Edad a la que el huevo eclosiona y pasa a ser bebé.
  static const Duration eggHatchTime = Duration(minutes: 5);

  /// Edad a la que la mascota pasa de bebé a niño.
  static const Duration babyToChild = Duration(hours: 24);

  /// Edad a la que la mascota pasa de niño a adolescente.
  static const Duration childToTeen = Duration(hours: 72);

  /// Edad a la que la mascota pasa de adolescente a adulta.
  static const Duration teenToAdult = Duration(hours: 168);
}
