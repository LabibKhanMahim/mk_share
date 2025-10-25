import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _gridController;
  late AnimationController _particleController;
  late AnimationController _scanController;

  late Animation<double> _gridAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();

    // Grid animation
    _gridController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _gridAnimation = Tween<double>(begin: 0, end: 1).animate(_gridController);
    _gridController.repeat();

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );
    _particleAnimation =
        Tween<double>(begin: 0, end: 1).animate(_particleController);
    _particleController.repeat();

    // Scan line animation
    _scanController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(_scanController);
    _scanController.repeat();
  }

  @override
  void dispose() {
    _gridController.dispose();
    _particleController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Grid background
        AnimatedBuilder(
          animation: _gridAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: GridPainter(_gridAnimation.value),
              size: Size.infinite,
            );
          },
        ),

        // Floating particles
        AnimatedBuilder(
          animation: _particleAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(_particleAnimation.value),
              size: Size.infinite,
            );
          },
        ),

        // Scanning line
        AnimatedBuilder(
          animation: _scanAnimation,
          builder: (context, child) {
            return Positioned(
              top: MediaQuery.of(context).size.height * _scanAnimation.value,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.primaryColor.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  final double animationValue;

  GridPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    const gridSize = 30.0;
    final offset = (animationValue * gridSize) % gridSize;

    // Draw vertical lines
    for (double x = -gridSize + offset;
        x < size.width + gridSize;
        x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = -gridSize + offset;
        y < size.height + gridSize;
        y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.secondaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    const particleCount = 20;
    final random = animationValue;

    for (int i = 0; i < particleCount; i++) {
      final x = (size.width * ((i * 0.1 + random) % 1.0));
      final y = (size.height * ((i * 0.15 + random * 0.5) % 1.0));
      final radius = 2.0 + (i % 3) * 1.5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
