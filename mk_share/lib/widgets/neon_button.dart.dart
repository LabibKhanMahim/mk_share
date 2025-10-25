import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'glowing_button.dart';

class NeonButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const NeonButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.width = 150,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return GlowingButton(
      text: text,
      icon: icon,
      onPressed: onPressed,
      width: width,
      height: height,
      glowColor: AppTheme.primaryColor,
      textColor: AppTheme.primaryColor,
      fontSize: 14,
    );
  }
}
