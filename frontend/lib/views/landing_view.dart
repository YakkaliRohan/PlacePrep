import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_dialog.dart';
import '../widgets/interactive_dot_grid.dart';
import '../widgets/animated_counter.dart';

class LandingView extends StatefulWidget {
  final VoidCallback onEnterApp;

  const LandingView({super.key, required this.onEnterApp});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> with TickerProviderStateMixin {
  late AnimationController _colorFlowController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Slow, soothing gradient shift across the brand title
    _colorFlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);

    // Subtle living glow pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _colorFlowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: InteractiveDotGrid(
        child: SafeArea(
          child: Column(
            children: [
              // Top Navigation Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (auth.isLoggedIn)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        ),
                        onPressed: widget.onEnterApp,
                        child: Text(
                          'Go to Dashboard',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const AuthDialog(initialMode: 'login'),
                          );
                        },
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Hero Centered Content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // #1 Interview Prep Platform Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0x1F6366F1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0x406366F1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🚀', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 8),
                              Text(
                                '#1 Interview Prep Platform',
                                style: GoogleFonts.outfit(
                                  color: AppColors.accentLight,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Large Title: PlacePrep with Slow Living Color Flow & Perfect 'p' Glyph Rendering
                        AnimatedBuilder(
                          animation: _colorFlowController,
                          builder: (context, _) {
                            final progress = _colorFlowController.value;

                            return ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) {
                                // Extend bounds generously so 'p' descenders are 100% inside the gradient!
                                final rect = Rect.fromLTWH(0, -10, bounds.width, bounds.height + 40);

                                return LinearGradient(
                                  begin: Alignment(-1.2 + (progress * 0.4), -0.8),
                                  end: Alignment(1.2 + (progress * 0.4), 0.8),
                                  colors: const [
                                    Color(0xFF5227FF), // Electric Indigo
                                    Color(0xFF7B5CFF), // Violet
                                    Color(0xFFE040FB), // Neon Magenta
                                    Color(0xFFFF4C6A), // Coral Red
                                  ],
                                  stops: [
                                    0.0,
                                    0.28 + (progress * 0.08),
                                    0.62 + (progress * 0.08),
                                    1.0,
                                  ],
                                ).createShader(rect);
                              },
                              child: Text(
                                'PlacePrep',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 84,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -2.0,
                                  height: 1.25, // Extra height ensures descenders of 'p' never clip
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Subtitle
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 580),
                          child: Text(
                            'Master aptitude, reasoning, verbal & coding with company-pattern mock tests, real-time analytics, and adaptive learning.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              color: const Color(0xFF8B8BA7),
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Action Buttons: Get Started Free & Sign In
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            // Primary Button with Living Ambient Glow
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, _) {
                                return DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF5227FF).withValues(alpha: 0.35 + _pulseController.value * 0.25),
                                        blurRadius: 24 + _pulseController.value * 14,
                                        spreadRadius: _pulseController.value * 1.5,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5227FF),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                                ),
                                onPressed: () {
                                  if (auth.isLoggedIn) {
                                    widget.onEnterApp();
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (_) => const AuthDialog(initialMode: 'signup'),
                                    );
                                  }
                                },
                                child: Text(
                                  'Get Started Free',
                                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                              ),
                            );
                          },
                        ),

                            // Secondary Dark Button
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0x0AFFFFFF),
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(color: Color(0x26FFFFFF)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => const AuthDialog(initialMode: 'login'),
                                );
                              },
                              child: Text(
                                'Sign In',
                                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 56),

                        // Live Counting Animated Stats Row
                        Wrap(
                          spacing: 48,
                          runSpacing: 20,
                          alignment: WrapAlignment.center,
                          children: const [
                            AnimatedCounter(
                              targetValue: 500,
                              suffix: '+',
                              label: 'Questions',
                              color: Color(0xFF7B5CFF),
                              duration: Duration(milliseconds: 1800),
                              delay: Duration(milliseconds: 300),
                            ),
                            AnimatedCounter(
                              targetValue: 8,
                              label: 'Company Tests',
                              color: Color(0xFF7B5CFF),
                              duration: Duration(milliseconds: 1400),
                              delay: Duration(milliseconds: 400),
                            ),
                            AnimatedCounter(
                              targetValue: 5,
                              label: 'Topics',
                              color: Color(0xFF7B5CFF),
                              duration: Duration(milliseconds: 1200),
                              delay: Duration(milliseconds: 500),
                            ),
                            AnimatedCounter(
                              targetValue: 0,
                              label: 'Practice',
                              color: Color(0xFF7B5CFF),
                              isInfinity: true,
                              delay: Duration(milliseconds: 600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
