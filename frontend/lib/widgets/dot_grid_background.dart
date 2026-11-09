import 'dart:math';
import 'package:flutter/material.dart';

class DotGridBackground extends StatefulWidget {
  final Widget child;
  const DotGridBackground({super.key, required this.child});

  @override
  State<DotGridBackground> createState() => _DotGridBackgroundState();
}

class _DotGridBackgroundState extends State<DotGridBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _DotGridPainter(progress: _controller.value),
              );
            },
          ),
        ),
        // Radial vignette overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.1),
                radius: 1.1,
                colors: [
                  Colors.transparent,
                  const Color(0xFF060612).withValues(alpha: 0.5),
                  const Color(0xFF060612).withValues(alpha: 0.98),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final double progress;
  _DotGridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const double spacing = 32.0;
    const double dotRadius = 1.3;

    final paint = Paint()..color = const Color(0x336366F1); // rgba(99,102,241,0.2)
    final highlightPaint = Paint()
      ..color = Color.lerp(
        const Color(0x407B5CFF),
        const Color(0x80E040FB),
        progress,
      )!;

    final centerX = size.width / 2;
    final centerY = size.height * 0.4;
    final maxDist = size.width * 0.45;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        final dist = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));
        if (dist < maxDist) {
          final factor = (1.0 - (dist / maxDist)).clamp(0.0, 1.0);
          final pulse = (sin(progress * pi * 2 + dist * 0.02) * 0.5 + 0.5);
          canvas.drawCircle(
            Offset(x, y),
            dotRadius + factor * 0.6 * pulse,
            factor > 0.4 ? highlightPaint : paint,
          );
        } else {
          canvas.drawCircle(Offset(x, y), dotRadius, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => oldDelegate.progress != progress;
}
