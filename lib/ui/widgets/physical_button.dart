/// Botón físico reutilizable de la carcasa.
///
/// Este archivo define [PhysicalButton], el widget que representa uno de los tres
/// botones circulares del Tamagotchi. Es un componente de presentación puro: dibuja
/// un círculo con una etiqueta, emite una vibración háptica al pulsarse y delega la
/// acción en el callback [onPressed]. No contiene estado ni lógica de negocio.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Botón circular con etiqueta, retroalimentación háptica y callback de pulsación.
///
/// Al tocarlo, dispara una vibración ([HapticFeedback.mediumImpact]) para simular
/// la sensación de un botón físico y después invoca [onPressed].
class PhysicalButton extends StatelessWidget {
  /// Texto que se muestra en el centro del botón (por ejemplo, "A").
  final String label;

  /// Callback invocado al pulsar el botón.
  final VoidCallback onPressed;

  /// Color de fondo del botón.
  final Color color;

  /// Crea el botón con su [label], [onPressed] y un [color] opcional.
  const PhysicalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = const Color(0xFF4A4A4A),
  });

  /// Construye el botón circular con su etiqueta y sombra.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Vibración háptica para simular la pulsación de un botón físico.
        HapticFeedback.mediumImpact();
        onPressed();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 3),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
