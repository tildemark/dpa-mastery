import 'package:flutter/material.dart';

import '../../engine/srs_engine.dart';
import 'review_provider.dart';

/// MCQ card for Reviews Mode. Unlike Lessons, there is no concept card —
/// the user goes directly to the question, then sees feedback + explanation.
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.item,
    required this.questionNumber,
    required this.totalQuestions,
    this.selectedAnswer,
    this.newStage,
    required this.onOptionSelected,
    required this.onNext,
  });

  final ReviewItem item;
  final int questionNumber;
  final int totalQuestions;
  final String? selectedAnswer;
  final int? newStage; // Set after answering
  final ValueChanged<String> onOptionSelected;
  final VoidCallback onNext;

  bool get _hasAnswered => selectedAnswer != null;
  bool get _isCorrect => selectedAnswer == item.question.correctAnswer;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final stageColor = _stageColor(item.progress.srsStage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        _ReviewHeader(
          questionNumber: questionNumber,
          totalQuestions: totalQuestions,
          currentStage: item.progress.srsStage,
          stageColor: stageColor,
        ),
        const SizedBox(height: 16),

        // ── Question bubble ──────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: stageColor.withAlpha(60),
              width: 1.5,
            ),
          ),
          child: Text(
            item.question.questionText,
            style: tt.titleMedium?.copyWith(height: 1.5),
          ),
        ),
        const SizedBox(height: 14),

        // ── Answer options ───────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: item.options.length,
            itemBuilder: (context, i) {
              final option = item.options[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ReviewOptionTile(
                  text: option,
                  index: i,
                  isSelected: selectedAnswer == option,
                  isCorrect: item.question.correctAnswer == option,
                  hasAnswered: _hasAnswered,
                  onTap: _hasAnswered ? null : () => onOptionSelected(option),
                ),
              );
            },
          ),
        ),

        // ── Feedback (explanation + stage shift) ─────────────────────────────
        if (_hasAnswered) ...[
          _ReviewFeedback(
            isCorrect: _isCorrect,
            explanation: item.question.explanation,
            fromStage: item.progress.srsStage,
            toStage: newStage ?? item.progress.srsStage,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Next'),
              style: FilledButton.styleFrom(
                backgroundColor: _isCorrect
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFEF5350),
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

// ─── Header ───────────────────────────────────────────────────────────────────

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({
    required this.questionNumber,
    required this.totalQuestions,
    required this.currentStage,
    required this.stageColor,
  });

  final int questionNumber;
  final int totalQuestions;
  final int currentStage;
  final Color stageColor;

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
              // Stage badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stageColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: stageColor.withAlpha(80)),
                ),
                child: Text(
                  SrsEngine.stageLabel(currentStage),
                  style: TextStyle(
                    color: stageColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
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
              valueColor: AlwaysStoppedAnimation<Color>(stageColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Option tile ──────────────────────────────────────────────────────────────

class _ReviewOptionTile extends StatelessWidget {
  const _ReviewOptionTile({
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
    if (!hasAnswered) return isSelected ? cs.primaryContainer : cs.surfaceContainerHigh;
    if (isCorrect) return const Color(0xFF1B5E20).withAlpha(200);
    if (isSelected && !isCorrect) return const Color(0xFFB71C1C).withAlpha(180);
    return cs.surfaceContainerHigh.withAlpha(120);
  }

  Color _borderColor(ColorScheme cs) {
    if (!hasAnswered) return isSelected ? cs.primary : cs.outline.withAlpha(60);
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
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.4),
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

// ─── Feedback panel ───────────────────────────────────────────────────────────

/// Shows the explanation and stage transition after an answer is submitted.
class _ReviewFeedback extends StatelessWidget {
  const _ReviewFeedback({
    required this.isCorrect,
    required this.explanation,
    required this.fromStage,
    required this.toStage,
  });

  final bool isCorrect;
  final String explanation;
  final int fromStage;
  final int toStage;

  String get _stageShiftLabel {
    if (toStage > fromStage) {
      return '${SrsEngine.stageLabel(fromStage)} → ${SrsEngine.stageLabel(toStage)} ↑';
    } else if (toStage < fromStage) {
      return '${SrsEngine.stageLabel(fromStage)} → ${SrsEngine.stageLabel(toStage)} ↓';
    }
    return SrsEngine.stageLabel(toStage);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final bgColor = isCorrect
        ? const Color(0xFF1B5E20).withAlpha(160)
        : const Color(0xFFB71C1C).withAlpha(140);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stage shift banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: (isCorrect
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFEF5350)).withAlpha(60),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Icon(
                  isCorrect
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _stageShiftLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Explanation
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              explanation,
              style: tt.bodySmall?.copyWith(
                color: Colors.white.withAlpha(220),
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Color _stageColor(int stage) => switch (stage) {
      0 => const Color(0xFF78909C),
      1 || 2 || 3 || 4 => const Color(0xFFEF5350), // Apprentice — red/pink
      5 || 6 => const Color(0xFF7C4DFF),             // Guru — purple
      7 => const Color(0xFF1565C0),                  // Master — blue
      _ => const Color(0xFF37474F),                  // Burned — dark grey
    };
