import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedCounter extends StatefulWidget {
  final int targetValue;
  final String suffix;
  final String label;
  final Color color;
  final Duration duration;
  final Duration delay;
  final bool isInfinity;

  const AnimatedCounter({
    super.key,
    required this.targetValue,
    this.suffix = '',
    required this.label,
    required this.color,
    this.duration = const Duration(milliseconds: 1800),
    this.delay = const Duration(milliseconds: 300),
    this.isInfinity = false,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Silky smooth deceleration curve matching original animCount step function
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            if (widget.isInfinity) {
              return Opacity(
                opacity: _animation.value.clamp(0.0, 1.0),
                child: Text(
                  '∞',
                  style: GoogleFonts.firaCode(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: widget.color,
                  ),
                ),
              );
            }

            final currentVal = (_animation.value * widget.targetValue).round();
            return Text(
              '$currentVal${widget.suffix}',
              style: GoogleFonts.firaCode(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: widget.color,
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          widget.label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: const Color(0xFF55557A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
