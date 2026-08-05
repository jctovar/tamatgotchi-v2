/// Overlay visual del menú de opciones sobre la pantalla LCD.
///
/// Este archivo define [MenuOverlayComponent], el componente Flame que dibuja
/// el estado de `menuProvider` (Riverpod) sobre la pantalla LCD: la lista de
/// opciones, cuál está seleccionada y si el menú está visible. Es un
/// componente puramente reactivo: `TamagotchiGame` le empuja los cambios de
/// estado y de idioma; el componente nunca los origina.
library;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../providers/menu_provider.dart';
import '../../utils/constants.dart';

/// Dibuja la lista de opciones del menú sobre la pantalla LCD cuando está
/// visible.
///
/// Se agrega a `world` con [priority] alto para dibujarse siempre por encima
/// de `PixelGridComponent` y del sprite de la mascota, sin depender del
/// orden en que se insertaron. Mientras el menú está oculto, [render] no
/// dibuja nada.
class MenuOverlayComponent extends Component {
  /// Alto de cada línea de opción, en píxeles lógicos de la pantalla LCD.
  static const double _lineHeight = 18;

  /// Margen superior antes de la primera línea.
  static const double _topPadding = 16;

  /// Margen horizontal del panel y de la barra de selección.
  static const double _horizontalPadding = 8;

  /// Último estado del menú recibido desde Riverpod.
  MenuState menuState = const MenuState();

  /// Etiquetas localizadas, en el mismo orden que [MenuState.items].
  ///
  /// Antes de recibir el primer [updateLabels] (vía `AppLocalizations`),
  /// usa los nombres del enum como valor por defecto.
  List<String> labels = MenuItem.values.map((item) => item.name).toList();

  /// Pintura del texto de opciones no seleccionadas.
  final TextPaint _unselectedText = TextPaint(
    style: const TextStyle(
      color: Color(0xFF9BBC0F),
      fontFamily: 'monospace',
      fontSize: 10,
    ),
  );

  /// Pintura del texto de la opción seleccionada (sobre fondo invertido).
  final TextPaint _selectedText = TextPaint(
    style: const TextStyle(
      color: Color(0xFF0F380F),
      fontFamily: 'monospace',
      fontSize: 10,
    ),
  );

  /// Crea el overlay con prioridad de dibujado alta.
  MenuOverlayComponent() : super(priority: 10);

  /// Actualiza el estado del menú (visibilidad y selección).
  void updateMenuState(MenuState state) {
    menuState = state;
  }

  /// Actualiza las etiquetas de texto localizadas.
  void updateLabels(List<String> newLabels) {
    labels = newLabels;
  }

  /// Dibuja el panel semitransparente y la lista de opciones si el menú
  /// está visible; no hace nada si está oculto.
  @override
  void render(Canvas canvas) {
    if (!menuState.isVisible) return;

    final width = Constants.lcdWidth.toDouble();
    final height = Constants.lcdHeight.toDouble();

    // Panel de fondo semitransparente sobre toda la pantalla lógica.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = const Color(0xCC2C2C2C),
    );

    for (var i = 0; i < menuState.items.length; i++) {
      final rowY = _topPadding + i * _lineHeight;
      final isSelected = i == menuState.selectedIndex;

      if (isSelected) {
        canvas.drawRect(
          Rect.fromLTWH(
            _horizontalPadding,
            rowY,
            width - _horizontalPadding * 2,
            _lineHeight,
          ),
          Paint()..color = const Color(0xFF9BBC0F),
        );
      }

      (isSelected ? _selectedText : _unselectedText).render(
        canvas,
        labels[i],
        Vector2(_horizontalPadding * 2, rowY + 2),
      );
    }
  }
}
