import 'dart:math';
import 'package:flutter/material.dart';

class InteractiveDotGrid extends StatefulWidget {
  final Widget child;
  const InteractiveDotGrid({super.key, required this.child});

  @override
  State<InteractiveDotGrid> createState() => _InteractiveDotGridState();
}

class _InteractiveDotGridState extends State<InteractiveDotGrid> with SingleTickerProviderStateMixin {
  Offset? _targetMousePos;
  Offset? _smoothMousePos;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          _targetMousePos = event.localPosition;
          // Smooth interpolation towards cursor
          if (_smoothMousePos == null) {
            _smoothMousePos = event.localPosition;
          } else {
            _smoothMousePos = Offset(
              _smoothMousePos!.dx + (event.localPosition.dx - _smoothMousePos!.dx) * 0.45,
              _smoothMousePos!.dy + (event.localPosition.dy - _smoothMousePos!.dy) * 0.45,
            );
          }
        });
      },
      onExit: (_) {
        setState(() {
          _targetMousePos = null;
          _smoothMousePos = null;
        });
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _FreeFlowDotPainter(
                    mousePos: _smoothMousePos ?? _targetMousePos,
                    time: _pulseController.value,
                  ),
                );
              },
            ),
          ),
          // Radial vignette overlay
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
    // Elegant, fine dot grid matching index.html
    const double dotRadius = 1.35; // Kept sharp and fine — NOT bold!
    const double spacing = 22.0;
    const double proximity = 240.0; // WIDE reaction area!
    const double maxDisplacement = 28.0; // Gentle, free floating displacement

    // Base dark purple dot color
    const baseColor = Color(0xFF231B32);

    final cols = (size.width / spacing).ceil() + 1;
    final rows = (size.height / spacing).ceil() + 1;

    final defaultPaint = Paint()..color = baseColor;

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final cx = x * spacing + spacing / 2;
        final cy = y * spacing + spacing / 2;

        double drawX = cx;
        double drawY = cy;
        double r = dotRadius;
        Color col = baseColor;

        if (mousePos != null) {
          final dx = cx - mousePos!.dx;
          final dy = cy - mousePos!.dy;
          final distSq = dx * dx + dy * dy;

          if (distSq < proximity * proximity && distSq > 0.1) {
            final dist = sqrt(distSq);
            // Smooth natural cosine falloff: 1.0 at center, 0.0 at perimeter
            final norm = dist / proximity;
            final t = 0.5 * (1.0 + cos(norm * pi)); // Silky smooth bell-curve

            // Gentle free displacement (push outward without dense ring)
            final push = maxDisplacement * t;
            drawX += (dx / dist) * push;
            drawY += (dy / dist) * push;

            // Keep radius delicate — maximum +0.4px increase only
            r = dotRadius + (t * 0.45);

            // Smooth color transition shifting across violet, purple, and neon pink
            final colorPhase = (time * 2 * pi + norm * 2);
            final highlightCol = Color.lerp(
              const Color(0xFF5227FF), // Electric Indigo
              Color.lerp(
                const Color(0xFF9333EA), // Violet
                const Color(0xFFE040FB), // Neon Pink
                sin(colorPhase) * 0.5 + 0.5,
              ),
              t,
            )!;

            col = Color.lerp(baseColor, highlightCol, t * 0.95)!;
          }
        } else {
          // Slow ambient cosmic drift across the grid
          final ambientWave = sin(time * 2 * pi + (cx * 0.008 + cy * 0.008));
          if (ambientWave > 0.7) {
            col = Color.lerp(
              baseColor,
              const Color(0x3B6366F1),
              (ambientWave - 0.7) * 3.0,
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
