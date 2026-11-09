import 'dart:math';
import 'package:flutter/material.dart';

class InteractiveDotGrid extends StatefulWidget {
  final Widget child;
  const InteractiveDotGrid({super.key, required this.child});

  @override
  State<InteractiveDotGrid> createState() => _InteractiveDotGridState();
}

class _InteractiveDotGridState extends State<InteractiveDotGrid>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<Offset?> _mousePosNotifier = ValueNotifier<Offset?>(null);
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mousePosNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        // High-performance pointer tracking: does NOT rebuild the widget tree!
        _mousePosNotifier.value = event.localPosition;
      },
      onExit: (_) {
        _mousePosNotifier.value = null;
      },
      child: Stack(
        children: [
          // 1. High-FPS hardware-accelerated canvas
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulseController, _mousePosNotifier]),
              builder: (context, _) {
                return RepaintBoundary(
                  child: CustomPaint(
                    painter: _FreeFlowDotPainter(
                      mousePos: _mousePosNotifier.value,
                      time: _pulseController.value,
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Radial vignette overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.1),
                    radius: 1.25,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF060612).withValues(alpha: 0.45),
                      const Color(0xFF060612).withValues(alpha: 0.98),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 3. Child widgets (never rebuilt by mouse movement)
          widget.child,
        ],
      ),
    );
  }
}

class _FreeFlowDotPainter extends CustomPainter {
  final Offset? mousePos;
  final double time;

  _FreeFlowDotPainter({required this.mousePos, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // Crisp, fine dot grid matching demo video
    const double dotRadius = 1.25;
    const double spacing = 28.0; // Optimized spacing for silky 60fps performance
    const double proximity = 220.0;
    const double proximitySq = proximity * proximity;
    const double maxDisplacement = 26.0;

    const baseColor = Color(0xFF231B32);
    final defaultPaint = Paint()..color = baseColor;

    final cols = (size.width / spacing).ceil() + 1;
    final rows = (size.height / spacing).ceil() + 1;

    final mx = mousePos?.dx;
    final my = mousePos?.dy;

    for (int y = 0; y < rows; y++) {
      final cy = y * spacing + spacing / 2;

      // Fast vertical proximity cull
      final bool nearY = my != null && (cy - my).abs() < proximity;

      for (int x = 0; x < cols; x++) {
        final cx = x * spacing + spacing / 2;

        double drawX = cx;
        double drawY = cy;
        double r = dotRadius;
        Color col = baseColor;

        if (nearY && mx != null) {
          final dx = cx - mx;
          final dy = cy - my;

          if (dx.abs() < proximity) {
            final distSq = dx * dx + dy * dy;

            if (distSq < proximitySq && distSq > 0.01) {
              final dist = sqrt(distSq);
              final norm = dist / proximity;
              final t = 0.5 * (1.0 + cos(norm * pi)); // Smooth cosine falloff

              // Repulsion push
              final push = maxDisplacement * t;
              drawX += (dx / dist) * push;
              drawY += (dy / dist) * push;

              r = dotRadius + (t * 0.45);

              // Smooth dynamic color shift: Indigo -> Violet -> Neon Pink
              final colorPhase = (time * 2 * pi + norm * 2);
              final highlightCol = Color.lerp(
                const Color(0xFF5227FF),
                Color.lerp(
                  const Color(0xFF9333EA),
                  const Color(0xFFE040FB),
                  sin(colorPhase) * 0.5 + 0.5,
                ),
                t,
              )!;

              col = Color.lerp(baseColor, highlightCol, t * 0.95)!;
            }
          }
        } else {
          // Ambient cosmic shimmer
          final ambientWave = sin(time * 2 * pi + (cx * 0.006 + cy * 0.006));
          if (ambientWave > 0.72) {
            col = Color.lerp(
              baseColor,
              const Color(0x3B6366F1),
              (ambientWave - 0.72) * 3.5,
            )!;
          }
        }

        final p = col == baseColor ? defaultPaint : (Paint()..color = col);
        canvas.drawCircle(Offset(drawX, drawY), r, p);
      }
    }
  }

  @override
  bool shouldRepaint(_FreeFlowDotPainter oldDelegate) {
    return oldDelegate.mousePos != mousePos || oldDelegate.time != time;
  }
}
