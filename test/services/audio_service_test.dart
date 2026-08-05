import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/models/pet_action.dart';
import 'package:tamagotchi/services/audio_service.dart';

void main() {
  // A diferencia de pet_controller_test.dart (que deliberadamente NO
  // inicializa el binding para ejercitar el atajo de "sin binding" de
  // AudioService), aqui si lo inicializamos para cubrir la rama en la que
  // realmente se intenta reproducir el sonido.
  TestWidgetsFlutterBinding.ensureInitialized();

  const globalChannel = MethodChannel('xyz.luan/audioplayers.global');
  const playerChannel = MethodChannel('xyz.luan/audioplayers');

  setUpAll(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(globalChannel, (call) async => null);
    messenger.setMockMethodCallHandler(playerChannel, (call) async => null);
    messenger.setMockStreamHandler(
      const EventChannel('xyz.luan/audioplayers.global/events'),
      MockStreamHandler.inline(onListen: (_, __) {}),
    );
  });

  group('AudioService.play', () {
    for (final action in PetAction.values) {
      test(
        'no lanza excepcion para $action aunque no haya plataforma de audio '
        '(best-effort)',
        () async {
          await expectLater(AudioService.play(action), completes);
        },
      );
    }

    test('puede llamarse repetidamente reutilizando el mismo reproductor',
        () async {
      await expectLater(AudioService.play(PetAction.feed), completes);
      await expectLater(AudioService.play(PetAction.play), completes);
    });
  });
}
