import 'package:flutter/material.dart';

/// Displays the lesson concept text for an item before the question is shown.
///
/// The concept text is formatted with a header and scrollable body, and
/// includes a "Continue to Question" CTA at the bottom.
class ConceptCard extends StatelessWidget {
  const ConceptCard({
    super.key,
    required this.conceptText,
    required this.questionNumber,
    required this.totalQuestions,
    required this.difficultyLevel,
    required this.onContinue,
  });

  final String conceptText;
  final int questionNumber;
  final int totalQuestions;
  final int difficultyLevel;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        _LessonHeader(
          questionNumber: questionNumber,
          totalQuestions: totalQuestions,
          label: 'Learn',
          accentColor: _levelColor(difficultyLevel),
        ),
        const SizedBox(height: 16),

        // ── Concept card ─────────────────────────────────────────────────────
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _levelColor(difficultyLevel).withAlpha(80),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Colored top bar
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: _levelColor(difficultyLevel),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        color: _levelColor(difficultyLevel),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Lesson Concept',
                        style: tt.labelLarge?.copyWith(
                          color: _levelColor(difficultyLevel),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      conceptText,
                      style: tt.bodyMedium?.copyWith(
                        height: 1.65,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── CTA button ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FilledButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.quiz_rounded),
            label: const Text('Continue to Question'),
            style: FilledButton.styleFrom(
              backgroundColor: _levelColor(difficultyLevel),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Question card ────────────────────────────────────────────────────────────

/// Displays the MCQ question with 4 answer options.
/// Once submitted, options are colour-coded correct/incorrect.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.questionText,
    required this.options,
    required this.questionNumber,
    required this.totalQuestions,
    required this.difficultyLevel,
    this.selectedAnswer,
    this.correctAnswer,
    required this.onOptionSelected,
    required this.onNext,
  });

  final String questionText;
  final List<String> options;
  final int questionNumber;
  final int totalQuestions;
  final int difficultyLevel;
  final String? selectedAnswer;
  final String? correctAnswer;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback onNext;

  bool get _hasAnswered => selectedAnswer != null;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isCorrect = selectedAnswer == correctAnswer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        _LessonHeader(
          questionNumber: questionNumber,
          totalQuestions: totalQuestions,
          label: 'Question',
          accentColor: _levelColor(difficultyLevel),
        ),
        const SizedBox(height: 16),

        // ── Question bubble ──────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            questionText,
            style: tt.titleMedium?.copyWith(height: 1.5),
          ),
        ),
        const SizedBox(height: 16),

        // ── Answer options ───────────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: options.length,
            separatorBuilder: (_, i2) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final option = options[i];
              return _OptionTile(
                text: option,
                index: i,
                isSelected: selectedAnswer == option,
                isCorrect: correctAnswer == option,
                hasAnswered: _hasAnswered,
                onTap: _hasAnswered ? null : () => onOptionSelected(option),
              );
            },
          ),
        ),

        // ── Feedback + Next button ────────────────────────────────────────────
        if (_hasAnswered) ...[
          _FeedbackBanner(isCorrect: isCorrect),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: FilledButton.icon(
              onPressed: onNext,
              icon: Icon(isCorrect
                  ? Icons.arrow_forward_rounded
                  : Icons.refresh_rounded),
              label: Text(isCorrect ? 'Next' : 'Got it'),
              style: FilledButton.styleFrom(
                backgroundColor:
                    isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ] else
          const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Shared subwidgets ────────────────────────────────────────────────────────

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({
    required this.questionNumber,
    required this.totalQuestions,
    required this.label,
    required this.accentColor,
  });

  final int questionNumber;
  final int totalQuestions;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
              ),
              Text(
                '$questionNumber / $totalQuestions',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: questionNumber / totalQuestions,
              minHeight: 5,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.hasAnswered,
    required this.onTap,
  });

  final String text;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool hasAnswered;
  final VoidCallback? onTap;

  static const _labels = ['A', 'B', 'C', 'D'];

  Color _tileColor(ColorScheme cs) {
    if (!hasAnswered) {
      return isSelected
          ? cs.primaryContainer
          : cs.surfaceContainerHigh;
    }
    if (isCorrect) return const Color(0xFF1B5E20).withAlpha(200);
    if (isSelected && !isCorrect) return const Color(0xFFB71C1C).withAlpha(180);
    return cs.surfaceContainerHigh.withAlpha(120);
  }

  Color _borderColor(ColorScheme cs) {
    if (!hasAnswered) {
      return isSelected ? cs.primary : cs.outline.withAlpha(60);
    }
    if (isCorrect) return const Color(0xFF4CAF50);
    if (isSelected && !isCorrect) return const Color(0xFFEF5350);
    return cs.outline.withAlpha(40);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _tileColor(cs),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor(cs), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withAlpha(120),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _labels[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                  ),
                ),
                if (hasAnswered && isCorrect)
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF4CAF50), size: 20),
                if (hasAnswered && isSelected && !isCorrect)
                  const Icon(Icons.cancel_rounded,
                      color: Color(0xFFEF5350), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.isCorrect});

  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCorrect
            ? const Color(0xFF1B5E20).withAlpha(180)
            : const Color(0xFFB71C1C).withAlpha(160),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(
            isCorrect ? 'Correct! Promoted to Apprentice 1 🎉' : 'Incorrect — review the concept again.',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Color _levelColor(int level) => switch (level) {
      1 => const Color(0xFF5E6AD2),
      2 => const Color(0xFF0EA5E9),
      3 => const Color(0xFF10B981),
      4 => const Color(0xFFF59E0B),
      _ => const Color(0xFFEF4444),
    };
