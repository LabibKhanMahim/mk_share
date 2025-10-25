import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class GlowingButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final Color? glowColor;
  final Color? textColor;
  final double? fontSize;
  final bool isPulsing;
  final Color? backgroundColor;

  const GlowingButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.width = 150,
    this.height = 50,
    this.glowColor,
    this.textColor,
    this.fontSize,
    this.isPulsing = true,
    this.backgroundColor,
  });

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton> with AnimationMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    if (widget.isPulsing) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.glowColor ?? const Color(0xFF00FF41);
    final textColor = widget.textColor ?? const Color(0xFF00FF41);
    final backgroundColor = widget.backgroundColor ?? Colors.transparent;

    return CustomAnimationBuilder<double>(
      control: Control.play,
      tween: Tween<double>(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        // ✅ fixed order
        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: glowColor,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.3 * value),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: glowColor.withOpacity(0.2 * value),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: widget.icon != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          color: textColor,
                          size: widget.fontSize != null
                              ? widget.fontSize! * 1.2
                              : 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.text,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Terminal',
                            fontSize: widget.fontSize ?? 16,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      widget.text,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Terminal',
                        fontSize: widget.fontSize ?? 16,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
