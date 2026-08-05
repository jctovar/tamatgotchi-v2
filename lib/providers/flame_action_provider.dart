// lib/providers/flame_action_provider.dart
/// Canal de eventos unidireccional de Riverpod hacia el motor Flame.
///
/// Este archivo define [FlameActionNotifier] y su proveedor [flameActionProvider].
/// Es el mecanismo por el cual las acciones del controlador se convierten en
/// eventos que el motor Flame observa para reproducir animaciones, sin que Flame
/// pueda mutar estado alguno. Cumple así la regla "Riverpod → Flame": el estado
/// fluye en un solo sentido y Flame solo reacciona.
///
/// Cada evento lleva una marca de tiempo para que los oyentes puedan distinguir
/// repeticiones de una misma acción (por ejemplo, dos `feed` consecutivos).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_action.dart';

/// Emisor de eventos de acción que notifica a los oyentes (el motor Flame).
///
/// Como [ChangeNotifier], cada llamada a [trigger] actualiza la última acción y
/// su marca de tiempo, y avisa a los suscriptores mediante `notifyListeners()`.
class FlameActionNotifier extends ChangeNotifier {
  /// Última acción emitida, o `null` si aún no se ha emitido ninguna.
  PetAction? _lastAction;

  /// Marca de tiempo (ms desde epoch) de la última acción emitida.
  int _timestamp = 0;

  /// Última acción emitida, o `null` si no hay ninguna.
  PetAction? get lastAction => _lastAction;

  /// Marca de tiempo (ms desde epoch) de la última acción emitida.
  int get timestamp => _timestamp;

  /// Emite [action] como evento, actualizando la marca de tiempo y notificando.
  ///
  /// La marca de tiempo se renueva en cada llamada para que dos emisiones
  /// idénticas y consecutivas sigan siendo distinguibles por los oyentes.
  void trigger(PetAction action) {
    _lastAction = action;
    _timestamp = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }
}

/// Proveedor que expone el emisor de eventos [FlameActionNotifier].
///
/// `PetController` lo usa para emitir eventos (`trigger`) y el widget
/// `GameScreen` lo escucha para trasladarlos al motor Flame.
final flameActionProvider =
    ChangeNotifierProvider<FlameActionNotifier>((ref) => FlameActionNotifier());
