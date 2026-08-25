import 'package:drift/drift.dart';

import '../app_database.dart';

part 'progress_dao.g.dart';

@DriftAccessor(tables: [UserProgress, Questions])
class ProgressDao extends DatabaseAccessor<AppDatabase>
    with _$ProgressDaoMixin {
  ProgressDao(super.db);

  // ─── Review Queue ─────────────────────────────────────────────────────────

  /// Items that are due for review right now:
  /// - Lesson has been completed (srsStage >= 1)
  /// - nextReviewTime is in the past
  Stream<List<UserProgressData>> watchReviewQueue() {
    final now = DateTime.now();
    return (select(userProgress)
          ..where((p) =>
              p.isLessonCompleted.equals(true) &
              p.nextReviewTime.isSmallerOrEqualValue(now)))
        .watch();
  }

  Future<List<UserProgressData>> getReviewQueue() {
    final now = DateTime.now();
    return (select(userProgress)
          ..where((p) =>
              p.isLessonCompleted.equals(true) &
              p.nextReviewTime.isSmallerOrEqualValue(now)))
        .get();
  }

  // ─── Lesson Queue ─────────────────────────────────────────────────────────

  /// Items for Lessons Mode: locked (srsStage == 0) questions at a given difficulty.
  /// Joined with Questions to apply the difficulty filter.
  Future<List<UserProgressData>> getLessonQueue(int difficultyLevel) {
    final query = select(userProgress).join([
      innerJoin(
        db.questions,
        db.questions.id.equalsExp(userProgress.questionId),
      ),
    ])
      ..where(
        userProgress.srsStage.equals(0) &
            userProgress.isLessonCompleted.equals(false) &
            db.questions.difficultyLevel.equals(difficultyLevel),
      );

    return query.map((row) => row.readTable(userProgress)).get();
  }

  // ─── Progress Upsert ─────────────────────────────────────────────────────

  /// Safe upsert — only modifies [UserProgress] fields.
  /// Never touches question content.
  Future<void> upsertProgress(UserProgressCompanion companion) async {
    await into(userProgress).insertOnConflictUpdate(companion);
  }

  /// Initialises a [UserProgress] row at Stage 0 (Locked) for a new question,
  /// only if one does not already exist (preserves existing progress).
  Future<void> initProgressIfAbsent(int questionId) async {
    await into(userProgress).insertOnConflictUpdate(
      UserProgressCompanion(
        questionId: Value(questionId),
        srsStage: const Value(0),
        mistakeCount: const Value(0),
        isLessonCompleted: const Value(false),
        isCustom: const Value(false),
      ),
    );
  }

  // ─── Gating Stats ────────────────────────────────────────────────────────

  /// Returns how many questions at [difficultyLevel] have reached Guru (stage >= 5).
  Future<int> countGuruAtLevel(int difficultyLevel) async {
    final query = select(userProgress).join([
      innerJoin(
        db.questions,
        db.questions.id.equalsExp(userProgress.questionId),
      ),
    ])
      ..where(
        db.questions.difficultyLevel.equals(difficultyLevel) &
            userProgress.srsStage.isBiggerOrEqualValue(5),
      );
    final rows = await query.get();
    return rows.length;
  }

  /// Returns the total number of questions at [difficultyLevel].
  Future<int> countTotalAtLevel(int difficultyLevel) async {
    final query = select(userProgress).join([
      innerJoin(
        db.questions,
        db.questions.id.equalsExp(userProgress.questionId),
      ),
    ])
      ..where(db.questions.difficultyLevel.equals(difficultyLevel));
    final rows = await query.get();
    return rows.length;
  }

  // ─── Progress by Question ────────────────────────────────────────────────

  Future<UserProgressData?> getProgressForQuestion(int questionId) {
    return (select(userProgress)
          ..where((p) => p.questionId.equals(questionId)))
        .getSingleOrNull();
  }

  // ─── WaniKani Dashboard Metrics & Forecast ────────────────────────────────

  /// Returns count breakdown across all 5 WaniKani SRS categories:
  /// - locked: stage == 0
  /// - apprentice: stage in 1..4
  /// - guru: stage in 5..6
  /// - master: stage == 7
  /// - burned: stage == 8
  Future<SrsStageCounts> getSrsStageCounts() async {
    final all = await select(userProgress).get();
    int locked = 0;
    int apprentice = 0;
    int guru = 0;
    int master = 0;
    int burned = 0;

    for (final p in all) {
      switch (p.srsStage) {
        case 0:
          locked++;
          break;
        case 1 || 2 || 3 || 4:
          apprentice++;
          break;
        case 5 || 6:
          guru++;
          break;
        case 7:
          master++;
          break;
        case 8:
          burned++;
          break;
      }
    }

    return SrsStageCounts(
      locked: locked,
      apprentice: apprentice,
      guru: guru,
      master: master,
      burned: burned,
    );
  }

  /// Returns the closest upcoming review timestamp (or null if none pending/scheduled).
  Future<DateTime?> getNextReviewTime() async {
    final query = (select(userProgress)
      ..where((p) =>
          p.isLessonCompleted.equals(true) &
          p.nextReviewTime.isNotNull() &
          p.nextReviewTime.isBiggerThanValue(DateTime.now()))
      ..orderBy([(p) => OrderingTerm(expression: p.nextReviewTime)]))
      ..limit(1);

    final row = await query.getSingleOrNull();
    return row?.nextReviewTime;
  }

  /// Returns number of items becoming reviewable in given hour intervals.
  Future<ReviewForecast> getReviewForecast() async {
    final now = DateTime.now();
    final in1h = now.add(const Duration(hours: 1));
    final in4h = now.add(const Duration(hours: 4));
    final in24h = now.add(const Duration(hours: 24));
    final in3d = now.add(const Duration(days: 3));
    final in7d = now.add(const Duration(days: 7));

    final activeRows = await (select(userProgress)
          ..where((p) =>
              p.isLessonCompleted.equals(true) & p.nextReviewTime.isNotNull()))
        .get();

    int count1h = 0;
    int count4h = 0;
    int count24h = 0;
    int count3d = 0;
    int count7d = 0;

    for (final r in activeRows) {
      final t = r.nextReviewTime!;
      if (t.isBefore(in1h)) count1h++;
      if (t.isBefore(in4h)) count4h++;
      if (t.isBefore(in24h)) count24h++;
      if (t.isBefore(in3d)) count3d++;
      if (t.isBefore(in7d)) count7d++;
    }

    return ReviewForecast(
      within1h: count1h,
      within4h: count4h,
      within24h: count24h,
      within3d: count3d,
      within7d: count7d,
    );
  }

  /// Returns all questions that have completed lessons (or all questions) for Cram mode.
  Future<List<UserProgressData>> getAllLearnedProgress({bool mistakesOnly = false}) async {
    final query = select(userProgress)
      ..where((p) =>
          p.isLessonCompleted.equals(true) &
          (mistakesOnly ? p.mistakeCount.isBiggerThanValue(0) : const Constant(true)));
    return query.get();
  }
}

class SrsStageCounts {
  const SrsStageCounts({
    required this.locked,
    required this.apprentice,
    required this.guru,
    required this.master,
    required this.burned,
  });

  final int locked;
  final int apprentice;
  final int guru;
  final int master;
  final int burned;

  int get total => locked + apprentice + guru + master + burned;
  int get learnedTotal => apprentice + guru + master + burned;
  int get masteredTotal => guru + master + burned;
}

class ReviewForecast {
  const ReviewForecast({
    required this.within1h,
    required this.within4h,
    required this.within24h,
    required this.within3d,
    required this.within7d,
  });

  final int within1h;
  final int within4h;
  final int within24h;
  final int within3d;
  final int within7d;
}
