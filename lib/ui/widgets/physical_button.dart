import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhysicalButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const PhysicalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = const Color(0xFF4A4A4A),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
