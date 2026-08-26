import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import '../../services/settings_service.dart';
import '../profile/profile_dialog.dart';

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
  late bool _shuffleOptions;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsServiceProvider);
    _dailyTarget = settings.dailyTarget;
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

          // ── 2. Randomize Choices ──
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
          const SizedBox(height: 24),

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

      await db.progressDao.resetAllProgress();
      await settings.resetQuota();

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
