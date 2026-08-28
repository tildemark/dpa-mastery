import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import '../../services/settings_service.dart';
import '../../services/seed_loader.dart';
import '../../services/dlc/dlc_service.dart';
import '../../services/app_time.dart';
import '../reviews/review_provider.dart';
import '../profile/profile_dialog.dart';
import '../dlc/dlc_store_screen.dart';
import '../home/home_providers.dart';
import '../home/module_mastery_provider.dart';
import '../../engine/gating_service.dart';

/// Modal bottom sheet allowing users to configure daily lesson pace and learning preferences.
class SettingsSheet extends ConsumerStatefulWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsSheet(),
    );
  }

  @override
  ConsumerState<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<SettingsSheet> {
  late int _dailyTarget;
  late int _apprenticeCap;
  late bool _shuffleOptions;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsServiceProvider);
    _dailyTarget = settings.dailyTarget;
    _apprenticeCap = settings.apprenticeCap;
    _shuffleOptions = settings.shuffleOptions;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final settings = ref.read(settingsServiceProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: cs.outlineVariant.withAlpha(150),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Study Preferences',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Control your daily lesson commitment and learning rhythm.',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // ── 0. User Profile Section ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF6366F1).withAlpha(50)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF6366F1).withAlpha(40),
                  child: const Icon(Icons.person_rounded, color: Color(0xFF818CF8)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        settings.userName == 'Guest' ? 'Local Guest Profile' : 'Cadet Profile',
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final newName = await ProfileDialog.show(context);
                    if (newName != null) {
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── 1. Daily Lesson Target ──
          const Text(
            'Daily Lesson Target (Pace)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Lessons accumulate every day if you miss a session.',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTargetChip(5, '5 / day (Relaxed)'),
              _buildTargetChip(10, '10 / day (Recommended)'),
              _buildTargetChip(15, '15 / day (Intensive)'),
              _buildTargetChip(20, '20 / day (Sprint)'),
              _buildTargetChip(0, 'Unlimited'),
            ],
          ),
          const SizedBox(height: 20),

          // ── 2. Apprentice Stage Cap (Review Overload Protection) ──
          const Text(
            'Apprentice Stage Cap',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Pauses new lessons if you have too many active apprentice items to prevent review avalanche.',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildApprenticeChip(30, '30 items (Strict)'),
              _buildApprenticeChip(50, '50 items (Recommended)'),
              _buildApprenticeChip(75, '75 items (High)'),
              _buildApprenticeChip(100, '100 items (Very High)'),
              _buildApprenticeChip(0, 'Disabled'),
            ],
          ),
          const SizedBox(height: 20),

          // ── 3. Randomize Choices ──
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile.adaptive(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: const Text('Randomize Multiple-Choice Options', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: const Text('Shuffle choices (A, B, C, D) during quizzes & exams', style: TextStyle(fontSize: 12)),
              value: _shuffleOptions,
              onChanged: (val) async {
                setState(() => _shuffleOptions = val);
                await settings.setShuffleOptions(val);
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── 2b. Expansion Packs / DLC Manager Navigation ──
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.extension_rounded, color: Color(0xFF6366F1)),
              title: const Text('Expansion Packs & DLCs', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: const Text('Manage downloadable question packs and mock exams', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(DlcStoreScreen.route());
              },
            ),
          ),
          const SizedBox(height: 16),

          // ── 2c. Developer & Testing Shortcuts (Debug Mode Only) ──
          if (kDebugMode) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withAlpha(20),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF6366F1).withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bolt_rounded, color: Color(0xFF818CF8), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Dev & QA Fast-Forward Shortcuts',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF818CF8)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Simulate natural time passage (+1h/+4h/+24h/+3d/+7d) across all SRS timers and daily lesson rollovers.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 14, color: AppTime.isTimeShifted ? const Color(0xFF10B981) : const Color(0xFF818CF8)),
                      const SizedBox(width: 6),
                      Text(
                        'Simulated Clock: ${AppTime.offsetLabel}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTime.isTimeShifted ? const Color(0xFF10B981) : const Color(0xFF818CF8),
                        ),
                      ),
                      if (AppTime.isTimeShifted) ...[
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            final prefs = ref.read(sharedPrefsProvider);
                            await AppTime.resetOffset(prefs);
                            ref.invalidate(reviewQueueProvider);
                            ref.invalidate(srsStageCountsStreamProvider);
                            ref.invalidate(reviewForecastStreamProvider);
                            ref.invalidate(nextReviewTimeStreamProvider);
                            ref.invalidate(settingsServiceProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Simulated clock reset back to Real Time.'),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              setState(() {});
                            }
                          },
                          child: const Text(
                            'Reset to Real Time',
                            style: TextStyle(fontSize: 11, color: Color(0xFFEF5350), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildFastForwardChip(
                        context: context,
                        label: '+1 hr',
                        duration: const Duration(hours: 1),
                        description: '1 hour',
                      ),
                      _buildFastForwardChip(
                        context: context,
                        label: '+4 hrs',
                        duration: const Duration(hours: 4),
                        description: '4 hours',
                      ),
                      _buildFastForwardChip(
                        context: context,
                        label: '+24 hrs',
                        duration: const Duration(hours: 24),
                        description: '24 hours',
                      ),
                      _buildFastForwardChip(
                        context: context,
                        label: '+3 days',
                        duration: const Duration(days: 3),
                        description: '3 days',
                      ),
                      _buildFastForwardChip(
                        context: context,
                        label: '+7 days',
                        duration: const Duration(days: 7),
                        description: '7 days',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Simulate Study / Fast-Forward Progress:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF818CF8)),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final db = ref.read(dbProvider);
                          final settings = ref.read(settingsServiceProvider);
                          final gating = GatingService(db, settings);
                          final unlocked = await gating.getUnlockedLevels();
                          int promoted = 0;
                          for (final lvl in unlocked) {
                            promoted += await db.progressDao.promoteLevelToApprentice(lvl);
                            if (promoted > 0) break;
                          }

                          ref.invalidate(reviewQueueProvider);
                          ref.invalidate(srsStageCountsStreamProvider);
                          ref.invalidate(reviewForecastStreamProvider);
                          ref.invalidate(nextReviewTimeStreamProvider);
                          ref.invalidate(homeProfileStreamProvider);
                          ref.invalidate(tierProgressionStreamProvider);
                          ref.invalidate(moduleMasteryStreamProvider);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  promoted > 0
                                      ? 'Completed lessons for $promoted question(s) → moved to Apprentice 1!'
                                      : 'No unlearned questions in active unlocked levels.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.school_rounded, size: 16),
                        label: const Text('Pass Unlearned Lessons', style: TextStyle(fontSize: 11)),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final db = ref.read(dbProvider);
                          final count = await db.progressDao.answerAllDueReviewsCorrectly();

                          ref.invalidate(reviewQueueProvider);
                          ref.invalidate(srsStageCountsStreamProvider);
                          ref.invalidate(reviewForecastStreamProvider);
                          ref.invalidate(nextReviewTimeStreamProvider);
                          ref.invalidate(homeProfileStreamProvider);
                          ref.invalidate(tierProgressionStreamProvider);
                          ref.invalidate(moduleMasteryStreamProvider);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  count > 0
                                      ? 'Answered $count review(s) correctly → advanced +1 SRS Stage!'
                                      : 'No reviews are currently due.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_circle_rounded, size: 16),
                        label: const Text('Pass All Due Reviews', style: TextStyle(fontSize: 11)),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final db = ref.read(dbProvider);
                          final count = await db.progressDao.makeAllReviewsDueNow();

                          ref.invalidate(reviewQueueProvider);
                          ref.invalidate(srsStageCountsStreamProvider);
                          ref.invalidate(reviewForecastStreamProvider);
                          ref.invalidate(nextReviewTimeStreamProvider);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Fast-forwarded: $count reviews are due right now!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.timer_outlined, size: 16),
                        label: const Text('Make All Due Now', style: TextStyle(fontSize: 11)),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final db = ref.read(dbProvider);
                          final settings = ref.read(settingsServiceProvider);
                          await db.progressDao.promoteTier1ToGuru();
                          await settings.setHighestUnlockedLevel(2);

                          ref.invalidate(reviewQueueProvider);
                          ref.invalidate(srsStageCountsStreamProvider);
                          ref.invalidate(reviewForecastStreamProvider);
                          ref.invalidate(nextReviewTimeStreamProvider);
                          ref.invalidate(homeProfileStreamProvider);
                          ref.invalidate(tierProgressionStreamProvider);
                          ref.invalidate(moduleMasteryStreamProvider);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Promoted Tier 1 to Guru (Stage 5)! Tier 2 unlocked.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.military_tech_rounded, size: 16),
                        label: const Text('Graduate Tier 1 to Guru', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── 3. Reset / New Profile Options ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.errorContainer.withAlpha(40),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.error.withAlpha(60)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: cs.error, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Profile & Progress Management',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.error),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _confirmReset(context, isNewProfile: false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.error,
                          side: BorderSide(color: cs.error.withAlpha(120)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Reset Progress', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _confirmReset(context, isNewProfile: true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.error,
                          side: BorderSide(color: cs.error.withAlpha(120)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('New Profile', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildTargetChip(int value, String label) {
    final isSelected = _dailyTarget == value;
    final settings = ref.read(settingsServiceProvider);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) async {
        if (selected) {
          setState(() => _dailyTarget = value);
          await settings.setDailyTarget(value);
        }
      },
    );
  }

  Widget _buildApprenticeChip(int value, String label) {
    final isSelected = _apprenticeCap == value;
    final settings = ref.read(settingsServiceProvider);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) async {
        if (selected) {
          setState(() => _apprenticeCap = value);
          await settings.setApprenticeCap(value);
        }
      },
    );
  }

  Widget _buildFastForwardChip({
    required BuildContext context,
    required String label,
    required Duration duration,
    required String description,
  }) {
    return ActionChip(
      avatar: const Icon(Icons.fast_forward_rounded, size: 14, color: Color(0xFF818CF8)),
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      backgroundColor: const Color(0xFF6366F1).withAlpha(30),
      side: const BorderSide(color: Color(0xFF6366F1), width: 0.8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      onPressed: () async {
        final prefs = ref.read(sharedPrefsProvider);
        final db = ref.read(dbProvider);

        // Advance the central simulated clock
        await AppTime.addOffset(duration, prefs);

        // Invalidate reactive providers to update all timers, queues, and quotas against the new time
        ref.invalidate(reviewQueueProvider);
        ref.invalidate(srsStageCountsStreamProvider);
        ref.invalidate(reviewForecastStreamProvider);
        ref.invalidate(nextReviewTimeStreamProvider);
        ref.invalidate(settingsServiceProvider);

        final count = await db.progressDao.countDueReviews();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Simulated Clock: Advanced $description (${AppTime.offsetLabel}). $count review(s) due.'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() {});
        }
      },
    );
  }

  Future<void> _confirmReset(BuildContext context, {required bool isNewProfile}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isNewProfile ? 'Start New Profile?' : 'Reset All Progress?'),
        content: Text(
          isNewProfile
              ? 'This will clear all current SRS study progress, history, and review queues, and allow you to set up a brand new profile.'
              : 'This will reset all questions back to Locked (Stage 0) and restore your daily lesson quota. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isNewProfile ? 'Start Fresh' : 'Reset Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final db = ref.read(dbProvider);
      final settings = ref.read(settingsServiceProvider);
      final prefs = ref.read(sharedPrefsProvider);
      final seedLoader = SeedLoader(db);

      await seedLoader.resetAndReseedCoreBank(prefs: prefs);
      await prefs.remove('installed_dlc_pack_ids');
      await settings.resetUnlockedLevels();
      await settings.resetQuota();

      ref.invalidate(availableDlcListProvider);
      ref.invalidate(installedDlcListProvider);
      ref.invalidate(reviewQueueProvider);
      ref.invalidate(srsStageCountsStreamProvider);
      ref.invalidate(reviewForecastStreamProvider);
      ref.invalidate(nextReviewTimeStreamProvider);
      ref.invalidate(homeProfileStreamProvider);
      ref.invalidate(tierProgressionStreamProvider);
      ref.invalidate(missedQuestionsCountProvider);
      ref.invalidate(moduleMasteryStreamProvider);

      if (isNewProfile) {
        if (context.mounted) {
          Navigator.of(context).pop(); // Close settings sheet
          await ProfileDialog.show(context, isOnboarding: true);
        }
      } else {
        if (context.mounted) {
          Navigator.of(context).pop(); // Close settings sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All progress and daily quotas have been reset.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
