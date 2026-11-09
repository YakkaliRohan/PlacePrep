import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';


// ── 1. ANIMATED PERFORMANCE TREND LINE CHART ──
class AnimatedTrendChart extends StatefulWidget {
  final bool isLong;
  final List<Offset>? customPoints;

  const AnimatedTrendChart({
    super.key,
    this.isLong = false,
    this.customPoints,
  });

  @override
  State<AnimatedTrendChart> createState() => _AnimatedTrendChartState();
}

class _AnimatedTrendChartState extends State<AnimatedTrendChart>
    with TickerProviderStateMixin {
  late AnimationController _drawController;
  late AnimationController _pulseController;
  late Animation<double> _drawAnimation;

  @override
  void initState() {
    super.initState();
    // 1. Line drawing animation left-to-right on open
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _drawAnimation = CurvedAnimation(
      parent: _drawController,
      curve: Curves.easeOutCubic,
    );

    // 2. Gentle continuous breathing pulse at the peak
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _drawController.forward();
    });
  }

  @override
  void dispose() {
    _drawController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_drawAnimation, _pulseController]),
      builder: (context, _) {
        return CustomPaint(
          painter: _TrendChartPainter(
            progress: _drawAnimation.value,
            pulse: _pulseController.value,
            isLong: widget.isLong,
            customPoints: widget.customPoints,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final double progress;
  final double pulse;
  final bool isLong;
  final List<Offset>? customPoints;

  _TrendChartPainter({
    required this.progress,
    required this.pulse,
    required this.isLong,
    this.customPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Exact points from placeprep-demo.html SVG:
    // viewBox is 0 0 300 110
    // d="M0,90 L30,75 L60,80 L90,60 L120,65 L150,45 L180,50 L210,35 L240,30 L270,20 L300,15"
    final List<Offset> rawSvgPoints = customPoints ??
        (isLong
            ? [
                const Offset(0, 90),
                const Offset(25, 75),
                const Offset(50, 80),
                const Offset(80, 60),
                const Offset(110, 65),
                const Offset(140, 50),
                const Offset(170, 52),
                const Offset(200, 38),
                const Offset(230, 32),
                const Offset(260, 22),
                const Offset(300, 15),
              ]
            : [
                const Offset(0, 90),
                const Offset(30, 75),
                const Offset(60, 80),
                const Offset(90, 60),
                const Offset(120, 65),
                const Offset(150, 45),
                const Offset(180, 50),
                const Offset(210, 35),
                const Offset(240, 30),
                const Offset(270, 20),
                const Offset(300, 15),
              ]);

    // Scale to current canvas width and height
    const double svgW = 300.0;
    const double svgH = 110.0;
    final double scaleX = size.width / svgW;
    final double scaleY = size.height / svgH;

    final List<Offset> scaledPoints = rawSvgPoints
        .map((p) => Offset(p.dx * scaleX, p.dy * scaleY))
        .toList();

    final double currentMaxX = size.width * progress;
    final List<Offset> currentPoints = [];

    for (int i = 0; i < scaledPoints.length; i++) {
      if (scaledPoints[i].dx <= currentMaxX) {
        currentPoints.add(scaledPoints[i]);
      } else {
        if (i > 0) {
          final pPrev = scaledPoints[i - 1];
          final pNext = scaledPoints[i];
          final t = (currentMaxX - pPrev.dx) / (pNext.dx - pPrev.dx);
          final interpolatedY = pPrev.dy + (pNext.dy - pPrev.dy) * t;
          currentPoints.add(Offset(currentMaxX, interpolatedY));
        }
        break;
      }
    }

    if (currentPoints.isEmpty) return;

    // 1. Draw subtle background horizontal guidelines
    final gridPaint = Paint()
      ..color = const Color(0x0F6366F1)
      ..strokeWidth = 1.0;
    canvas.drawLine(
        Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), gridPaint);
    canvas.drawLine(
        Offset(0, size.height * 0.65), Offset(size.width, size.height * 0.65), gridPaint);

    // 2. Build line path (exact straight segments as in demo video)
    final path = Path()..moveTo(currentPoints[0].dx, currentPoints[0].dy);
    for (int i = 1; i < currentPoints.length; i++) {
      path.lineTo(currentPoints[i].dx, currentPoints[i].dy);
    }

    // 3. Build Area Path underneath for purple gradient fill
    final areaPath = Path.from(path)
      ..lineTo(currentPoints.last.dx, size.height)
      ..lineTo(currentPoints.first.dx, size.height)
      ..close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF5227FF).withValues(alpha: 0.40 * progress),
          const Color(0xFF5227FF).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(areaPath, areaPaint);

    // 4. Draw the glowing purple line
    final linePaint = Paint()
      ..color = const Color(0xFF7B5CFF)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // 5. Glowing head dot at currentMaxX
    final headPoint = currentPoints.last;
    final dotRadius = 4.0 + (pulse * 1.0);

    // Outer aura glow
    canvas.drawCircle(
      headPoint,
      dotRadius + 4,
      Paint()
        ..color = const Color(0xFF7B5CFF).withValues(alpha: 0.3 + pulse * 0.25),
    );

    // Inner bright dot
    canvas.drawCircle(
      headPoint,
      dotRadius,
      Paint()..color = const Color(0xFF9E86FF),
    );

    // Core white center
    canvas.drawCircle(
      headPoint,
      2.0,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_TrendChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pulse != pulse;
  }
}

// ── 2. ANIMATED HEXAGON RADAR PROFICIENCY CHART ──
class AnimatedRadarChart extends StatefulWidget {
  const AnimatedRadarChart({super.key});

  @override
  State<AnimatedRadarChart> createState() => _AnimatedRadarChartState();
}

class _AnimatedRadarChartState extends State<AnimatedRadarChart>
    with TickerProviderStateMixin {
  late AnimationController _bloomController;
  late AnimationController _pulseController;
  late Animation<double> _bloomAnimation;

  @override
  void initState() {
    super.initState();
    // 1. Radar polygon bloom expansion on open (from center 0,0 out to full shape)
    _bloomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _bloomAnimation = CurvedAnimation(
      parent: _bloomController,
      curve: Curves.easeOutBack,
    );

    // 2. Subtle living pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _bloomController.forward();
    });
  }

  @override
  void dispose() {
    _bloomController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bloomAnimation, _pulseController]),
      builder: (context, _) {
        return CustomPaint(
          painter: _HexagonRadarPainter(
            bloom: _bloomAnimation.value,
            pulse: _pulseController.value,
          ),
          size: const Size(200, 110),
        );
      },
    );
  }
}

class _HexagonRadarPainter extends CustomPainter {
  final double bloom;
  final double pulse;

  _HexagonRadarPainter({
    required this.bloom,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Center point inside viewBox 200 x 110 (demo uses translate(100, 60))
    final center = Offset(size.width / 2, size.height / 2 + 5);

    // ── 1. Draw 3 Concentric Hexagon Background Rings from placeprep-demo.html ──
    // points:
    // Outer:  0,-50  43,-25  43,25  0,50  -43,25  -43,-25
    // Middle: 0,-35  30,-18  30,18  0,35  -30,18  -30,-18
    // Inner:  0,-20  17,-10  17,10  0,20  -17,10  -17,-10
    final ringPaint = Paint()
      ..color = const Color(0x1F6366F1) // rgba(99,102,241,0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const ringPointsList = [
      [
        Offset(0, -50),
        Offset(43, -25),
        Offset(43, 25),
        Offset(0, 50),
        Offset(-43, 25),
        Offset(-43, -25),
      ],
      [
        Offset(0, -35),
        Offset(30, -18),
        Offset(30, 18),
        Offset(0, 35),
        Offset(-30, 18),
        Offset(-30, -18),
      ],
      [
        Offset(0, -20),
        Offset(17, -10),
        Offset(17, 10),
        Offset(0, 20),
        Offset(-17, 10),
        Offset(-17, -10),
      ],
    ];

    for (final ring in ringPointsList) {
      final ringPath = Path()..moveTo(center.dx + ring[0].dx, center.dy + ring[0].dy);
      for (int i = 1; i < ring.length; i++) {
        ringPath.lineTo(center.dx + ring[i].dx, center.dy + ring[i].dy);
      }
      ringPath.close();
      canvas.drawPath(ringPath, ringPaint);
    }

    // ── 2. Draw Blooming Purple Radar Polygon ──
    // Target points in placeprep-demo.html:
    // points="0,-42 36,-14 30,22 0,38 -38,18 -32,-20"
    const targetPoints = [
      Offset(0, -42),
      Offset(36, -14),
      Offset(30, 22),
      Offset(0, 38),
      Offset(-38, 18),
      Offset(-32, -20),
    ];

    final double effectiveBloom = bloom.clamp(0.0, 1.08);
    final List<Offset> currentRadarPoints = [];

    for (final pt in targetPoints) {
      final currentX = center.dx + pt.dx * effectiveBloom + (pulse * 1.0 * (pt.dx / 40));
      final currentY = center.dy + pt.dy * effectiveBloom + (pulse * 1.0 * (pt.dy / 40));
      currentRadarPoints.add(Offset(currentX, currentY));
    }

    if (currentRadarPoints.isNotEmpty) {
      final radarPath = Path()
        ..moveTo(currentRadarPoints[0].dx, currentRadarPoints[0].dy);
      for (int i = 1; i < currentRadarPoints.length; i++) {
        radarPath.lineTo(currentRadarPoints[i].dx, currentRadarPoints[i].dy);
      }
      radarPath.close();

      // Radar Fill: rgba(139,92,246,0.18)
      final fillPaint = Paint()
        ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.18 + pulse * 0.05)
        ..style = PaintingStyle.fill;
      canvas.drawPath(radarPath, fillPaint);

      // Radar Border: #8B5CF6, stroke-width: 2
      final borderPaint = Paint()
        ..color = const Color(0xFF8B5CF6)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawPath(radarPath, borderPaint);

      // ── 3. Vertex Dots from demo ──
      // <circle cx="..." cy="..." r="3" fill="var(--prp)"/>
      for (final pt in currentRadarPoints) {
        // Subtle outer glow
        canvas.drawCircle(
          pt,
          5.0,
          Paint()..color = const Color(0xFF8B5CF6).withValues(alpha: 0.35),
        );
        // Purple node
        canvas.drawCircle(
          pt,
          3.0,
          Paint()..color = const Color(0xFF8B5CF6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_HexagonRadarPainter oldDelegate) {
    return oldDelegate.bloom != bloom || oldDelegate.pulse != pulse;
  }
}

// ── 3. ANIMATED DONUT ACCURACY BREAKDOWN CHART ──
class AnimatedDonutChart extends StatefulWidget {
  final double accuracy;
  final int correctCount;
  final int incorrectCount;
  final double size;

  const AnimatedDonutChart({
    super.key,
    required this.accuracy,
    required this.correctCount,
    required this.incorrectCount,
    this.size = 110.0,
  });

  @override
  State<AnimatedDonutChart> createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart>
    with TickerProviderStateMixin {
  late AnimationController _sweepController;
  late AnimationController _pulseController;
  late Animation<double> _sweepAnimation;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _sweepAnimation = CurvedAnimation(
      parent: _sweepController,
      curve: Curves.easeOutCubic,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _sweepController.forward();
    });
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_sweepAnimation, _pulseController]),
      builder: (context, _) {
        final currentPct = (_sweepAnimation.value * widget.accuracy).round();
        return Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _DonutChartPainter(
                progress: _sweepAnimation.value,
                pulse: _pulseController.value,
                accuracy: widget.accuracy,
                correctCount: widget.correctCount,
                incorrectCount: widget.incorrectCount,
              ),
            ),
            Text(
              '$currentPct%',
              style: GoogleFonts.firaCode(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.green,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double progress;
  final double pulse;
  final double accuracy;
  final int correctCount;
  final int incorrectCount;

  _DonutChartPainter({
    required this.progress,
    required this.pulse,
    required this.accuracy,
    required this.correctCount,
    required this.incorrectCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeW = 14.0;
    final radius = (size.width - strokeW) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Dark base track (unfilled / wrong background)
    final bgPaint = Paint()
      ..color = AppColors.red.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW;
    canvas.drawArc(rect, 0, 2 * pi, false, bgPaint);

    // 2. Animated correct green arc
    final totalRatio = (accuracy / 100.0).clamp(0.0, 1.0);
    final currentSweep = 2 * pi * totalRatio * progress;

    if (currentSweep > 0.01) {
      final greenPaint = Paint()
        ..color = AppColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round;

      // Glow behind green arc
      final glowPaint = Paint()
        ..color = AppColors.green.withValues(alpha: 0.15 + pulse * 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW + 4;
      canvas.drawArc(rect, -pi / 2, currentSweep, false, glowPaint);
      canvas.drawArc(rect, -pi / 2, currentSweep, false, greenPaint);

      // Trailing bright head node
      final endAngle = -pi / 2 + currentSweep;
      final headX = center.dx + radius * cos(endAngle);
      final headY = center.dy + radius * sin(endAngle);
      final headPt = Offset(headX, headY);

      canvas.drawCircle(
        headPt,
        4.0,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pulse != pulse;
  }
}

// ── 4. ANIMATED PROGRESS BAR WITH DYNAMIC COUNT-UP ──
class AnimatedProgressBar extends StatefulWidget {
  final double percentage;
  final Color color;
  final double minHeight;
  final Duration delay;
  final Duration duration;

  const AnimatedProgressBar({
    super.key,
    required this.percentage,
    required this.color,
    this.minHeight = 6.0,
    this.delay = const Duration(milliseconds: 300),
    this.duration = const Duration(milliseconds: 1100),
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final val = ((widget.percentage / 100) * _animation.value).clamp(0.0, 1.0);
        return LayoutBuilder(
          builder: (context, constraints) {
            final totalW = constraints.maxWidth;
            final fillW = totalW * val;

            return Container(
              height: widget.minHeight,
              width: totalW,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(widget.minHeight / 2),
              ),
              child: Stack(
                children: [
                  Container(
                    width: fillW,
                    height: widget.minHeight,
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(widget.minHeight / 2),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.35 * _animation.value),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── 5. ANIMATED SECTION ROW (Label, dynamic %, and animated bar) ──
class AnimatedSectionBar extends StatefulWidget {
  final String label;
  final double percentage;
  final Color color;
  final Duration delay;

  const AnimatedSectionBar({
    super.key,
    required this.label,
    required this.percentage,
    required this.color,
    this.delay = const Duration(milliseconds: 400),
  });

  @override
  State<AnimatedSectionBar> createState() => _AnimatedSectionBarState();
}

class _AnimatedSectionBarState extends State<AnimatedSectionBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final currentPct = (_animation.value * widget.percentage).round();

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '$currentPct%',
                    style: GoogleFonts.firaCode(
                      fontSize: 11,
                      color: AppColors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              AnimatedProgressBar(
                percentage: widget.percentage,
                color: widget.color,
                minHeight: 6,
                delay: widget.delay,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── 6. ANIMATED DIFFICULTY TRACK (Easy / Med / Hard) ──
class AnimatedDiffTrack extends StatefulWidget {
  final String label;
  final double percentage;
  final Color color;
  final Duration delay;

  const AnimatedDiffTrack({
    super.key,
    required this.label,
    required this.percentage,
    required this.color,
    this.delay = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedDiffTrack> createState() => _AnimatedDiffTrackState();
}

class _AnimatedDiffTrackState extends State<AnimatedDiffTrack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final currentPct = (_animation.value * widget.percentage).round();

        return Column(
          children: [
            Text(widget.label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            AnimatedProgressBar(
              percentage: widget.percentage,
              color: widget.color,
              minHeight: 6,
              delay: widget.delay,
            ),
            const SizedBox(height: 8),
            Text(
              '$currentPct%',
              style: GoogleFonts.firaCode(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}
