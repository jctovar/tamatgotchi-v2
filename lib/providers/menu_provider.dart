/// Estado y lógica del menú de iconos de la interfaz.
///
/// Este archivo define [MenuState], [MenuNotifier] y su proveedor [menuProvider],
/// además del enum [MenuItem]. Modela el pequeño menú del Tamagotchi: una lista
/// de opciones por la que el usuario navega con el botón A y que ejecuta con el
/// botón B. Es estado puramente de UI (no afecta a las estadísticas de la
/// mascota) y, como tal, vive en Riverpod dentro de la arquitectura unidireccional.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opciones disponibles en el menú de iconos.
///
/// * [food] Alimentar a la mascota.
/// * [light] Encender/apagar la luz.
/// * [play] Jugar con la mascota.
/// * [medicine] Dar medicina.
/// * [status] Ver el estado (reservado, aún sin acción).
/// * [game] Mini-juego (reservado, aún sin acción).
enum MenuItem { food, light, play, medicine, status, game }

/// Proveedor que expone el [MenuNotifier] y su [MenuState] asociado.
final menuProvider = NotifierProvider<MenuNotifier, MenuState>(
  MenuNotifier.new,
);

/// Estado inmutable del menú: sus opciones, la selección actual y su visibilidad.
class MenuState {
  /// Lista ordenada de opciones del menú.
  final List<MenuItem> items;

  /// Índice de la opción seleccionada actualmente.
  final int selectedIndex;

  /// Indica si el menú está visible u oculto.
  final bool isVisible;

  /// Crea un estado de menú con valores por defecto (primera opción, oculto).
  const MenuState({
    this.items = MenuItem.values,
    this.selectedIndex = 0,
    this.isVisible = false,
  });

  /// Opción seleccionada actualmente.
  MenuItem get currentItem => items[selectedIndex];

  /// Devuelve una copia de este estado cambiando [selectedIndex] y/o [isVisible].
  ///
  /// La lista [items] se conserva siempre; solo varían la selección y la
  /// visibilidad.
  MenuState copyWith({int? selectedIndex, bool? isVisible}) => MenuState(
        items: items,
        selectedIndex: selectedIndex ?? this.selectedIndex,
        isVisible: isVisible ?? this.isVisible,
      );
}

/// Notificador que gestiona la navegación y visibilidad del menú.
class MenuNotifier extends Notifier<MenuState> {
  /// Inicializa el proveedor con un menú oculto y en la primera opción.
  @override
  MenuState build() => const MenuState();

  /// Avanza a la siguiente opción, volviendo al inicio de forma circular.
  void next() {
    final s = state;
    final nextIndex = (s.selectedIndex + 1) % s.items.length;
    state = s.copyWith(selectedIndex: nextIndex);
  }

  /// Muestra el menú si está oculto, o lo oculta si está visible.
  void toggle() {
    state = state.copyWith(isVisible: !state.isVisible);
  }

  /// Oculta el menú.
  void hide() {
    state = state.copyWith(isVisible: false);
  }
}
