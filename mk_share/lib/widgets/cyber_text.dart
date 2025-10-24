import 'package:flutter/material.dart';

class CyberText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final double letterSpacing;

  const CyberText({
    super.key,
    required this.text,
    this.size = 16,
    this.color = Colors.white,
    this.letterSpacing = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        color: color,
        fontFamily: 'RobotoMono',
        letterSpacing: letterSpacing,
        shadows: [
          Shadow(
            color: color.withOpacity(0.5),
            blurRadius: 5,
          ),
        ],
      ),
    );
  }
}