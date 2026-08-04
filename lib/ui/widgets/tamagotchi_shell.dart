import 'package:flutter/material.dart';
import 'lcd_screen.dart';
import 'physical_button.dart';

class TamagotchiShell extends StatelessWidget {
  final VoidCallback onButtonA;
  final VoidCallback onButtonB;
  final VoidCallback onButtonC;

  const TamagotchiShell({
    super.key,
    required this.onButtonA,
    required this.onButtonB,
    required this.onButtonC,
  });

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
