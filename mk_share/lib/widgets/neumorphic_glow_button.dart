import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class NeumorphicGlowButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const NeumorphicGlowButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.width = 150,
    this.height = 50,
  });

  @override
  State<NeumorphicGlowButton> createState() => _NeumorphicGlowButtonState();
}

class _NeumorphicGlowButtonState extends State<NeumorphicGlowButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FF41)
                    .withOpacity(0.3 * _glowAnimation.value),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: NeumorphicButton(
            onPressed: widget.onPressed,
            style: NeumorphicStyle(
              // <-- const removed ✅
              color: const Color(0xFF1A1A1A),
              boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.all(Radius.circular(12))),
              border: const NeumorphicBorder(
                color: Color(0xFF00FF41),
                width: 1.5,
              ),
            ),
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: Center(
                child: widget.icon != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.icon,
                            color: const Color(0xFF00FF41),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.text,
                            style: const TextStyle(
                              color: Color(0xFF00FF41),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Courier',
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        widget.text,
                        style: const TextStyle(
                          color: Color(0xFF00FF41),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
