/// Servicio de persistencia del estado de la mascota.
///
/// Este archivo contiene [PersistenceService], la capa de acceso a datos de la
/// aplicación. Serializa el [PetState] a JSON y lo guarda en `SharedPreferences`,
/// de modo que la mascota sobreviva al cierre de la app. En la arquitectura
/// unidireccional, este servicio es el único punto de contacto con el
/// almacenamiento local: `PetController` lo invoca tras cada mutación para que
/// el estado quede siempre guardado de forma inmediata.
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_state.dart';

/// Persistencia de [PetState] en `SharedPreferences` como JSON.
///
/// Todos sus métodos son estáticos y asíncronos. No mantiene estado interno; la
/// clave de almacenamiento es fija ([_key]).
abstract final class PersistenceService {
  /// Clave bajo la que se guarda el JSON del estado en `SharedPreferences`.
  static const _key = 'pet_state';

  /// Guarda [state] serializándolo a JSON y escribiéndolo en `SharedPreferences`.
  ///
  /// Se llama tras cada mutación del estado para que la persistencia sea
  /// inmediata y no se pierda progreso si la app se cierra inesperadamente.
  static Future<void> save(PetState state) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.toJson());
    await prefs.setString(_key, json);
  }

  /// Carga y deserializa el [PetState] guardado, o devuelve `null` si no existe.
  ///
  /// Devuelve `null` la primera vez que se ejecuta la app (sin datos previos),
  /// en cuyo caso el controlador usará `PetState.initial()`.
  static Future<PetState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return PetState.fromJson(json);
  }

  /// Elimina el estado guardado, borrando por completo a la mascota.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
