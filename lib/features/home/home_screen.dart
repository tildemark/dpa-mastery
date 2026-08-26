import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/gating_service.dart';
import '../../engine/rank_service.dart';
import '../../main.dart';
import '../lessons/lessons_screen.dart';
import '../reviews/reviews_screen.dart';
import '../reviews/review_provider.dart';
import '../drills/tag_drill_screen.dart';
import '../cram/cram_screen.dart';

import '../../services/settings_service.dart';
import '../settings/settings_screen.dart';
import '../profile/profile_dialog.dart';
import 'srs_breakdown_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsServiceProvider);
      if (!settings.hasCompletedOnboarding) {
        ProfileDialog.show(context, isOnboarding: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(dbProvider);
    final settings = ref.watch(settingsServiceProvider);
    final gating = GatingService(db);
    final rankService = RankService(db);
    final reviewQueueAsync = ref.watch(reviewQueueProvider);
    final srsCountsAsync = ref.watch(srsStageCountsStreamProvider);
    final forecastAsync = ref.watch(reviewForecastStreamProvider);
    final nextReviewAsync = ref.watch(nextReviewTimeStreamProvider);
    final cs = Theme.of(context).colorScheme;

    final counts = srsCountsAsync.value;
    final fc = forecastAsync.asData?.value;
    final nextTime = nextReviewAsync.asData?.value;
    final isCountsLoading = srsCountsAsync.isLoading || counts == null;
    final availableLessons = counts != null ? settings.getAvailableLessonsToday(counts.locked) : 0;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('DPA Mastery', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Study Settings',
            onPressed: () => SettingsSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About & Credits',
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'DPA Mastery',
                applicationVersion: '1.2.0',
                applicationIcon: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.verified_user_rounded, color: cs.primary, size: 28),
                ),
                applicationLegalese: '© 2026 Alfredo Sanchez Jr.\nAll rights reserved.',
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Developer',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Text('Alfredo Sanchez Jr\nhttps://sanchez.ph'),
                  const SizedBox(height: 14),
                  const Text(
                    'Privacy Policy & Offline Guarantee',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Text(
                    'DPA Mastery is 100% offline. Zero telemetry, zero user tracking, and zero personal data collection. All SRS progress, study history, and question records reside strictly in your local device SQLite database in full compliance with the Data Privacy Act of 2012 (RA 10173).',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Certification Focus',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Text(
                    'National Privacy Commission (NPC) Certified DPO (Data Protection Officer) Assessment & Compliance Framework.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // ── 1. DPO Rank & Certification Profile Card ──
            FutureBuilder<UserRankProfile>(
              future: rankService.getUserRankProfile(),
              builder: (context, snapshot) {
                final rank = snapshot.data;
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1E293B),
                        cs.surfaceContainerHigh,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF6366F1).withAlpha(90), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withAlpha(40),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF6366F1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_user_rounded, color: Color(0xFF818CF8), size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'Level ${rank?.level ?? 1}',
                                  style: const TextStyle(
                                    color: Color(0xFF818CF8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${(rank?.masteryPercentage ?? 0).toInt()}% Exam Ready',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${settings.userName} • ${rank?.title ?? "Privacy Cadet"}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (rank?.masteryPercentage ?? 0) / 100,
                          minHeight: 6,
                          backgroundColor: cs.surfaceContainerHighest,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 18),

            // ── 2. Primary Study Action Cards ──
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    title: 'Lessons',
                    subtitle: isCountsLoading
                        ? 'Loading lessons...'
                        : (availableLessons > 0
                            ? '$availableLessons available today'
                            : (counts.locked == 0
                                ? 'All lessons completed'
                                : 'Daily quota complete')),
                    icon: Icons.school_rounded,
                    color: const Color(0xFF5E6AD2),
                    badgeCount: availableLessons,
                    onTap: () async {
                      final unlocked = await gating.getUnlockedLevels();
                      final currentLevel = unlocked.isNotEmpty ? unlocked.last : 1;
                      if (context.mounted) {
                        Navigator.of(context).push(LessonsScreen.route(currentLevel));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      String subtitle;
                      if (reviewQueueAsync.asData != null && reviewQueueAsync.asData!.value.isNotEmpty) {
                        subtitle = '${reviewQueueAsync.asData!.value.length} due now';
                      } else if (nextTime != null) {
                        final diff = nextTime.difference(DateTime.now());
                        if (diff.isNegative) {
                          subtitle = 'Available now';
                        } else if (diff.inHours > 0) {
                          subtitle = 'Next in ${diff.inHours}h ${diff.inMinutes % 60}m';
                        } else {
                          subtitle = 'Next in ${diff.inMinutes}m';
                        }
                      } else {
                        subtitle = 'All caught up';
                      }

                      return _ActionCard(
                        title: 'Reviews',
                        subtitle: subtitle,
                        icon: Icons.repeat_rounded,
                        color: const Color(0xFF10B981),
                        badgeCount: reviewQueueAsync.asData?.value.length ?? 0,
                        onTap: () {
                          Navigator.of(context).push(ReviewsScreen.route());
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── 3. Cram / Self-Study (Adventure Mode) Quick Banner ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withAlpha(20),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF59E0B).withAlpha(90)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B), size: 26),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Self-Study / Cram Mode',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Practice cards freely anytime without review timers.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () => CramSetupSheet.show(context),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Configure'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── 4. WaniKani SRS Stage Distribution Bar ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SRS Mastery Breakdown',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurfaceVariant,
                      ),
                ),
                Text(
                  'Tap for details',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SrsStageMetric(
                        label: 'Locked',
                        count: counts?.locked ?? 0,
                        color: const Color(0xFF64748B),
                        icon: Icons.lock_outline,
                      ),
                      _SrsStageMetric(
                        label: 'Apprentice',
                        count: counts?.apprentice ?? 0,
                        color: const Color(0xFFEF5350),
                        icon: Icons.local_fire_department,
                      ),
                      _SrsStageMetric(
                        label: 'Guru',
                        count: counts?.guru ?? 0,
                        color: const Color(0xFF7C4DFF),
                        icon: Icons.auto_awesome,
                      ),
                      _SrsStageMetric(
                        label: 'Master',
                        count: counts?.master ?? 0,
                        color: const Color(0xFF1565C0),
                        icon: Icons.workspace_premium,
                      ),
                      _SrsStageMetric(
                        label: 'Burned',
                        count: counts?.burned ?? 0,
                        color: const Color(0xFFF59E0B),
                        icon: Icons.whatshot,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── 5. Review Forecast (Upcoming Countdowns) ──
            Text(
              'Review Forecast',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ForecastSlot(label: '+1h', count: fc?.within1h ?? 0),
                  _ForecastSlot(label: '+4h', count: fc?.within4h ?? 0),
                  _ForecastSlot(label: '+24h', count: fc?.within24h ?? 0),
                  _ForecastSlot(label: '+3d', count: fc?.within3d ?? 0),
                  _ForecastSlot(label: '+7d', count: fc?.within7d ?? 0),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── 6. Difficulty Progression (85% Guru Gating) ──
            Text(
              'Difficulty Progression (85% Guru Gating)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<int>>(
              future: gating.getUnlockedLevels(),
              builder: (context, snapshot) {
                final unlockedLevels = snapshot.data ?? [1];
                return Column(
                  children: List.generate(5, (index) {
                    final level = index + 1;
                    final isUnlocked = unlockedLevels.contains(level);

                    return FutureBuilder<double>(
                      future: gating.guruRatioForLevel(level),
                      builder: (context, ratioSnap) {
                        final ratio = ratioSnap.data ?? 0.0;
                        return _LevelProgressTile(
                          level: level,
                          isUnlocked: isUnlocked,
                          ratio: ratio,
                          onTap: isUnlocked
                              ? () => Navigator.of(context).push(LessonsScreen.route(level))
                              : null,
                        );
                      },
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 24),

            // ── 7. Quick Practice Drill Topics ──
            Text(
              'Targeted Concept Drills',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Scope of DPA',
                'Statutory Exclusions',
                'General Principles',
                'Consent',
                'Data Breach Management',
              ].map((tag) {
                return ActionChip(
                  label: Text(tag),
                  avatar: const Icon(Icons.tag, size: 16),
                  onPressed: () {
                    Navigator.of(context).push(TagDrillScreen.route(tag));
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
  }
}

class _SrsStageMetric extends StatelessWidget {
  const _SrsStageMetric({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        SrsBreakdownSheet.show(
          context,
          stageName: label,
          stageColor: color,
          stageIcon: icon,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForecastSlot extends StatelessWidget {
  const _ForecastSlot({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(80), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 30),
                if (badgeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelProgressTile extends StatelessWidget {
  const _LevelProgressTile({
    required this.level,
    required this.isUnlocked,
    required this.ratio,
    this.onTap,
  });

  final int level;
  final bool isUnlocked;
  final double ratio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _levelColor(level);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isUnlocked ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                  color: isUnlocked ? color : cs.outline,
                  size: 20,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level $level: ${_levelLabel(level)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isUnlocked ? cs.onSurface : cs.outline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 4,
                          backgroundColor: cs.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(ratio * 100).toInt()}% Guru',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? color : cs.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _levelLabel(int l) => switch (l) {
        1 => 'Foundational Framework',
        2 => 'Key Definitions & Rules',
        3 => 'Single-Concept Scenarios',
        4 => 'Multi-Concept Application',
        _ => 'Edge Cases & Exceptions',
      };

  Color _levelColor(int l) => switch (l) {
        1 => const Color(0xFF5E6AD2),
        2 => const Color(0xFF0EA5E9),
        3 => const Color(0xFF10B981),
        4 => const Color(0xFFF59E0B),
        _ => const Color(0xFFEF4444),
      };
}
