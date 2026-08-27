import '../db/app_database.dart';

/// Computes a composite NPC DPO exam readiness score (0–100).
///
/// The score blends two dimensions:
///   - **Depth** (60 % weight): overall Guru+ rate across all 282 questions.
///   - **Breadth** (40 % weight): proportion of the 7 curriculum modules that
///     have reached ≥ 50 % Guru mastery.
///
/// A score of 100 means you've Guru'd at least half the questions in every
/// module AND achieved high overall mastery.
class ReadinessService {
  ReadinessService(this._db);

  final AppDatabase _db;

  static const int _totalModules = 7;
  static const double _moduleThreshold = 0.50; // 50 % Guru to count as "covered"

  /// Returns a readiness score in the range [0, 100].
  Future<ReadinessResult> computeReadiness() async {
    final allProgress = await _db.select(_db.userProgress).get();
    final allQuestions = await _db.select(_db.questions).get();
    final allQuestionTags = await _db.select(_db.questionTags).get();
    final allTags = await _db.select(_db.tags).get();

    // ── Depth score ──────────────────────────────────────────────────────────
    final totalQ = allQuestions.length;
    if (totalQ == 0) return const ReadinessResult(score: 0, depth: 0, breadth: 0);

    final progressByQid = {for (final p in allProgress) p.questionId: p.srsStage};
    int guruPlusTotal = 0;
    for (final q in allQuestions) {
      if ((progressByQid[q.id] ?? 0) >= 5) guruPlusTotal++;
    }
    final depth = guruPlusTotal / totalQ; // 0.0–1.0

    // ── Breadth score ─────────────────────────────────────────────────────────
    final tagNameById = {for (final t in allTags) t.id: t.name};
    final modulesForQ = <int, Set<int>>{};
    for (final qt in allQuestionTags) {
      final tagName = tagNameById[qt.tagId];
      if (tagName == null) continue;
      for (int m = 1; m <= _totalModules; m++) {
        if (tagName.startsWith('Module $m')) {
          modulesForQ.putIfAbsent(qt.questionId, () => {}).add(m);
          break;
        }
      }
    }

    final moduleTotals = <int, int>{};
    final moduleGuru = <int, int>{};
    for (final q in allQuestions) {
      final stage = progressByQid[q.id] ?? 0;
      for (final m in modulesForQ[q.id] ?? {}) {
        moduleTotals[m] = (moduleTotals[m] ?? 0) + 1;
        if (stage >= 5) moduleGuru[m] = (moduleGuru[m] ?? 0) + 1;
      }
    }

    int coveredModules = 0;
    for (int m = 1; m <= _totalModules; m++) {
      final total = moduleTotals[m] ?? 0;
      if (total == 0) continue;
      final ratio = (moduleGuru[m] ?? 0) / total;
      if (ratio >= _moduleThreshold) coveredModules++;
    }
    final breadth = coveredModules / _totalModules; // 0.0–1.0

    // ── Composite ────────────────────────────────────────────────────────────
    const depthWeight = 0.60;
    const breadthWeight = 0.40;
    final composite = (depth * depthWeight + breadth * breadthWeight) * 100;

    return ReadinessResult(
      score: composite.round().clamp(0, 100),
      depth: depth,
      breadth: breadth,
    );
  }
}

class ReadinessResult {
  const ReadinessResult({
    required this.score,
    required this.depth,
    required this.breadth,
  });

  /// Composite readiness score, 0–100.
  final int score;

  /// Overall Guru+ ratio (0.0–1.0).
  final double depth;

  /// Proportion of modules >= 50 % Guru (0.0–1.0).
  final double breadth;
}
