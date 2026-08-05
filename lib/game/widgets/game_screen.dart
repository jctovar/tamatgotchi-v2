/// Widget puente entre Riverpod y el motor Flame.
///
/// Este archivo define [GameScreen], el widget que aloja el [GameWidget] de Flame
/// y conecta la arquitectura unidireccional: escucha los cambios de estado y los
/// eventos de acción en Riverpod, y los traslada al motor [TamagotchiGame]. Es el
/// único punto donde la capa reactiva de Flutter y el motor de juego se tocan.
///
/// Dirección del flujo que implementa:
///
/// * `Riverpod → Flame` (estado): cambios de [petControllerProvider] →
///   [TamagotchiGame.onStateChanged].
/// * `Riverpod → Flame` (eventos): emisiones de [flameActionProvider] →
///   [TamagotchiGame.onAction].
library;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/flame_action_provider.dart';
import '../../providers/pet_controller.dart';
import '../../providers/menu_provider.dart';
import '../../l10n/app_localizations.dart';
import '../tamagotchi_game.dart';

/// Widget con estado que crea y mantiene la instancia del juego Flame.
///
/// Es un [ConsumerStatefulWidget] para poder usar `ref` (Riverpod) tanto en la
/// creación inicial del juego como en las escuchas de cambios.
class GameScreen extends ConsumerStatefulWidget {
  /// Crea el widget que aloja la pantalla de juego.
  const GameScreen({super.key});

  /// Crea el estado asociado a este widget.
  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

/// Estado de [GameScreen]: posee el juego y lo sincroniza con Riverpod.
class _GameScreenState extends ConsumerState<GameScreen> {
  /// Instancia del motor Flame, creada una sola vez en [initState].
  late TamagotchiGame _game;

  /// Inicializa el juego con el estado actual de la mascota.
  ///
  /// Se lee el estado de [petControllerProvider] y se pasa como estado inicial al
  /// motor. El juego se crea aquí (y no en `build`) para que la instancia sea
  /// estable entre reconstrucciones del widget.
  @override
  void initState() {
    super.initState();
    final initialState = ref.read(petControllerProvider);
    final initialMenuState = ref.read(menuProvider);
    _game = TamagotchiGame(
      initialState: initialState,
      initialMenuState: initialMenuState,
    );
  }

  /// Empuja las etiquetas del menú localizadas al motor.
  ///
  /// Se ejecuta una vez al montar el widget y de nuevo si cambian las
  /// dependencias de [BuildContext] (por ejemplo, si cambia el locale del
  /// sistema en caliente). No se hace en [build] para no reenviar las
  /// etiquetas en cada reconstrucción no relacionada con el idioma.
  ///
  /// `didChangeDependencies` se ejecuta de forma síncrona durante el montaje
  /// inicial del widget, antes de que exista el [GameWidget] y, por tanto,
  /// antes de que `TamagotchiGame.onLoad` (asíncrono) haya podido inicializar
  /// el overlay del menú. Por eso se espera a [TamagotchiGame.loaded] —el
  /// future de Flame que se resuelve cuando termina `onLoad`— antes de llamar
  /// a [TamagotchiGame.onLocaleChanged]; llamarlo antes provocaría un
  /// `LateInitializationError` sobre el campo `late` del overlay.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.menuFood,
      l10n.menuLight,
      l10n.menuPlay,
      l10n.menuMedicine,
      l10n.menuStatus,
      l10n.menuGame,
    ];
    _game.loaded.then((_) {
      if (mounted) {
        _game.onLocaleChanged(labels);
      }
    });
  }

  /// Construye el [GameWidget] y registra las escuchas de Riverpod.
  ///
  /// Las llamadas a `ref.listen` se realizan dentro de `build` (patrón habitual de
  /// Riverpod): cada vez que cambia el estado o se emite una acción, se notifica al
  /// motor para que actualice la animación.
  @override
  Widget build(BuildContext context) {
    // Sincroniza los cambios de estado de la mascota con el motor.
    ref.listen(petControllerProvider, (prev, next) {
      _game.onStateChanged(next);
    });

    // Traslada los eventos de acción emitidos por el controlador al motor.
    ref.listen(flameActionProvider, (prev, next) {
      final action = next.lastAction;
      if (action != null) {
        _game.onAction(action);
      }
    });

    // Sincroniza la visibilidad/selección del menú con el motor.
    ref.listen(menuProvider, (prev, next) {
      _game.onMenuChanged(next);
    });

    return GameWidget(game: _game);
  }
}
