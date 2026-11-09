import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../providers/exam_provider.dart';

class ExamView extends StatelessWidget {
  final VoidCallback onFinish;

  const ExamView({super.key, required this.onFinish});

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final exam = context.watch<ExamProvider>();
    final q = exam.currentQuestion;

    if (!exam.isExamActive || q == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isWide = MediaQuery.of(context).size.width >= 900;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _confirmExit(context, exam);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: _buildTopBar(context, exam),
        body: Row(
          children: [
            // Left Main Question Area
            Expanded(
              flex: 7,
              child: _buildQuestionArea(context, exam, q),
            ),

            // Right Navigator Sidebar
            if (isWide) ...[
              Container(width: 1, color: AppColors.border),
              SizedBox(
                width: 280,
                child: _buildNavigatorPanel(context, exam),
              ),
            ],
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context, ExamProvider exam) {
    final isWarn = exam.remainingSeconds < 120;

    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color: AppColors.bg2,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left exit + test title + warning badge
            Row(
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () => _confirmExit(context, exam),
                  child: const Text('← Exit', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ),
                const SizedBox(width: 14),
                Text(
                  exam.testTitle,
                  style: GoogleFonts.firaCode(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentLight,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.redGlow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '⚠ Cannot go back',
                    style: TextStyle(color: AppColors.red, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            // Right Timer + Progress + Navigator Toggle + Submit
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isWarn ? AppColors.redGlow : AppColors.bg3,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isWarn ? AppColors.red.withValues(alpha: 0.5) : AppColors.border),
                  ),
                  child: Text(
                    _formatTime(exam.remainingSeconds),
                    style: GoogleFonts.firaCode(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isWarn ? AppColors.red : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  '${exam.currentIndex + 1}/${exam.questions.length}',
                  style: GoogleFonts.firaCode(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () => _confirmSubmit(context, exam),
                  child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionArea(BuildContext context, ExamProvider exam, QuestionModel q) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Q Number
          Text(
            'Q${exam.currentIndex + 1} / ${exam.questions.length}',
            style: GoogleFonts.firaCode(
              fontSize: 12,
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),

          // Badges: Medium + Topic
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.yellowGlow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  q.difficulty,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.yellow),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentGlow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  q.topic.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accentLight),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Question Text
          Text(
            q.questionText,
            style: const TextStyle(
              fontSize: 16,
              height: 1.75,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),

          // Options List
          Expanded(
            child: ListView.separated(
              itemCount: q.options.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final isSelected = exam.currentAnswer == i;
                final letter = String.fromCharCode(65 + i);

                return _InteractiveOptionTile(
                  letter: letter,
                  text: q.options[i],
                  isSelected: isSelected,
                  onTap: () => exam.selectOption(i),
                );
              },
            ),
          ),

          // Bottom Prev / Next Nav
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: exam.currentIndex > 0 ? exam.prevQuestion : null,
                child: const Text('← Prev', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () {
                  if (exam.currentIndex < exam.questions.length - 1) {
                    exam.nextQuestion();
                  } else {
                    _confirmSubmit(context, exam);
                  }
                },
                child: Text(
                  exam.currentIndex < exam.questions.length - 1 ? 'Next →' : 'Review & Submit →',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigatorPanel(BuildContext context, ExamProvider exam) {
    return Container(
      color: AppColors.bg2,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Navigator',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),

          // Grid
          Expanded(
            child: GridView.builder(
              itemCount: exam.questions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemBuilder: (context, i) {
                final isCurrent = exam.currentIndex == i;
                final isAnswered = exam.isQuestionAnswered(i);
                final isFlagged = exam.isQuestionFlagged(i);

                return _InteractivePaletteTile(
                  number: i + 1,
                  isCurrent: isCurrent,
                  isAnswered: isAnswered,
                  isFlagged: isFlagged,
                  onTap: () => exam.goToQuestion(i),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),

          // Legend
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✅ Answered: ${exam.answeredCount}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Text('🚩 Flagged: ${exam.flaggedCount}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Text('⬜ Unanswered: ${exam.questions.length - exam.answeredCount}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmSubmit(BuildContext context, ExamProvider exam) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Submit Test?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'You answered ${exam.answeredCount} out of ${exam.questions.length} questions. Would you like to finalize and view your report?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to Test', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
            onPressed: () async {
              Navigator.of(context).pop();
              await exam.submitExam();
              onFinish();
            },
            child: const Text('Submit Now'),
          ),
        ],
      ),
    );
  }

  void _confirmExit(BuildContext context, ExamProvider exam) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: const Text('Exit Test?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Your progress in this test will be lost if you leave without submitting.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Stay', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () {
              Navigator.of(context).pop();
              exam.resetExam();
              onFinish();
            },
            child: const Text('Exit Anyway'),
          ),
        ],
      ),
    );
  }
}

class _InteractiveOptionTile extends StatefulWidget {
  final String letter;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _InteractiveOptionTile({
    required this.letter,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_InteractiveOptionTile> createState() => _InteractiveOptionTileState();
}

class _InteractiveOptionTileState extends State<_InteractiveOptionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(_isHovered ? 4.0 : 0.0, 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0x1400D68F)
                : (_isHovered ? const Color(0x1F6366F1) : AppColors.bg2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFF00D68F)
                  : (_isHovered ? AppColors.accentLight : AppColors.border),
              width: widget.isSelected ? 1.6 : 1.0,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.green.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : (_isHovered
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : []),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.green
                      : (_isHovered ? AppColors.accent : AppColors.bg3),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.letter,
                  style: GoogleFonts.firaCode(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: widget.isSelected || _isHovered
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.isSelected ? AppColors.green : AppColors.textPrimary,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
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

class _InteractivePaletteTile extends StatefulWidget {
  final int number;
  final bool isCurrent;
  final bool isAnswered;
  final bool isFlagged;
  final VoidCallback onTap;

  const _InteractivePaletteTile({
    required this.number,
    required this.isCurrent,
    required this.isAnswered,
    required this.isFlagged,
    required this.onTap,
  });

  @override
  State<_InteractivePaletteTile> createState() => _InteractivePaletteTileState();
}

class _InteractivePaletteTileState extends State<_InteractivePaletteTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.bg3;
    Color text = AppColors.textMuted;
    Color border = AppColors.border;

    if (widget.isCurrent) {
      bg = AppColors.accent;
      text = Colors.white;
      border = AppColors.accentLight;
    } else if (widget.isFlagged) {
      bg = AppColors.yellowGlow;
      text = AppColors.yellow;
      border = AppColors.yellow.withValues(alpha: 0.4);
    } else if (widget.isAnswered) {
      bg = AppColors.greenGlow;
      text = AppColors.green;
      border = AppColors.green.withValues(alpha: 0.4);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: _isHovered ? border.withValues(alpha: 0.25) : bg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _isHovered ? AppColors.accentLight : border,
                width: _isHovered ? 1.5 : 1.0,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: border.withValues(alpha: 0.35),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            alignment: Alignment.center,
            child: Text(
              '${widget.number}',
              style: GoogleFonts.firaCode(fontSize: 11, fontWeight: FontWeight.w700, color: text),
            ),
          ),
        ),
      ),
    );
  }
}
