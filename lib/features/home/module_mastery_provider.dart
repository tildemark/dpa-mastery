import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import 'home_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

/// Mastery statistics for a single NPC curriculum module.
class ModuleMasteryData {
  const ModuleMasteryData({
    required this.moduleNumber,
    required this.name,
    required this.shortName,
    required this.total,
    required this.availableCount,
    required this.apprenticeCount,
    required this.guruCount,
    required this.masterCount,
    required this.burnedCount,
    required this.subStageCounts,
  });

  final int moduleNumber;

  /// Full display name, e.g. "Module 1: Framework"
  final String name;

  /// Short label used on the compact card.
  final String shortName;

  /// Total number of questions in this module.
  final int total;

  /// Unlearned questions (Stage 0).
  final int availableCount;

  /// Questions currently in active learning (srsStage 1..4).
  final int apprenticeCount;

  /// Questions at Guru stage (srsStage 5..6).
  final int guruCount;

  /// Questions at Master stage (srsStage 7).
  final int masterCount;

  /// Questions at Burned stage (srsStage 8).
  final int burnedCount;

  /// Granular sub-stage counts (e.g. stage 1..8).
  final Map<int, int> subStageCounts;

  /// Questions that have reached Guru or above (srsStage >= 5).
  int get guruPlus => guruCount + masterCount + burnedCount;

  /// Combined items started (Apprentice + Guru+).
  int get startedTotal => apprenticeCount + guruPlus;

  /// Mastery ratio 0.0–1.0 (Guru+ items). Safe: returns 0 when total == 0.
  double get masteryRatio => total > 0 ? guruPlus / total : 0.0;

  /// Apprentice ratio 0.0–1.0. Safe: returns 0 when total == 0.
  double get apprenticeRatio => total > 0 ? apprenticeCount / total : 0.0;

  /// Guru ratio 0.0–1.0. Safe: returns 0 when total == 0.
  double get guruRatio => total > 0 ? guruCount / total : 0.0;

  /// Master ratio 0.0–1.0. Safe: returns 0 when total == 0.
  double get masterRatio => total > 0 ? masterCount / total : 0.0;

  /// Burned ratio 0.0–1.0. Safe: returns 0 when total == 0.
  double get burnedRatio => total > 0 ? burnedCount / total : 0.0;

  /// Backward compatible alias for learningRatio.
  double get learningRatio => apprenticeRatio;

  /// Total active started ratio (Mastered + Learning).
  double get startedRatio => total > 0 ? (startedTotal / total).clamp(0.0, 1.0) : 0.0;

  /// Mastery as a percentage string e.g. "42%".
  String get masteryLabel => '${(masteryRatio * 100).round()}%';
}

// ─────────────────────────────────────────────────────────────────────────────
// Module definitions
// ─────────────────────────────────────────────────────────────────────────────

/// The 7 NPC DPO curriculum modules with their canonical tag prefix.
const _kModules = [
  (1, 'Module 1: Framework',              'Framework'),
  (2, 'Module 2: Concepts',               'Concepts'),
  (3, 'Module 3: Principles',             'Principles'),
  (4, 'Module 4: Lawful Criteria',        'Lawful Criteria'),
  (5, 'Module 5: Data Subject Rights',    'DSR'),
  (6, 'Module 6: Penalties',              'Penalties'),
  (7, 'Module 7: Data Breach Management', 'Breach Mgmt'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Live stream of [ModuleMasteryData] for all 7 modules, respecting the active [DashboardScope].
///
/// Re-fires whenever [UserProgress] or active [DashboardScope] changes.
final moduleMasteryStreamProvider =
    StreamProvider.autoDispose<List<ModuleMasteryData>>((ref) {
  final db = ref.watch(dbProvider);
  final scope = ref.watch(dashboardScopeProvider);

  return db.select(db.userProgress).watch().asyncMap((_) async {
    // Snapshot all tables once per change event.
    final allProgress = await db.select(db.userProgress).get();
    final allQuestions = await db.select(db.questions).get();
    final allQuestionTags = await db.select(db.questionTags).get();
    final allTags = await db.select(db.tags).get();

    // Filter questions based on scope
    final filteredQuestions = switch (scope) {
      DashboardScope.core => allQuestions.where((q) => q.id <= 282).toList(),
      DashboardScope.dlc => allQuestions.where((q) => q.id > 282).toList(),
      DashboardScope.all => allQuestions,
    };

    // Build lookups.
    final tagNameById = {for (final t in allTags) t.id: t.name};
    final progressByQid = {for (final p in allProgress) p.questionId: p.srsStage};

    // questionId → set of module numbers it belongs to.
    final modulesForQuestion = <int, Set<int>>{};
    for (final qt in allQuestionTags) {
      final tagName = tagNameById[qt.tagId];
      if (tagName == null) continue;
      for (final (num, _, _) in _kModules) {
        if (tagName.startsWith('Module $num')) {
          modulesForQuestion.putIfAbsent(qt.questionId, () => {}).add(num);
          break;
        }
      }
    }

    // Tally totals and stages per module.
    final totals = <int, int>{for (final (n, _, _) in _kModules) n: 0};
    final availableCounts = <int, int>{for (final (n, _, _) in _kModules) n: 0};
    final apprenticeCounts = <int, int>{for (final (n, _, _) in _kModules) n: 0};
    final guruCounts = <int, int>{for (final (n, _, _) in _kModules) n: 0};
    final masterCounts = <int, int>{for (final (n, _, _) in _kModules) n: 0};
    final burnedCounts = <int, int>{for (final (n, _, _) in _kModules) n: 0};
    final subStageMaps = <int, Map<int, int>>{
      for (final (n, _, _) in _kModules) n: {for (int s = 0; s <= 8; s++) s: 0}
    };

    for (final q in filteredQuestions) {
      final stage = progressByQid[q.id] ?? 0;
      final mods = modulesForQuestion[q.id];
      if (mods == null || mods.isEmpty) continue;

      for (final mod in mods) {
        totals[mod] = (totals[mod] ?? 0) + 1;
        subStageMaps[mod]![stage] = (subStageMaps[mod]![stage] ?? 0) + 1;

        if (stage == 0) {
          availableCounts[mod] = (availableCounts[mod] ?? 0) + 1;
        } else if (stage >= 1 && stage <= 4) {
          apprenticeCounts[mod] = (apprenticeCounts[mod] ?? 0) + 1;
        } else if (stage == 5 || stage == 6) {
          guruCounts[mod] = (guruCounts[mod] ?? 0) + 1;
        } else if (stage == 7) {
          masterCounts[mod] = (masterCounts[mod] ?? 0) + 1;
        } else if (stage == 8) {
          burnedCounts[mod] = (burnedCounts[mod] ?? 0) + 1;
        }
      }
    }

    return [
      for (final (num, fullName, shortName) in _kModules)
        ModuleMasteryData(
          moduleNumber: num,
          name: fullName,
          shortName: shortName,
          total: totals[num] ?? 0,
          availableCount: availableCounts[num] ?? 0,
          apprenticeCount: apprenticeCounts[num] ?? 0,
          guruCount: guruCounts[num] ?? 0,
          masterCount: masterCounts[num] ?? 0,
          burnedCount: burnedCounts[num] ?? 0,
          subStageCounts: subStageMaps[num] ?? {},
        ),
    ];
  });
});
