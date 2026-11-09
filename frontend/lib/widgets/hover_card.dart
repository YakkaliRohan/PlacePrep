import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Interactive card wrapper that provides subtle elevation lift,
/// border accent illumination, and cursor feedback on hover.
class HoverCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  final Color? hoverBorderColor;
  final double hoverTranslateY;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const HoverCard({
    super.key,
    required this.child,
    this.padding,
    this.decoration,
    this.hoverBorderColor,
    this.hoverTranslateY = -3.0,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final br = widget.borderRadius ?? BorderRadius.circular(14);
    final hoverColor = widget.hoverBorderColor ?? AppColors.accentLight;

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(
            0,
            _isHovered ? widget.hoverTranslateY : 0,
            0,
          ),
          padding: widget.padding,
          decoration: (widget.decoration ??
                  BoxDecoration(
                    color: AppColors.bg2,
                    borderRadius: br,
                    border: Border.all(color: AppColors.border),
                  ))
              .copyWith(
            borderRadius: br,
            border: Border.all(
              color: _isHovered
                  ? hoverColor.withValues(alpha: 0.6)
                  : (widget.decoration?.border as Border?)?.top.color ?? AppColors.border,
              width: _isHovered ? 1.4 : 1.0,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: hoverColor.withValues(alpha: 0.12),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
