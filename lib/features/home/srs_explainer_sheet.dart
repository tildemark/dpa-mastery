import 'package:flutter/material.dart';

/// Modal bottom sheet that explains the Spaced Repetition System (SRS)
/// and how questions advance to Mastered status.
class SrsExplainerSheet extends StatelessWidget {
  const SrsExplainerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SrsExplainerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.school_rounded, color: cs.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'How Mastery Works',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Spaced Repetition System (SRS) Guide',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.outline,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quick Explanation Callout
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cs.outlineVariant.withAlpha(80)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, color: Colors.amber.shade700, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Answering a question once puts it into active learning (Apprentice). To reach "Mastered" (Guru+), you review and recall it correctly over spaced intervals.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'THE 5 SRS STAGES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _StageRow(
                      icon: Icons.lock_open_rounded,
                      color: const Color(0xFF64748B),
                      name: 'Available (Stage 0)',
                      badge: 'New',
                      desc: 'New questions waiting for you to study in Lessons Mode.',
                    ),
                    const SizedBox(height: 12),

                    _StageRow(
                      icon: Icons.local_fire_department,
                      color: const Color(0xFFEF5350),
                      name: 'Apprentice (Stages 1–4)',
                      badge: 'In Learning',
                      desc: 'Items you recently learned. They return for review every 4h, 8h, 24h, and 48h to build initial recall.',
                    ),
                    const SizedBox(height: 12),

                    _StageRow(
                      icon: Icons.auto_awesome,
                      color: const Color(0xFF7C4DFF),
                      name: 'Guru (Stages 5–6)',
                      badge: 'Mastered (Counted in %)',
                      desc: 'Concepts you know solidly! Reaching Guru unlocks new Tiers and counts toward Curriculum Mastery % (intervals: 1 wk & 2 wks).',
                    ),
                    const SizedBox(height: 12),

                    _StageRow(
                      icon: Icons.workspace_premium,
                      color: const Color(0xFF1565C0),
                      name: 'Master (Stage 7)',
                      badge: 'Long-term',
                      desc: 'Deeply retained memory. Reviewed once a month (30 days).',
                    ),
                    const SizedBox(height: 12),

                    _StageRow(
                      icon: Icons.whatshot,
                      color: const Color(0xFFF59E0B),
                      name: 'Burned (Stage 8)',
                      badge: 'Permanent',
                      desc: 'Permanently mastered concepts retired from scheduled review queues.',
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'WHY DO CARDS SAY 0% AT FIRST?',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'When you first finish a lesson, items enter Apprentice (shown as coral progress). Once you pass their upcoming reviews and advance them to Guru (Stage 5), they turn green and count as Mastered.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Got it!'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.icon,
    required this.color,
    required this.name,
    required this.badge,
    required this.desc,
  });

  final IconData icon;
  final Color color;
  final String name;
  final String badge;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
