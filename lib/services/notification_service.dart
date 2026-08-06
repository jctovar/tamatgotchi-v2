/// Servicio de notificaciones locales para avisos de la mascota.
///
/// Este archivo contiene [NotificationService], que programa notificaciones
/// locales cuando la mascota queda en segundo plano con necesidades críticas
/// (hambre o enfermedad). Es el mecanismo que "llama la atención" del usuario
/// mientras la app no está visible.
///
/// En la arquitectura unidireccional, este servicio es un efecto secundario de
/// salida: `LifecycleObserver` lo invoca al pausar/reanudar la aplicación, y él
/// solo programa o cancela avisos, sin tocar el estado de la mascota.
library;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../l10n/app_localizations.dart';
import '../models/pet_state.dart';
import '../utils/constants.dart';

/// Programación y cancelación de notificaciones locales de aviso.
///
/// Envuelve una única instancia del plugin ([_plugin]) y garantiza que solo se
/// inicialice una vez mediante la bandera [_initialized].
abstract final class NotificationService {
  /// Instancia única del plugin de notificaciones locales.
  static final _plugin = FlutterLocalNotificationsPlugin();

  /// Bandera para evitar inicializar el plugin más de una vez.
  static bool _initialized = false;

  /// Inicializa el plugin de notificaciones y la base de datos de zonas horarias.
  ///
  /// `tz_data.initializeTimeZones()` es obligatorio: el paquete `timezone` no
  /// carga la información de zonas horarias automáticamente, y sin ella no se
  /// puede construir el [tz.TZDateTime] que requiere `zonedSchedule`. Se llama
  /// una sola vez desde `main()` antes de `runApp`.
  static Future<void> init() async {
    if (_initialized) return;
    // Carga la base de datos de zonas horarias necesaria para TZDateTime.
    tz_data.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  /// Programa avisos en función de las necesidades actuales de [state].
  ///
  /// Cancela primero cualquier aviso previo para no duplicar notificaciones y, si
  /// la mascota sigue viva, programa un recordatorio de hambre y/o de enfermedad
  /// según los umbrales definidos en [Constants]. Los textos del aviso se toman
  /// de [l10n] para respetar el idioma activo de la aplicación.
  static Future<void> scheduleWarnings(
    PetState state,
    AppLocalizations l10n,
  ) async {
    await cancelAll();
    if (!state.isAlive) return;

    // Aviso de hambre si la saciedad cae por debajo del umbral.
    if (state.hunger < Constants.hungerWarningThreshold) {
      await _schedule(
        id: 1,
        title: l10n.appTitle,
        body: l10n.notificationHungerBody,
        delay: const Duration(minutes: 30),
      );
    }

    // Aviso de enfermedad si la salud cae por debajo del umbral.
    if (state.health < Constants.healthWarningThreshold) {
      await _schedule(
        id: 2,
        title: l10n.appTitle,
        body: l10n.notificationSickBody,
        delay: const Duration(minutes: 15),
      );
    }
  }

  /// Programa una única notificación con el [id], [title], [body] y [delay] dados.
  ///
  /// Se usa `zonedSchedule` con un [tz.TZDateTime] porque la API 17.x de
  /// `flutter_local_notifications` exige una fecha con zona horaria para poder
  /// disparar el aviso en el instante local correcto. El parámetro
  /// `uiLocalNotificationDateInterpretation` es obligatorio en esta versión para
  /// indicar cómo interpretar la fecha (aquí, como hora absoluta).
  static Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
    // Fecha objetivo: ahora (en la zona horaria local) más el retraso pedido.
    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails('tamagotchi', 'Tamagotchi'),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancela todas las notificaciones programadas.
  ///
  /// Se llama al reanudar la app, ya que el usuario vuelve a ver a la mascota y
  /// los avisos dejan de tener sentido.
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
