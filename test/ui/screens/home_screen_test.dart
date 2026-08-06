import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamagotchi/l10n/app_localizations.dart';
import 'package:tamagotchi/models/pet_state.dart';
import 'package:tamagotchi/providers/menu_provider.dart';
import 'package:tamagotchi/providers/pet_controller.dart';
import 'package:tamagotchi/ui/screens/home_screen.dart';

/// Estado con salud reducida, para poder observar el efecto de la medicina
/// (con salud al máximo el incremento no seria observable).
class _SickPetController extends PetController {
  @override
  PetState build() => PetState.initial().copyWith(health: 50.0);
}

void main() {
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  Future<void> pumpHomeScreen(
    WidgetTester tester, {
    List<Override> overrides = const [],
  }) async {
    if (overrides.isNotEmpty) {
      container = ProviderContainer(overrides: overrides);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [Locale('en'), Locale('es'), Locale('ja')],
          home: HomeScreen(),
        ),
      ),
    );
  }

  /// Pulsa el botón A las veces necesarias para abrir el menú (si estaba
  /// oculto) y dejar seleccionado el item en el índice [index], partiendo de
  /// un menú recién construido (oculto, índice 0).
  Future<void> openMenuAt(WidgetTester tester, int index) async {
    for (var i = 0; i <= index; i++) {
      await tester.tap(find.text('A'));
      await tester.pump();
    }
  }

  group('HomeScreen', () {
    testWidgets('muestra los tres botones fisicos A, B y C', (tester) async {
      await pumpHomeScreen(tester);

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('boton A muestra el menu si estaba oculto', (tester) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.text('A'));
      await tester.pump();

      final state = container.read(menuProvider);
      expect(state.isVisible, true);
      expect(state.selectedIndex, 0);
    });

    testWidgets(
      'boton A avanza la seleccion cuando el menu ya esta visible',
      (tester) async {
        await pumpHomeScreen(tester);

        await openMenuAt(tester, 1);

        final state = container.read(menuProvider);
        expect(state.isVisible, true);
        expect(state.currentItem, MenuItem.light);
      },
    );

    testWidgets('boton C oculta el menu', (tester) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.text('A'));
      await tester.pump();
      await tester.tap(find.text('C'));
      await tester.pump();

      expect(container.read(menuProvider).isVisible, false);
    });

    testWidgets('boton B sin menu visible no hace nada', (tester) async {
      await pumpHomeScreen(tester);
      final before = container.read(petControllerProvider);

      await tester.tap(find.text('B'));
      await tester.pump();

      expect(container.read(menuProvider).isVisible, false);
      expect(container.read(petControllerProvider), before);
    });

    testWidgets(
      'boton B con Comida seleccionada oculta el menu',
      (tester) async {
        await pumpHomeScreen(tester);

        await openMenuAt(tester, 0);
        expect(container.read(menuProvider).currentItem, MenuItem.food);

        await tester.tap(find.text('B'));
        await tester.pump();

        expect(container.read(menuProvider).isVisible, false);
      },
    );

    testWidgets(
      'boton B con Luz seleccionada alterna isLightOn y oculta el menu',
      (tester) async {
        await pumpHomeScreen(tester);
        final lightBefore = container.read(petControllerProvider).isLightOn;

        await openMenuAt(tester, 1);
        expect(container.read(menuProvider).currentItem, MenuItem.light);

        await tester.tap(find.text('B'));
        await tester.pump();

        expect(container.read(petControllerProvider).isLightOn, !lightBefore);
        expect(container.read(menuProvider).isVisible, false);
      },
    );

    testWidgets(
      'boton B con Jugar seleccionada disminuye el hambre y oculta el menu',
      (tester) async {
        await pumpHomeScreen(tester);
        final hungerBefore = container.read(petControllerProvider).hunger;

        await openMenuAt(tester, 2);
        expect(container.read(menuProvider).currentItem, MenuItem.play);

        await tester.tap(find.text('B'));
        await tester.pump();

        expect(
          container.read(petControllerProvider).hunger,
          lessThan(hungerBefore),
        );
        expect(container.read(menuProvider).isVisible, false);
      },
    );

    testWidgets(
      'boton B con Medicina seleccionada aumenta la salud y oculta el menu',
      (tester) async {
        await pumpHomeScreen(
          tester,
          overrides: [
            petControllerProvider.overrideWith(() => _SickPetController()),
          ],
        );

        await openMenuAt(tester, 3);
        expect(container.read(menuProvider).currentItem, MenuItem.medicine);

        await tester.tap(find.text('B'));
        await tester.pump();

        expect(container.read(petControllerProvider).health, greaterThan(50.0));
        expect(container.read(menuProvider).isVisible, false);
      },
    );

    testWidgets(
      'boton B con Estado seleccionada solo oculta el menu (sin accion aun)',
      (tester) async {
        await pumpHomeScreen(tester);
        final before = container.read(petControllerProvider);

        await openMenuAt(tester, 4);
        expect(container.read(menuProvider).currentItem, MenuItem.status);

        await tester.tap(find.text('B'));
        await tester.pump();

        expect(container.read(petControllerProvider), before);
        expect(container.read(menuProvider).isVisible, false);
      },
    );

    testWidgets(
      'boton B con Juego seleccionada solo oculta el menu (sin accion aun)',
      (tester) async {
        await pumpHomeScreen(tester);
        final before = container.read(petControllerProvider);

        await openMenuAt(tester, 5);
        expect(container.read(menuProvider).currentItem, MenuItem.game);

        await tester.tap(find.text('B'));
        await tester.pump();

        expect(container.read(petControllerProvider), before);
        expect(container.read(menuProvider).isVisible, false);
      },
    );
  });
}
