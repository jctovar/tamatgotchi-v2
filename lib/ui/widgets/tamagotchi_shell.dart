/// Carcasa física del Tamagotchi.
///
/// Este archivo define [TamagotchiShell], el widget que dibuja el "hardware" del
/// juguete: un contenedor rosa con la pantalla LCD y los tres botones físicos
/// A/B/C. Es un componente de presentación puro: no contiene estado ni lógica, y
/// delega las pulsaciones de los botones en los manejadores que recibe por
/// parámetro (que en última instancia invocan a Riverpod).
library;

import 'package:flutter/material.dart';
import 'lcd_screen.dart';
import 'physical_button.dart';

/// Carcasa del juguete con la pantalla LCD y los botones A/B/C.
///
/// Recibe tres callbacks ([onButtonA], [onButtonB], [onButtonC]) que se invocan al
/// pulsar cada botón físico. El padre ([HomeScreen]) decide qué hace cada botón.
class TamagotchiShell extends StatelessWidget {
  /// Callback invocado al pulsar el botón A.
  final VoidCallback onButtonA;

  /// Callback invocado al pulsar el botón B.
  final VoidCallback onButtonB;

  /// Callback invocado al pulsar el botón C.
  final VoidCallback onButtonC;

  /// Crea la carcasa con los tres manejadores de botón requeridos.
  const TamagotchiShell({
    super.key,
    required this.onButtonA,
    required this.onButtonB,
    required this.onButtonC,
  });

  /// Construye la carcasa: contenedor rosa con la pantalla y la fila de botones.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LcdScreen(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PhysicalButton(label: 'A', onPressed: onButtonA),
              PhysicalButton(label: 'B', onPressed: onButtonB),
              PhysicalButton(label: 'C', onPressed: onButtonC),
            ],
          ),
        ],
      ),
    );
  }
}
