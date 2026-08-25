import 'package:flutter/material.dart';

import '../../engine/srs_engine.dart';
import 'review_provider.dart';

/// Post-session summary screen.
///
/// Shows correct/incorrect counts, accuracy percentage, and a breakdown
/// of stage transitions that occurred during the session.
class ReviewSummaryScreen extends StatelessWidget {
  const ReviewSummaryScreen({
    super.key,
    required this.results,
    required this.totalItems,
  });

  final List<ReviewResult> results;
  final int totalItems;

  int get _correctCount => results.where((r) => r.wasCorrect).length;
  int get _incorrectCount => results.where((r) => !r.wasCorrect).length;
  double get _accuracy =>
      results.isEmpty ? 0 : _correctCount / results.length;

  // Group stage transitions for the summary.
  List<ReviewResult> get _promotions =>
      results.where((r) => r.toStage > r.fromStage).toList();
  List<ReviewResult> get _demotions =>
      results.where((r) => r.toStage < r.fromStage).toList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isPerfect = _incorrectCount == 0;
    final accentColor =
        isPerfect ? const Color(0xFF4CAF50) : const Color(0xFF5E6AD2);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // ── Icon ──────────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withAlpha(30),
                    border: Border.all(color: accentColor, width: 2),
                  ),
                  child: Icon(
                    isPerfect
                        ? Icons.military_tech_rounded
                        : Icons.task_alt_rounded,
                    size: 48,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ─────────────────────────────────────────────────────
              Text(
                isPerfect ? 'Perfect Session! 🎉' : 'Session Complete',
                textAlign: TextAlign.center,
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You reviewed $totalItems item${totalItems == 1 ? '' : 's'}.',
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),

              // ── Stats row ─────────────────────────────────────────────────
              Row(
                children: [
                  _StatCard(
                    label: 'Correct',
                    value: '$_correctCount',
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    label: 'Incorrect',
                    value: '$_incorrectCount',
                    icon: Icons.cancel_rounded,
                    color: const Color(0xFFEF5350),
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    label: 'Accuracy',
                    value: '${(_accuracy * 100).round()}%',
                    icon: Icons.percent_rounded,
                    color: accentColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Stage transitions ─────────────────────────────────────────
              if (_promotions.isNotEmpty || _demotions.isNotEmpty) ...[
                Text(
                  'Stage Changes',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (_promotions.isNotEmpty)
                  _TransitionSection(
                    label: 'Promoted (${_promotions.length})',
                    results: _promotions,
                    isPromotion: true,
                  ),
                if (_demotions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _TransitionSection(
                    label: 'Demoted (${_demotions.length})',
                    results: _demotions,
                    isPromotion: false,
                  ),
                ],
                const SizedBox(height: 24),
              ],

              // ── Actions ───────────────────────────────────────────────────
              FilledButton.icon(
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Back to Home'),
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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

// ─── Stage transition section ─────────────────────────────────────────────────

class _TransitionSection extends StatelessWidget {
  const _TransitionSection({
    required this.label,
    required this.results,
    required this.isPromotion,
  });

  final String label;
  final List<ReviewResult> results;
  final bool isPromotion;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isPromotion ? const Color(0xFF4CAF50) : const Color(0xFFEF5350);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPromotion
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...results.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                  Text(
                    '${SrsEngine.stageLabel(r.fromStage)} → ${SrsEngine.stageLabel(r.toStage)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(60), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
