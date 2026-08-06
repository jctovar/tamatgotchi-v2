/// Pantalla principal de la aplicación.
///
/// Este archivo define [HomeScreen], la única pantalla funcional de la app. Muestra
/// la carcasa del Tamagotchi ([TamagotchiShell]) y traduce las pulsaciones de los
/// botones físicos A/B/C en acciones sobre los proveedores de Riverpod. Es el punto
/// de entrada "UI → Riverpod" de la arquitectura unidireccional: la UI nunca muta
/// estado directamente, sino que invoca a los controladores.
///
/// También registra un [LifecycleObserver] para aplicar el decaimiento offline al
/// reanudar la app desde segundo plano.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lifecycle_observer.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/menu_provider.dart';
import '../../providers/pet_controller.dart';
import '../widgets/tamagotchi_shell.dart';

/// Pantalla principal que aloja la carcasa del Tamagotchi.
///
/// Es un [ConsumerStatefulWidget] porque necesita una referencia [ref] a Riverpod
/// y un observador de ciclo de vida con el mismo tiempo de vida que la pantalla.
class HomeScreen extends ConsumerStatefulWidget {
  /// Crea la pantalla principal.
  const HomeScreen({super.key});

  /// Crea el estado asociado a esta pantalla.
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

/// Estado de [HomeScreen]: gestiona el observador y los manejadores de botones.
class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Observador del ciclo de vida de la app.
  late final LifecycleObserver _observer;

  /// Registra el observador de ciclo de vida al iniciar la pantalla.
  @override
  void initState() {
    super.initState();
    _observer = LifecycleObserver(ref);
    _observer.register();
  }

  /// Desregistra el observador al disponer la pantalla, evitando fugas.
  @override
  void dispose() {
    _observer.dispose();
    super.dispose();
  }

  /// Empuja las cadenas localizadas al observador de ciclo de vida.
  ///
  /// Se ejecuta al montar la pantalla y de nuevo si cambia el idioma del sistema,
  /// para que los avisos de notificación se programen en el idioma activo.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _observer.updateL10n(AppLocalizations.of(context)!);
  }

  /// Construye la interfaz centrando la carcasa del Tamagotchi.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TamagotchiShell(
          onButtonA: _handleA,
          onButtonB: _handleB,
          onButtonC: _handleC,
        ),
      ),
    );
  }

  /// Manejador del botón A: abre el menú o avanza a la siguiente opción.
  ///
  /// Si el menú está oculto, lo muestra; si ya está visible, pasa a la siguiente
  /// opción de forma circular.
  void _handleA() {
    final menu = ref.read(menuProvider);
    if (!menu.isVisible) {
      ref.read(menuProvider.notifier).toggle();
    } else {
      ref.read(menuProvider.notifier).next();
    }
  }

  /// Manejador del botón B: ejecuta la opción seleccionada del menú.
  ///
  /// Si el menú está oculto no hace nada. En caso contrario, traduce la opción
  /// actual a una acción del controlador de la mascota y oculta el menú. Las
  /// opciones `status` y `game` aún no tienen acción asociada.
  void _handleB() {
    final menu = ref.read(menuProvider);
    if (!menu.isVisible) return;

    final controller = ref.read(petControllerProvider.notifier);
    switch (menu.currentItem) {
      case MenuItem.food:
        controller.feed();
      case MenuItem.light:
        controller.toggleLight();
      case MenuItem.play:
        controller.play();
      case MenuItem.medicine:
        controller.useMedicine();
      case MenuItem.status:
        break;
      case MenuItem.game:
        break;
    }
    ref.read(menuProvider.notifier).hide();
  }

  /// Manejador del botón C: cancela y oculta el menú.
  void _handleC() {
    ref.read(menuProvider.notifier).hide();
  }
}
