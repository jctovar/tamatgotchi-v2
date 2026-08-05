// lib/services/audio_service.dart
/// Servicio de efectos de sonido de la mascota.
///
/// Este archivo contiene [AudioService], que reproduce un efecto de sonido corto
/// cada vez que el usuario realiza una acción (alimentar, jugar, limpiar, etc.).
/// Es un efecto secundario de salida dentro de la arquitectura unidireccional:
/// `PetController` lo invoca tras cada acción, pero el audio nunca modifica el
/// estado de la mascota.
///
/// El audio se trata como "mejor esfuerzo" (best-effort): si por cualquier razón
/// no puede reproducirse (plataforma sin audio, entorno de pruebas sin binding),
/// se ignora silenciosamente para no interrumpir la lógica del juego.
library;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../models/pet_action.dart';

/// Reproducción de efectos de sonido asociados a cada [PetAction].
///
/// Mantiene un único reproductor ([_player]) creado de forma perezosa para no
/// pagar el coste de inicialización hasta que realmente se necesita audio.
abstract final class AudioService {
  /// Reproductor de audio compartido, creado de forma perezosa.
  ///
  /// Es nullable ([AudioPlayer]?) porque solo se construye la primera vez que se
  /// reproduce un sonido; además, construirlo exige que el binding de Flutter
  /// esté inicializado (ver [play]).
  static AudioPlayer? _player;

  /// Reproduce el efecto de sonido correspondiente a [action].
  ///
  /// Por qué la guarda `ServicesBinding.instance`: construir un [AudioPlayer]
  /// dispara internamente un `_create()` asíncrono que necesita el binding de
  /// Flutter (el `GlobalAudioScope` registra un `EventChannel`). En entornos de
  /// prueba sin binding (p. ej. un `ProviderContainer` plano), ese error escapa
  /// de cualquier `try/catch` que rodee a `play()` a través de un hueco asíncrono
  /// y haría fallar el test. Por eso se comprueba el binding antes de construir
  /// el reproductor y se aborta si no existe. En producción, `runApp()` siempre
  /// inicializa el binding.
  static Future<void> play(PetAction action) async {
    // Skip audio when the Flutter binding isn't initialized. Constructing an
    // AudioPlayer triggers an async _create() that requires the binding (the
    // GlobalAudioScope sets up an EventChannel), and the resulting error
    // escapes any try/catch around play() via an async gap. pet_controller_test
    // runs actions inside a plain ProviderContainer with no binding, so we
    // short-circuit before constructing the player. In production, runApp()
    // initializes the binding.
    try {
      ServicesBinding.instance;
    } catch (_) {
      return;
    }
    // Mapa de acción → archivo de sonido (assets). Solo `feed` usa un sonido
    // propio; el resto comparte el mismo "beep".
    final file = switch (action) {
      PetAction.feed => 'audio/eat.wav',
      PetAction.play => 'audio/beep.wav',
      PetAction.clean => 'audio/beep.wav',
      PetAction.medicine => 'audio/beep.wav',
      PetAction.toggleLight => 'audio/beep.wav',
      PetAction.sleep => 'audio/beep.wav',
    };
    try {
      // Crea el reproductor solo la primera vez y lo reutiliza después.
      final player = _player ??= AudioPlayer();
      await player.play(AssetSource(file));
    } catch (_) {
      // Best-effort audio: ignore failures (e.g., no audio platform).
    }
  }
}
