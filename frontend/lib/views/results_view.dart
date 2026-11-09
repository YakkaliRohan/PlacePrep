import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../widgets/animated_charts.dart';
import '../widgets/hover_card.dart';

class ResultsView extends StatefulWidget {
  final TestResultModel result;
  final VoidCallback onBackToDashboard;

  const ResultsView({
    super.key,
    required this.result,
    required this.onBackToDashboard,
  });

  @override
  State<ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends State<ResultsView> with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: const BoxDecoration(
            color: AppColors.bg2,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('📊', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Test Report',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      Text(
                        '${result.testTitle} · Today',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: widget.onBackToDashboard,
                    child: const Text('Dashboard',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. STAGGERED ENTRANCE 5 SCORE KPI CARDS ──
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = (constraints.maxWidth - (12 * 4)) / 5;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildAnimatedKpi(
                          index: 0,
                          cardWidth: cardWidth,
                          child: _buildCounterKpiCard(
                            title: 'Score',
                            targetValue: result.accuracy.round(),
                            suffix: '%',
                            sub: 'Grade: A',
                            color: AppColors.green,
                          ),
                        ),
                        _buildAnimatedKpi(
                          index: 1,
                          cardWidth: cardWidth,
                          child: _buildCorrectKpiCard(
                            title: 'Correct',
                            correctCount: result.correctCount,
                            totalQuestions: result.totalQuestions,
                            sub: '${result.correctCount + result.incorrectCount} att.',
                            color: AppColors.accentLight,
                          ),
                        ),
                        _buildAnimatedKpi(
                          index: 2,
                          cardWidth: cardWidth,
                          child: _buildCounterKpiCard(
                            title: 'Percentile',
                            targetValue: 84,
                            suffix: 'th',
                            sub: 'est.',
                            color: AppColors.purple,
                          ),
                        ),
                        _buildAnimatedKpi(
                          index: 3,
                          cardWidth: cardWidth,
                          child: _buildStaticKpiCard(
                            title: 'Time',
                            value: _formatTime(result.timeTakenSeconds),
                            sub:
                                '${result.timeTakenSeconds ~/ (result.totalQuestions > 0 ? result.totalQuestions : 1)}s/q avg',
                            color: AppColors.yellow,
                          ),
                        ),
                        _buildAnimatedKpi(
                          index: 4,
                          cardWidth: cardWidth,
                          child: _buildGradeKpiCard(
                            title: 'Grade',
                            grade: 'A',
                            sub: 'Strong',
                            color: AppColors.pink,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // ── 2. CHARTS ROW: ANIMATED DONUT + ANIMATED SECTION PERFORMANCE ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Donut Chart Card
                    Expanded(
                      child: HoverCard(
                        padding: const EdgeInsets.all(24),
                        hoverBorderColor: AppColors.green,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Accuracy Breakdown',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                AnimatedDonutChart(
                                  accuracy: result.accuracy,
                                  correctCount: result.correctCount,
                                  incorrectCount: result.incorrectCount,
                                  size: 110,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLegendRow('Correct (${result.correctCount})', AppColors.green),
                                    const SizedBox(height: 10),
                                    _buildLegendRow('Wrong (${result.incorrectCount})', AppColors.red),
                                    const SizedBox(height: 10),
                                    _buildLegendRow('Skip (${result.unattemptedCount})', AppColors.bg3),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Section Performance Card
                    Expanded(
                      child: HoverCard(
                        padding: const EdgeInsets.all(24),
                        hoverBorderColor: AppColors.accentLight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Section Performance',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 16),
                            if (result.sectionBreakdown.isEmpty) ...[
                              const AnimatedSectionBar(
                                label: '🧮 APTITUDE',
                                percentage: 85,
                                color: AppColors.yellow,
                                delay: Duration(milliseconds: 300),
                              ),
                              const AnimatedSectionBar(
                                label: '📝 VERBAL',
                                percentage: 76,
                                color: AppColors.accentLight,
                                delay: Duration(milliseconds: 500),
                              ),
                              const AnimatedSectionBar(
                                label: '🧩 LOGICAL',
                                percentage: 90,
                                color: AppColors.green,
                                delay: Duration(milliseconds: 700),
                              ),
                            ] else
                              ...result.sectionBreakdown.entries.toList().asMap().entries.map((item) {
                                final idx = item.key;
                                final e = item.value;
                                final acc = (e.value['accuracy'] as num?)?.toDouble() ?? 0.0;
                                return AnimatedSectionBar(
                                  label: e.key.toUpperCase(),
                                  percentage: acc,
                                  color: idx % 2 == 0 ? AppColors.accentLight : AppColors.green,
                                  delay: Duration(milliseconds: 300 + idx * 150),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── 3. ANIMATED DIFFICULTY BREAKDOWN CARD ──
                HoverCard(
                  padding: const EdgeInsets.all(24),
                  hoverBorderColor: AppColors.yellow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Difficulty Breakdown',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(
                            child: AnimatedDiffTrack(
                              label: 'Easy',
                              percentage: 95,
                              color: AppColors.green,
                              delay: Duration(milliseconds: 400),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: AnimatedDiffTrack(
                              label: 'Medium',
                              percentage: 78,
                              color: AppColors.yellow,
                              delay: Duration(milliseconds: 650),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: AnimatedDiffTrack(
                              label: 'Hard',
                              percentage: 52,
                              color: AppColors.red,
                              delay: Duration(milliseconds: 900),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── 4. DETAILED SOLUTIONS LIST WITH INTERACTIVE HOVER CARDS ──
                const Text(
                  'Detailed Solutions & Explanations',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: result.answersSummary.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, i) {
                    final item = result.answersSummary[i];
                    final isCorrect = item.isCorrect;

                    return HoverCard(
                      padding: const EdgeInsets.all(20),
                      hoverTranslateY: -2.0,
                      hoverBorderColor: isCorrect ? AppColors.green : AppColors.red,
                      decoration: BoxDecoration(
                        color: AppColors.bg2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCorrect
                              ? AppColors.green.withValues(alpha: 0.28)
                              : AppColors.red.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Question ${i + 1} • ${item.concept}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                      fontSize: 13)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isCorrect ? AppColors.greenGlow : AppColors.redGlow,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isCorrect ? 'CORRECT' : 'INCORRECT',
                                  style: TextStyle(
                                      color: isCorrect ? AppColors.green : AppColors.red,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(item.questionText,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 14),

                          // Correct Answer
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.greenGlow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.green, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Correct Answer: ${item.options[item.correctAnswer]}',
                                    style: const TextStyle(
                                        color: AppColors.green,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (item.explanation.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text('💡 ${item.explanation}',
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedKpi({
    required int index,
    required double cardWidth,
    required Widget child,
  }) {
    final start = (index * 0.12).clamp(0.0, 1.0);
    final end = (start + 0.5).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curve,
      builder: (context, _) {
        return Opacity(
          opacity: curve.value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1.0 - curve.value)),
            child: SizedBox(
              width: cardWidth,
              child: HoverCard(
                hoverBorderColor: AppColors.accentLight,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCounterKpiCard({
    required String title,
    required int targetValue,
    required String suffix,
    required String sub,
    required Color color,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: targetValue.toDouble()),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${val.round()}$suffix',
              style: GoogleFonts.firaCode(fontSize: 24, fontWeight: FontWeight.w700, color: color),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        );
      },
    );
  }

  Widget _buildCorrectKpiCard({
    required String title,
    required int correctCount,
    required int totalQuestions,
    required String sub,
    required Color color,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: correctCount.toDouble()),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${val.round()}/$totalQuestions',
              style: GoogleFonts.firaCode(fontSize: 24, fontWeight: FontWeight.w700, color: color),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        );
      },
    );
  }

  Widget _buildStaticKpiCard({
    required String title,
    required String value,
    required String sub,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: GoogleFonts.firaCode(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildGradeKpiCard({
    required String title,
    required String grade,
    required String sub,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(grade,
            style: GoogleFonts.firaCode(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildLegendRow(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
