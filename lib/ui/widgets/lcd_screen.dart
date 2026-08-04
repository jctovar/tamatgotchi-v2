import 'package:flutter/material.dart';
import '../../game/widgets/game_screen.dart';

class LcdScreen extends StatelessWidget {
  const LcdScreen({super.key});

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
