import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/pet_state.dart';
import '../utils/constants.dart';

abstract final class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  static Future<void> scheduleWarnings(PetState state) async {
    await cancelAll();
    if (!state.isAlive) return;

    if (state.hunger < Constants.hungerWarningThreshold) {
      await _schedule(
        id: 1,
        title: 'Tamagotchi',
        body: 'Tu mascota tiene hambre!',
        delay: const Duration(minutes: 30),
      );
    }

    if (state.health < Constants.healthWarningThreshold) {
      await _schedule(
        id: 2,
        title: 'Tamagotchi',
        body: 'Tu mascota esta enferma!',
        delay: const Duration(minutes: 15),
      );
    }
  }

  static Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
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

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
