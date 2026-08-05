/// Marco físico de la pantalla LCD.
///
/// Este archivo define [LcdScreen], el widget que dibuja el bisel oscuro alrededor
/// de la pantalla y aloja en su interior el motor de juego ([GameScreen]). Es un
/// componente de presentación puro: solo decora y recorta el contenido, sin estado
/// ni lógica. El recorte con bordes redondeados refuerza la estética de pantalla
/// retro incrustada en la carcasa.
library;

import 'package:flutter/material.dart';
import '../../game/widgets/game_screen.dart';

/// Bisel oscuro que enmarca y recorta la pantalla del juego.
///
/// Contiene un [GameScreen] (el motor Flame) dentro de un [ClipRRect] para que el
/// renderizado del juego quede limitado al área visible de la pantalla LCD.
class LcdScreen extends StatelessWidget {
  /// Crea el marco de la pantalla LCD.
  const LcdScreen({super.key});

  /// Construye el bisel con el área de juego recortada en su interior.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 180,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1A1A1A), width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: const GameScreen(),
      ),
    );
  }
}
