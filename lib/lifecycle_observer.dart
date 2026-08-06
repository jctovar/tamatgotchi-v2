/// Observador del ciclo de vida de la aplicación.
///
/// Este archivo define [LifecycleObserver], el puente entre los eventos del
/// sistema operativo (app en primer/segundo plano) y la lógica del juego. Es el
/// componente que hace posible el decaimiento "offline": cuando la app pasa a
/// segundo plano programa avisos, y cuando vuelve a primer plano aplica el
/// decaimiento del tiempo transcurrido mediante `TimeEngine`.
///
/// En la arquitectura unidireccional actúa como disparador: no muta estado por sí
/// mismo, sino que invoca al controlador (`PetController.applyTimeDecay`) y al
/// servicio de notificaciones.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'l10n/app_localizations_en.dart';
import 'providers/pet_controller.dart';
import 'services/notification_service.dart';

/// Observador que reacciona a los cambios de ciclo de vida de la app.
///
/// Se registra en el [WidgetsBinding] y reacciona en
/// [didChangeAppLifecycleState]. Necesita una referencia [ref] a Riverpod para
/// leer y notificar al controlador de la mascota.
class LifecycleObserver with WidgetsBindingObserver {
  /// Referencia a Riverpod para interactuar con los proveedores.
  final WidgetRef ref;

  /// Últimas cadenas localizadas, empujadas por la UI al cambiar el idioma.
  AppLocalizations _l10n = AppLocalizationsEn();

  /// Crea el observador con la referencia [ref] a Riverpod.
  LifecycleObserver(this.ref);

  /// Actualiza las cadenas localizadas usadas al programar avisos.
  void updateL10n(AppLocalizations l10n) {
    _l10n = l10n;
  }

  /// Registra este observador en el [WidgetsBinding] para recibir eventos.
  void register() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Desregistra este observador del [WidgetsBinding].
  ///
  /// Debe llamarse al disponer el widget que lo creó para evitar fugas.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Gestiona las transiciones de ciclo de vida de la aplicación.
  ///
  /// * Al pausar ([AppLifecycleState.paused]): programa avisos de hambre y/o
  ///   enfermedad según el estado actual de la mascota.
  /// * Al reanudar ([AppLifecycleState.resumed]): cancela los avisos y aplica el
  ///   decaimiento acumulado durante la ausencia.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        final petState = ref.read(petControllerProvider);
        NotificationService.scheduleWarnings(petState, _l10n);
      case AppLifecycleState.resumed:
        NotificationService.cancelAll();
        ref.read(petControllerProvider.notifier).applyTimeDecay();
      default:
        break;
    }
  }
}
