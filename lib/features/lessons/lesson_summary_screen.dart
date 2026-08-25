import 'package:flutter/material.dart';
import 'lessons_screen.dart';

/// Shown after a 5-item lesson batch is complete.
/// Displays a summary and navigates back to home.
class LessonSummaryScreen extends StatelessWidget {
  const LessonSummaryScreen({
    super.key,
    required this.completedCount,
    required this.totalCount,
    required this.difficultyLevel,
  });

  final int completedCount;
  final int totalCount;
  final int difficultyLevel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accentColor = _levelColor(difficultyLevel);
    final allCorrect = completedCount == totalCount;

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
                    allCorrect
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
                allCorrect ? 'Batch Complete! 🎉' : 'Lesson Done',
                textAlign: TextAlign.center,
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'You promoted $completedCount of $totalCount items to Apprentice 1.\nThey\'ll be ready to review in 4 hours.',
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),

              // ── Stats grid ───────────────────────────────────────────────────
              Row(
                children: [
                  _StatCard(
                    label: 'Promoted',
                    value: '$completedCount',
                    icon: Icons.arrow_upward_rounded,
                    color: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Next Review',
                    value: '4h',
                    icon: Icons.schedule_rounded,
                    color: accentColor,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Level',
                    value: '$difficultyLevel',
                    icon: Icons.bar_chart_rounded,
                    color: const Color(0xFF9C27B0),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(60), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
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

Color _levelColor(int level) => switch (level) {
      1 => const Color(0xFF5E6AD2),
      2 => const Color(0xFF0EA5E9),
      3 => const Color(0xFF10B981),
      4 => const Color(0xFFF59E0B),
      _ => const Color(0xFFEF4444),
    };
