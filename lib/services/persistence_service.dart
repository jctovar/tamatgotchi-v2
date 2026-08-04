import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_state.dart';

abstract final class PersistenceService {
  static const _key = 'pet_state';

  static Future<void> save(PetState state) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.toJson());
    await prefs.setString(_key, json);
  }

  static Future<PetState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return PetState.fromJson(json);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
