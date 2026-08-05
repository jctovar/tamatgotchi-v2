// lib/providers/pet_controller.dart
/// Controlador de estado de la mascota (fuente de verdad y lógica de negocio).
///
/// Este archivo define [PetController] y su proveedor [petControllerProvider].
/// Es el corazón de la arquitectura unidireccional: recibe las intenciones de la
/// UI (botones A/B/C), las traduce a mutaciones del [PetState] y orquesta los
/// efectos secundarios de salida (persistencia, animación en Flame y sonido).
///
/// Flujo de una acción típica (p. ej. alimentar):
///
/// 1. La UI llama a un método de este controlador (`feed()`).
/// 2. El método muta el estado con `copyWith` y lo persiste vía [_commit].
/// 3. Se emite el evento hacia Flame (`flameActionProvider`) para animar.
/// 4. Se reproduce el efecto de sonido (`AudioService`).
///
/// El estado nunca se muta directamente desde la UI ni desde Flame; todo pasa
/// por este controlador.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_action.dart';
import '../models/pet_state.dart';
import '../services/audio_service.dart';
import '../services/persistence_service.dart';
import '../services/time_engine.dart';
import 'flame_action_provider.dart';

/// Proveedor que expone el [PetController] y su [PetState] asociado.
///
/// Los widgets y otros proveedores leen el estado con
/// `ref.watch(petControllerProvider)` y ejecutan acciones con
/// `ref.read(petControllerProvider.notifier)`.
final petControllerProvider = NotifierProvider<PetController, PetState>(
  PetController.new,
);

/// Notificador que concentra toda la lógica de negocio de la mascota.
///
/// Como [Notifier], su campo [state] es el [PetState] actual. Cada método público
/// representa una acción del usuario y sigue el patrón: mutar el estado,
/// persistirlo y emitir los efectos secundarios (animación y sonido).
class PetController extends Notifier<PetState> {
  /// Inicializa el proveedor devolviendo el estado inicial.
  ///
  /// Arranca con [PetState.initial] de forma síncrona y, en paralelo, lanza la
  /// carga asíncrona del estado guardado ([_loadState]). Esto permite que la UI
  /// tenga un estado válido de inmediato y se actualice cuando termine la carga.
  @override
  PetState build() {
    _loadState();
    return PetState.initial();
  }

  /// Carga el estado guardado, aplica el decaimiento acumulado y lo publica.
  ///
  /// Es un "fire-and-forget": se invoca sin `await` desde [build] porque Riverpod
  /// necesita un valor síncrono inicial; la carga real ocurre en segundo plano y
  /// reemplaza el estado cuando termina. Si no hay datos guardados, no hace nada
  /// y se conserva el estado inicial.
  Future<void> _loadState() async {
    final saved = await PersistenceService.load();
    if (saved != null) {
      // Aplica el tiempo transcurrido desde que la app se cerró por última vez.
      final updated = TimeEngine.applyDecay(saved, DateTime.now());
      state = updated;
    }
  }

  /// Publica [newState] y lo persiste de forma inmediata.
  ///
  /// También es "fire-and-forget": los métodos de acción no esperan a que termine
  /// la escritura en disco, de modo que la UI se actualiza al instante. La
  /// persistencia se completa en segundo plano.
  Future<void> _commit(PetState newState) async {
    state = newState;
    await PersistenceService.save(newState);
  }

  /// Alimenta a la mascota: +20 de saciedad y +0.5 de peso.
  ///
  /// No tiene efecto si la mascota está muerta (guarda [PetState.isAlive]).
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

  /// Juega con la mascota: +15 de felicidad, −5 de saciedad y −0.2 de peso.
  ///
  /// El peso se limita al rango 1.0–50.0. No tiene efecto si está muerta.
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

  /// Limpia a la mascota: +5 de salud. No tiene efecto si está muerta.
  void clean() {
    if (!state.isAlive) return;
    _commit(state.copyWith(
      health: (state.health + 5).clamp(0.0, 100.0),
      lastUpdated: DateTime.now(),
    ));
    ref.read(flameActionProvider).trigger(PetAction.clean);
    AudioService.play(PetAction.clean);
  }

  /// Da medicina a la mascota: +30 de salud. No tiene efecto si está muerta.
  void useMedicine() {
    if (!state.isAlive) return;
    _commit(state.copyWith(
      health: (state.health + 30).clamp(0.0, 100.0),
      lastUpdated: DateTime.now(),
    ));
    ref.read(flameActionProvider).trigger(PetAction.medicine);
    AudioService.play(PetAction.medicine);
  }

  /// Enciende o apaga la luz de la pantalla.
  ///
  /// A diferencia de las acciones anteriores, no requiere que la mascota esté
  /// viva: la luz puede togglearse en cualquier momento.
  void toggleLight() {
    _commit(state.copyWith(
      isLightOn: !state.isLightOn,
      lastUpdated: DateTime.now(),
    ));
    ref.read(flameActionProvider).trigger(PetAction.toggleLight);
    AudioService.play(PetAction.toggleLight);
  }

  /// Duerme a la mascota, pausando el decaimiento de estadísticas.
  void sleep() {
    _commit(state.copyWith(isSleeping: true, lastUpdated: DateTime.now()));
    ref.read(flameActionProvider).trigger(PetAction.sleep);
    AudioService.play(PetAction.sleep);
  }

  /// Despierta a la mascota, reanudando el decaimiento de estadísticas.
  ///
  /// No emite animación ni sonido; solo cambia el interruptor de sueño.
  void wake() {
    _commit(state.copyWith(isSleeping: false, lastUpdated: DateTime.now()));
  }

  /// Aplica el decaimiento por el tiempo transcurrido hasta ahora.
  ///
  /// Lo invoca `LifecycleObserver` al reanudar la app desde segundo plano.
  /// Delega el cálculo en [TimeEngine] y persiste el resultado.
  void applyTimeDecay() {
    final updated = TimeEngine.applyDecay(state, DateTime.now());
    state = updated;
    PersistenceService.save(updated);
  }
}
