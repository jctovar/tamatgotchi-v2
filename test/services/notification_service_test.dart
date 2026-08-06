import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/l10n/app_localizations_es.dart';
import 'package:tamagotchi/models/pet_state.dart';
import 'package:tamagotchi/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final calls = <MethodCall>[];
  final l10n = AppLocalizationsEs();

  PetState stateWith({
    double hunger = 100.0,
    double health = 100.0,
    bool isAlive = true,
  }) {
    return PetState.initial().copyWith(
      hunger: hunger,
      health: health,
      isAlive: isAlive,
    );
  }

  setUpAll(() {
    // Fuerza una plataforma determinista: sin esto, `defaultTargetPlatform`
    // resuelve segun el SO donde corren los tests y el plugin podria
    // enrutar a una implementacion distinta (p. ej. macOS) en cada maquina.
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  });

  tearDownAll(() {
    debugDefaultTargetPlatformOverride = null;
  });

  setUp(() async {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      calls.add(call);
      if (call.method == 'initialize') return true;
      return null;
    });
    // `init()` solo llama al plugin la primera vez que corre en todo el
    // proceso de test (usa una bandera estatica interna); las llamadas que
    // genere aqui no son parte de lo que cada test quiere verificar.
    await NotificationService.init();
    calls.clear();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('NotificationService.scheduleWarnings', () {
    test('cancela los avisos previos antes de evaluar el estado', () async {
      await NotificationService.scheduleWarnings(stateWith(), l10n);

      expect(calls.first.method, 'cancelAll');
    });

    test('no programa avisos si la mascota esta muerta', () async {
      await NotificationService.scheduleWarnings(
        stateWith(isAlive: false, hunger: 5, health: 5),
        l10n,
      );

      expect(calls.map((c) => c.method), ['cancelAll']);
    });

    test(
      'no programa avisos si las estadisticas superan los umbrales',
      () async {
        await NotificationService.scheduleWarnings(
          stateWith(hunger: 80, health: 80),
          l10n,
        );

        expect(calls.map((c) => c.method), ['cancelAll']);
      },
    );

    test('programa aviso de hambre cuando la saciedad cae por debajo del '
        'umbral', () async {
      await NotificationService.scheduleWarnings(
        stateWith(hunger: 20, health: 80),
        l10n,
      );

      expect(calls.map((c) => c.method), ['cancelAll', 'zonedSchedule']);
      final args = calls.last.arguments as Map;
      expect(args['id'], 1);
      expect(args['body'], contains('hambre'));
    });

    test('programa aviso de enfermedad cuando la salud cae por debajo del '
        'umbral', () async {
      await NotificationService.scheduleWarnings(
        stateWith(hunger: 80, health: 10),
        l10n,
      );

      expect(calls.map((c) => c.method), ['cancelAll', 'zonedSchedule']);
      final args = calls.last.arguments as Map;
      expect(args['id'], 2);
      expect(args['body'], contains('enferma'));
    });

    test('programa ambos avisos cuando hambre y salud estan por debajo de '
        'sus umbrales', () async {
      await NotificationService.scheduleWarnings(
        stateWith(hunger: 10, health: 10),
        l10n,
      );

      final scheduled = calls.where((c) => c.method == 'zonedSchedule');
      expect(scheduled.length, 2);
      expect(
        scheduled.map((c) => (c.arguments as Map)['id']),
        containsAll(<int>[1, 2]),
      );
    });

    test(
      'no programa aviso de hambre justo en el umbral (comparacion '
      'estricta)',
      () async {
        await NotificationService.scheduleWarnings(
          stateWith(hunger: 40, health: 80),
          l10n,
        );

        expect(calls.map((c) => c.method), ['cancelAll']);
      },
    );
  });

  group('NotificationService.cancelAll', () {
    test('invoca cancelAll directamente en el plugin', () async {
      await NotificationService.cancelAll();

      expect(calls.single.method, 'cancelAll');
    });
  });
}
