// lib/providers/flame_action_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_action.dart';

class FlameActionNotifier extends ChangeNotifier {
  PetAction? _lastAction;
  int _timestamp = 0;

  PetAction? get lastAction => _lastAction;
  int get timestamp => _timestamp;

  void trigger(PetAction action) {
    _lastAction = action;
    _timestamp = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }
}

final flameActionProvider =
    ChangeNotifierProvider<FlameActionNotifier>((ref) => FlameActionNotifier());
