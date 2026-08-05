/// Componente decorativo de rejilla de píxeles.
///
/// Este archivo define [PixelGridComponent], un componente visual que dibuja una
/// rejilla tenue sobre la pantalla LCD para simular la matriz de píxeles de una
/// pantalla retro. Es puramente estético: no tiene lógica, no recibe estado y no
/// emite eventos.
library;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Rejilla de líneas finas que simula la matriz de píxeles del LCD.
///
/// Dibuja líneas verticales y horizontales cada 4 píxeles con un trazo casi
/// transparente, dando textura de pantalla antigua sin ocultar el contenido.
class PixelGridComponent extends Component with HasGameReference {
  /// Pintura usada para las líneas: negra con opacidad muy baja y trazo fino.
  final Paint _paint = Paint()
    ..color = const Color(0x0A000000)
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke;

  /// Dibuja la rejilla sobre el lienzo [canvas].
  ///
  /// Recorre el tamaño lógico del juego ([game.size]) trazando una línea vertical y
  /// una horizontal cada 4 píxeles. El mixin `HasGameReference` proporciona el
  /// acceso a [game] para conocer las dimensiones del viewport.
  @override
  void render(Canvas canvas) {
    final size = game.size;
    // Líneas verticales, separadas 4 píxeles.
    for (double x = 0; x < size.x; x += 4) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), _paint);
    }
    // Líneas horizontales, separadas 4 píxeles.
    for (double y = 0; y < size.y; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), _paint);
    }
  }
}
