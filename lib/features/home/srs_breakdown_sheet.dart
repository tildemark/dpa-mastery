import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';

/// Represents SRS breakdown statistics grouped by Level and Module.
class StageBreakdownData {
  const StageBreakdownData({
    required this.stageName,
    required this.totalCount,
    required this.levelCounts,
    required this.moduleCounts,
  });

  final String stageName;
  final int totalCount;
  final Map<int, int> levelCounts;
  final Map<String, int> moduleCounts;
}

/// Provider for detailed stage breakdown statistics (by Level and Module).
final stageBreakdownProvider =
    FutureProvider.family<StageBreakdownData, String>((ref, stageName) async {
  final db = ref.watch(dbProvider);

  // Determine stage filter criteria
  final allProgress = await db.select(db.userProgress).get();
  final progressMap = {for (final p in allProgress) p.questionId: p.srsStage};

  // Fetch all questions and their module tags
  final allQuestions = await db.select(db.questions).get();
  final allQuestionTags = await db.select(db.questionTags).get();
  final allTags = await db.select(db.tags).get();
  final tagMap = {for (final t in allTags) t.id: t.name};

  // Map questionId -> List of Module tags
  final questionModules = <int, List<String>>{};
  for (final qt in allQuestionTags) {
    final tagName = tagMap[qt.tagId];
    if (tagName != null && tagName.startsWith('Module')) {
      questionModules.putIfAbsent(qt.questionId, () => []).add(tagName);
    }
  }

  bool matchesStage(int stage) {
    switch (stageName.toLowerCase()) {
      case 'available':
      case 'unlearned':
      case 'locked':
        return stage == 0;
      case 'apprentice':
        return stage >= 1 && stage <= 4;
      case 'guru':
        return stage == 5 || stage == 6;
      case 'master':
        return stage == 7;
      case 'burned':
        return stage == 8;
      default:
        return false;
    }
  }

  final levelCounts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  final moduleCounts = <String, int>{
    'Module 1: Framework': 0,
    'Module 2: Concepts': 0,
    'Module 3: Principles': 0,
    'Module 4: Lawful Criteria': 0,
    'Module 5: Data Subject Rights': 0,
    'Module 6: Penalties': 0,
    'Module 7: Data Breach Management': 0,
  };

  int total = 0;

  final moduleMap = <int, String>{
    1: 'Module 1: Framework',
    2: 'Module 2: Concepts',
    3: 'Module 3: Principles',
    4: 'Module 4: Lawful Criteria',
    5: 'Module 5: Data Subject Rights',
    6: 'Module 6: Penalties',
    7: 'Module 7: Data Breach Management',
  };

  String normalizeModuleTag(String rawTag, int fallbackLevel) {
    for (final entry in moduleMap.entries) {
      if (rawTag.startsWith('Module ${entry.key}')) {
        return entry.value;
      }
    }
    return moduleMap[fallbackLevel] ?? 'Module $fallbackLevel';
  }

  for (final q in allQuestions) {
    final stage = progressMap[q.id] ?? 0;
    if (matchesStage(stage)) {
      total++;
      levelCounts[q.difficultyLevel] = (levelCounts[q.difficultyLevel] ?? 0) + 1;

      final modules = questionModules[q.id];
      if (modules != null && modules.isNotEmpty) {
        final normalizedSet = <String>{};
        for (final m in modules) {
          normalizedSet.add(normalizeModuleTag(m, q.difficultyLevel));
        }
        for (final norm in normalizedSet) {
          moduleCounts[norm] = (moduleCounts[norm] ?? 0) + 1;
        }
      } else {
        // Fallback if tag is general
        final fallback = moduleMap[q.difficultyLevel] ?? 'Module ${q.difficultyLevel}';
        moduleCounts[fallback] = (moduleCounts[fallback] ?? 0) + 1;
      }
    }
  }

  return StageBreakdownData(
    stageName: stageName,
    totalCount: total,
    levelCounts: levelCounts,
    moduleCounts: moduleCounts,
  );
});

/// Bottom sheet displaying the detailed breakdown of questions in a specific SRS stage.
class SrsBreakdownSheet extends ConsumerWidget {
  const SrsBreakdownSheet({
    super.key,
    required this.stageName,
    required this.stageColor,
    required this.stageIcon,
  });

  final String stageName;
  final Color stageColor;
  final IconData stageIcon;

  static Future<void> show(
    BuildContext context, {
    required String stageName,
    required Color stageColor,
    required IconData stageIcon,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SrsBreakdownSheet(
        stageName: stageName,
        stageColor: stageColor,
        stageIcon: stageIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final breakdownAsync = ref.watch(stageBreakdownProvider(stageName));
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: stageColor.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(stageIcon, color: stageColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$stageName Stage Breakdown',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _getStageDescription(stageName),
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              breakdownAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Failed to load breakdown: $err'),
                ),
                data: (data) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Total Highlight Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: stageColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: stageColor.withAlpha(60)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total in $stageName',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${data.totalCount} Lessons',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: stageColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section 1: By Difficulty Level
                      Text(
                        'By Difficulty Level',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 10),
                      ...data.levelCounts.entries.map((e) {
                        final level = e.key;
                        final count = e.value;
                        final pct = data.totalCount > 0 ? count / data.totalCount : 0.0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tier $level: ${_levelLabel(level)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '$count items',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: count > 0 ? cs.primary : cs.outline,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 4,
                                  backgroundColor: cs.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(_levelColor(level)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 18),

                      // Section 2: By Curriculum Module
                      Text(
                        'By Curriculum Module',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 10),
                      ...data.moduleCounts.entries
                          .where((e) => e.value > 0 || data.totalCount == 0)
                          .map((e) {
                        final moduleName = e.key;
                        final count = e.value;
                        final pct = data.totalCount > 0 ? count / data.totalCount : 0.0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      moduleName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$count items',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: count > 0 ? stageColor : cs.outline,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 4,
                                  backgroundColor: cs.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(stageColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),

                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStageDescription(String stage) {
    switch (stage.toLowerCase()) {
      case 'available':
      case 'unlearned':
      case 'locked':
        return 'Questions awaiting their first lesson (Stage 0).';
      case 'apprentice':
        return 'Active learning items with 4h–48h review intervals.';
      case 'guru':
        return 'Solidified concepts with 1-week and 2-week intervals.';
      case 'master':
        return 'Near-permanent knowledge (1-month review interval).';
      case 'burned':
        return 'Mastered items permanently retired from the active queue.';
      default:
        return '';
    }
  }

  String _levelLabel(int l) => switch (l) {
        1 => 'Foundations',
        2 => 'Compliance Practitioner',
        3 => 'Privacy Specialist',
        4 => 'Lead Privacy Architect',
        _ => 'Master DPO',
      };

  Color _levelColor(int l) => switch (l) {
        1 => const Color(0xFF5E6AD2),
        2 => const Color(0xFF0EA5E9),
        3 => const Color(0xFF10B981),
        4 => const Color(0xFFF59E0B),
        _ => const Color(0xFFEF4444),
      };
}
