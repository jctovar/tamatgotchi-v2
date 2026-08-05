import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamagotchi/lifecycle_observer.dart';
import 'package:tamagotchi/models/pet_state.dart';
import 'package:tamagotchi/providers/pet_controller.dart';
import 'package:tamagotchi/services/notification_service.dart';

/// Estado con hambre y salud bajo los umbrales de aviso, para ejercitar la
/// rama de [AppLifecycleState.paused].
class _LowStatsController extends PetController {
  @override
  PetState build() => PetState.initial().copyWith(hunger: 20.0, health: 10.0);
}

/// Estado con `lastUpdated` en el pasado, para que `applyTimeDecay` produzca
/// un cambio medible al reanudar.
class _StaleController extends PetController {
  @override
  PetState build() => PetState.initial().copyWith(
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const notificationsChannel = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );
  final calls = <MethodCall>[];

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notificationsChannel, (call) async {
      if (call.method == 'initialize') return true;
      return null;
    });
    // Carga la base de datos de zonas horarias una unica vez para todo el
    // archivo; NotificationService._initialized evita que vuelva a correr.
    // El canal 'dexterous.com/flutter/local_notifications' es compartido por
    // todas las implementaciones de plataforma del plugin, asi que mockearlo
    // basta sin necesidad de forzar `defaultTargetPlatform`.
    await NotificationService.init();
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notificationsChannel, null);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notificationsChannel, (call) async {
      calls.add(call);
      if (call.method == 'initialize') return true;
      return null;
    });
  });

  /// Monta un [Consumer] mínimo respaldado por [container] y devuelve el
  /// [WidgetRef] real que produce, para poder construir un [LifecycleObserver]
  /// fuera de un árbol de widgets completo.
  Future<WidgetRef> pumpRef(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    late WidgetRef captured;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) {
            captured = ref;
            return const SizedBox();
          },
        ),
      ),
    );
    return captured;
  }

  testWidgets(
    'al pausar, programa avisos segun el estado actual de la mascota',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          petControllerProvider.overrideWith(() => _LowStatsController()),
        ],
      );
      addTearDown(container.dispose);
      final ref = await pumpRef(tester, container);
      final observer = LifecycleObserver(ref);

      observer.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump();

      expect(calls.map((c) => c.method), contains('cancelAll'));
      expect(calls.map((c) => c.method), contains('zonedSchedule'));
    },
  );

  testWidgets(
    'al pausar con estadisticas altas, solo cancela sin programar avisos',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final ref = await pumpRef(tester, container);
      final observer = LifecycleObserver(ref);

      observer.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump();

      expect(calls.map((c) => c.method), ['cancelAll']);
    },
  );

  testWidgets(
    'al reanudar, cancela avisos y aplica el decaimiento acumulado',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          petControllerProvider.overrideWith(() => _StaleController()),
        ],
      );
      addTearDown(container.dispose);
      final ref = await pumpRef(tester, container);
      final observer = LifecycleObserver(ref);

      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pump();

      expect(calls.map((c) => c.method), contains('cancelAll'));
      expect(calls.any((c) => c.method == 'zonedSchedule'), false);
      final state = container.read(petControllerProvider);
      expect(state.hunger, lessThan(100.0));
    },
  );

  testWidgets(
    'estados sin manejador explicito (inactive) no producen efectos',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final ref = await pumpRef(tester, container);
      final observer = LifecycleObserver(ref);
      final before = container.read(petControllerProvider);

      observer.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await tester.pump();

      expect(calls, isEmpty);
      expect(container.read(petControllerProvider), before);
    },
  );

  testWidgets(
    'register conecta el observador al WidgetsBinding real',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          petControllerProvider.overrideWith(() => _LowStatsController()),
        ],
      );
      addTearDown(container.dispose);
      final ref = await pumpRef(tester, container);
      final observer = LifecycleObserver(ref);

      observer.register();
      addTearDown(observer.dispose);
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.paused,
      );
      await tester.pump();

      expect(calls.map((c) => c.method), contains('cancelAll'));
    },
  );

  testWidgets(
    'dispose desconecta el observador: deja de reaccionar a cambios',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          petControllerProvider.overrideWith(() => _LowStatsController()),
        ],
      );
      addTearDown(container.dispose);
      final ref = await pumpRef(tester, container);
      final observer = LifecycleObserver(ref);

      observer.register();
      observer.dispose();
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.paused,
      );
      await tester.pump();

      expect(calls, isEmpty);
    },
  );
}
