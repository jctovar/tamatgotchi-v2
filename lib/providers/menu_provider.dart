import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MenuItem { food, light, play, medicine, status, game }

final menuProvider = NotifierProvider<MenuNotifier, MenuState>(
  MenuNotifier.new,
);

class MenuState {
  final List<MenuItem> items;
  final int selectedIndex;
  final bool isVisible;

  const MenuState({
    this.items = MenuItem.values,
    this.selectedIndex = 0,
    this.isVisible = false,
  });

  MenuItem get currentItem => items[selectedIndex];

  MenuState copyWith({int? selectedIndex, bool? isVisible}) => MenuState(
        items: items,
        selectedIndex: selectedIndex ?? this.selectedIndex,
        isVisible: isVisible ?? this.isVisible,
      );
}

class MenuNotifier extends Notifier<MenuState> {
  @override
  MenuState build() => const MenuState();

  void next() {
    final s = state;
    final nextIndex = (s.selectedIndex + 1) % s.items.length;
    state = s.copyWith(selectedIndex: nextIndex);
  }

  void toggle() {
    state = state.copyWith(isVisible: !state.isVisible);
  }

  void hide() {
    state = state.copyWith(isVisible: false);
  }
}
