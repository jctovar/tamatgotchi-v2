import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PixelGridComponent extends Component with HasGameReference {
  final Paint _paint = Paint()
    ..color = const Color(0x0A000000)
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke;

  @override
  void render(Canvas canvas) {
    final size = game.size;
    for (double x = 0; x < size.x; x += 4) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), _paint);
    }
    for (double y = 0; y < size.y; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), _paint);
    }
  }
}
