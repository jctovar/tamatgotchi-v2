// lib/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../models/pet_action.dart';

abstract final class AudioService {
  static AudioPlayer? _player;

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
    final file = switch (action) {
      PetAction.feed => 'audio/eat.wav',
      PetAction.play => 'audio/beep.wav',
      PetAction.clean => 'audio/beep.wav',
      PetAction.medicine => 'audio/beep.wav',
      PetAction.toggleLight => 'audio/beep.wav',
      PetAction.sleep => 'audio/beep.wav',
    };
    try {
      final player = _player ??= AudioPlayer();
      await player.play(AssetSource(file));
    } catch (_) {
      // Best-effort audio: ignore failures (e.g., no audio platform).
    }
  }
}
