// lib/providers/pet_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_action.dart';
import '../models/pet_state.dart';
import '../services/audio_service.dart';
import '../services/persistence_service.dart';
import '../services/time_engine.dart';
import 'flame_action_provider.dart';

final petControllerProvider = NotifierProvider<PetController, PetState>(
  PetController.new,
);

class PetController extends Notifier<PetState> {
  @override
  PetState build() {
    _loadState();
    return PetState.initial();
  }

  Future<void> _loadState() async {
    final saved = await PersistenceService.load();
    if (saved != null) {
      final updated = TimeEngine.applyDecay(saved, DateTime.now());
      state = updated;
    }
  }

  Future<void> _commit(PetState newState) async {
    state = newState;
    await PersistenceService.save(newState);
  }

  void feed() {
    if (!state.isAlive) return;
    _commit(state.copyWith(
      hunger: (state.hunger + 20).clamp(0.0, 100.0),
      weight: state.weight + 0.5,
      lastUpdated: DateTime.now(),
    ));
    ref.read(flameActionProvider).trigger(PetAction.feed);
    AudioService.play(PetAction.feed);
  }

  void play() {
    if (!state.isAlive) return;
    _commit(state.copyWith(
      happiness: (state.happiness + 15).clamp(0.0, 100.0),
      hunger: (state.hunger - 5).clamp(0.0, 100.0),
      weight: (state.weight - 0.2).clamp(1.0, 50.0),
      lastUpdated: DateTime.now(),
    ));
    ref.read(flameActionProvider).trigger(PetAction.play);
    AudioService.play(PetAction.play);
  }

  void clean() {
    if (!state.isAlive) return;
    _commit(state.copyWith(
      health: (state.health + 5).clamp(0.0, 100.0),
      lastUpdated: DateTime.now(),
    ));
    ref.read(flameActionProvider).trigger(PetAction.clean);
    AudioService.play(PetAction.clean);
  }

  void useMedicine() {
    if (!state.isAlive) return;
    _commit(state.copyWith(
      health: (state.health + 30).clamp(0.0, 100.0),
      lastUpdated: DateTime.now(),
    ));
    ref.read(flameActionProvider).trigger(PetAction.medicine);
    AudioService.play(PetAction.medicine);
  }

  void toggleLight() {
    _commit(state.copyWith(
      isLightOn: !state.isLightOn,
      lastUpdated: DateTime.now(),
    ));
    ref.read(flameActionProvider).trigger(PetAction.toggleLight);
    AudioService.play(PetAction.toggleLight);
  }

  void sleep() {
    _commit(state.copyWith(isSleeping: true, lastUpdated: DateTime.now()));
    ref.read(flameActionProvider).trigger(PetAction.sleep);
    AudioService.play(PetAction.sleep);
  }

  void wake() {
    _commit(state.copyWith(isSleeping: false, lastUpdated: DateTime.now()));
  }

  void applyTimeDecay() {
    final updated = TimeEngine.applyDecay(state, DateTime.now());
    state = updated;
    PersistenceService.save(updated);
  }
}
