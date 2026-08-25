import 'package:flutter/material.dart';
import 'lessons_screen.dart';

/// Shown after a lesson batch is complete.
/// Displays an exact breakdown of promoted cards (answered cleanly on 1st try)
/// vs re-tested cards that had mistakes during the quiz exam.
class LessonSummaryScreen extends StatelessWidget {
  const LessonSummaryScreen({
    super.key,
    required this.completedCount,
    required this.totalCount,
    required this.mistakesCount,
    required this.difficultyLevel,
  });

  final int completedCount;
  final int totalCount;
  final int mistakesCount;
  final int difficultyLevel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accentColor = _levelColor(difficultyLevel);
    final isCleanPass = mistakesCount == 0;
    final cleanPromotedCount = (totalCount - mistakesCount).clamp(0, totalCount);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // ── Icon ────────────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withAlpha(30),
                    border: Border.all(color: accentColor, width: 2),
                  ),
                  child: Icon(
                    isCleanPass
                        ? Icons.emoji_events_rounded
                        : Icons.school_rounded,
                    size: 52,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Title ────────────────────────────────────────────────────────
              Text(
                isCleanPass ? 'Batch Perfect! 🎉' : 'Batch Complete!',
                textAlign: TextAlign.center,
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                isCleanPass
                    ? 'All $totalCount items passed cleanly on the first try and are promoted to Apprentice 1.'
                    : '$totalCount items mastered!\n($cleanPromotedCount passed cleanly on 1st try, $mistakesCount required re-testing and will be prioritized in reviews).',
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // ── Stats grid ───────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Promoted',
                      value: '$totalCount',
                      icon: Icons.arrow_upward_rounded,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      label: '1st Try',
                      value: '$cleanPromotedCount',
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFF00ACC1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      label: 'Missed',
                      value: '$mistakesCount',
                      icon: Icons.error_outline_rounded,
                      color: mistakesCount > 0
                          ? const Color(0xFFEF5350)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      label: 'Review in',
                      value: '4h',
                      icon: Icons.schedule_rounded,
                      color: accentColor,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ── Actions ──────────────────────────────────────────────────────
              FilledButton.icon(
                onPressed: () => Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                ),
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    LessonsScreen.route(difficultyLevel),
                  );
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Keep Learning'),
                style: OutlinedButton.styleFrom(
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
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

Color _levelColor(int level) => switch (level) {
      1 => const Color(0xFF5E6AD2),
      2 => const Color(0xFF0EA5E9),
      3 => const Color(0xFF10B981),
      4 => const Color(0xFFF59E0B),
      _ => const Color(0xFFEF4444),
    };
