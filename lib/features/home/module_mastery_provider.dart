import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';

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
    required this.guruPlus,
  });

  final int moduleNumber;

  /// Full display name, e.g. "Module 1: Framework"
  final String name;

  /// Short label used on the compact card.
  final String shortName;

  /// Total number of questions in this module.
  final int total;

  /// Questions that have reached Guru or above (srsStage >= 5).
  final int guruPlus;

  /// Mastery ratio 0.0–1.0. Safe: returns 0 when total == 0.
  double get masteryRatio => total > 0 ? guruPlus / total : 0.0;

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

/// Live stream of [ModuleMasteryData] for all 7 modules.
///
/// Re-fires whenever [UserProgress] changes (after lessons or reviews).
final moduleMasteryStreamProvider =
    StreamProvider.autoDispose<List<ModuleMasteryData>>((ref) {
  final db = ref.watch(dbProvider);

  return db.select(db.userProgress).watch().asyncMap((_) async {
    // Snapshot all tables once per change event.
    final allProgress = await db.select(db.userProgress).get();
    final allQuestions = await db.select(db.questions).get();
    final allQuestionTags = await db.select(db.questionTags).get();
    final allTags = await db.select(db.tags).get();

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

    // Tally totals and guruPlus per module.
    final totals = <int, int>{for (final (n, _, _) in _kModules) n: 0};
    final guruCounts = <int, int>{for (final (n, _, _) in _kModules) n: 0};

    for (final q in allQuestions) {
      final stage = progressByQid[q.id] ?? 0;
      final mods = modulesForQuestion[q.id];
      if (mods == null || mods.isEmpty) continue;

      for (final mod in mods) {
        totals[mod] = (totals[mod] ?? 0) + 1;
        if (stage >= 5) {
          guruCounts[mod] = (guruCounts[mod] ?? 0) + 1;
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
          guruPlus: guruCounts[num] ?? 0,
        ),
    ];
  });
});
