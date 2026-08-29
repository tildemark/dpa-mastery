import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../services/app_time.dart';

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
    final now = AppTime.now();
    return (select(userProgress)
          ..where((p) =>
              p.isLessonCompleted.equals(true) &
              p.nextReviewTime.isSmallerOrEqualValue(now)))
        .watch();
  }

  Future<List<UserProgressData>> getReviewQueue() {
    final now = AppTime.now();
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

  /// Counts all active reviews currently due according to [AppTime.now()].
  Future<int> countDueReviews() async {
    final now = AppTime.now();
    final due = await (select(userProgress)
          ..where((p) =>
              p.isLessonCompleted.equals(true) &
              p.nextReviewTime.isNotNull() &
              p.nextReviewTime.isSmallerOrEqualValue(now)))
        .get();
    return due.length;
  }

  /// Makes all active SRS review items due immediately (sets nextReviewTime to past).
  Future<int> makeAllReviewsDueNow() async {
    return (update(userProgress)
          ..where((p) => p.isLessonCompleted.equals(true)))
        .write(
      UserProgressCompanion(
        nextReviewTime: Value(AppTime.now().subtract(const Duration(minutes: 1))),
      ),
    );
  }

  /// Advances all active items to the next SRS stage and makes them due now.
  Future<void> advanceAllSrsStages() async {
    final all = await (select(userProgress)..where((p) => p.isLessonCompleted.equals(true))).get();
    for (final p in all) {
      final nextStage = (p.srsStage + 1).clamp(1, 8);
      await (update(userProgress)..where((row) => row.questionId.equals(p.questionId))).write(
        UserProgressCompanion(
          srsStage: Value(nextStage),
          nextReviewTime: Value(AppTime.now().subtract(const Duration(minutes: 1))),
        ),
      );
    }
  }

  /// Promotes unlearned questions in a given level to Apprentice 1 (simulates passing lessons),
  /// with an optional [limit] count (e.g. 5, 10, or all if null).
  Future<int> promoteLevelToApprentice(int level, {int? limit}) async {
    final questions = await (select(db.questions)..where((q) => q.difficultyLevel.equals(level))).get();
    int promoted = 0;
    for (final q in questions) {
      if (limit != null && limit > 0 && promoted >= limit) break;
      final existing = await getProgressForQuestion(q.id);
      if (existing == null || existing.srsStage == 0) {
        await into(userProgress).insertOnConflictUpdate(
          UserProgressCompanion(
            questionId: Value(q.id),
            srsStage: const Value(1),
            isLessonCompleted: const Value(true),
            mistakeCount: const Value(0),
            nextReviewTime: Value(AppTime.now().add(const Duration(hours: 4))),
          ),
        );
        promoted++;
      }
    }
    return promoted;
  }

  /// Promotes all questions in a given level to Guru (Stage 5) and marks next reviews.
  Future<int> promoteLevelToGuru(int level) async {
    final questions = await (select(db.questions)..where((q) => q.difficultyLevel.equals(level))).get();
    for (final q in questions) {
      await into(userProgress).insertOnConflictUpdate(
        UserProgressCompanion(
          questionId: Value(q.id),
          srsStage: const Value(5),
          isLessonCompleted: const Value(true),
          mistakeCount: const Value(0),
          nextReviewTime: Value(AppTime.now().add(const Duration(days: 7))),
        ),
      );
    }
    return questions.length;
  }

  /// Answers all currently due reviews correctly (+1 Stage advance for each due review item).
  Future<int> answerAllDueReviewsCorrectly() async {
    final now = AppTime.now();
    final due = await (select(userProgress)
          ..where((p) =>
              p.isLessonCompleted.equals(true) &
              p.nextReviewTime.isNotNull() &
              p.nextReviewTime.isSmallerOrEqualValue(now)))
        .get();

    for (final p in due) {
      final nextStage = (p.srsStage + 1).clamp(1, 8);
      final nextInterval = switch (nextStage) {
        2 => const Duration(hours: 8),
        3 => const Duration(hours: 24),
        4 => const Duration(hours: 48),
        5 => const Duration(days: 7),
        6 => const Duration(days: 14),
        7 => const Duration(days: 30),
        8 => null, // Burned
        _ => const Duration(hours: 4),
      };

      await (update(userProgress)..where((row) => row.questionId.equals(p.questionId))).write(
        UserProgressCompanion(
          srsStage: Value(nextStage),
          nextReviewTime: Value(nextInterval != null ? now.add(nextInterval) : null),
        ),
      );
    }
    return due.length;
  }

  /// Unlocks and promotes items directly to Guru (Stage 5) to test higher difficulty tiers.
  Future<void> promoteTier1ToGuru() => promoteLevelToGuru(1);

  /// Resets all user progress records back to Stage 0 (Locked).
  Future<void> resetAllProgress() async {
    await update(userProgress).write(
      const UserProgressCompanion(
        srsStage: Value(0),
        mistakeCount: Value(0),
        isLessonCompleted: Value(false),
        nextReviewTime: Value(null),
      ),
    );
  }

  /// Deletes all user progress rows (full table wipe).
  Future<void> clearAllProgress() async {
    await delete(userProgress).go();
  }

  /// Initialises a [UserProgress] row at Stage 0 (Locked) for a new question,
  /// only if one does not already exist (preserves existing progress on every app launch).
  Future<void> initProgressIfAbsent(int questionId) async {
    await into(userProgress).insert(
      UserProgressCompanion(
        questionId: Value(questionId),
        srsStage: const Value(0),
        mistakeCount: const Value(0),
        isLessonCompleted: const Value(false),
        isCustom: const Value(false),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  // ─── Gating Stats ────────────────────────────────────────────────────────

  /// Returns how many questions at [difficultyLevel] have reached Guru (stage >= 5).
  /// Joins UserProgress so only questions that have been started are counted.
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

  /// Returns the total number of questions at [difficultyLevel] from the
  /// Questions table directly — accurate even before UserProgress rows exist
  /// (i.e. with lazy progress initialisation).
  Future<int> countTotalAtLevel(int difficultyLevel) async {
    final rows = await (select(db.questions)
          ..where((q) => q.difficultyLevel.equals(difficultyLevel)))
        .get();
    return rows.length;
  }

  /// Convenience alias — same as [countTotalAtLevel] but named for clarity at
  /// call sites that explicitly want the raw question count.
  Future<int> countQuestionsAtLevel(int difficultyLevel) =>
      countTotalAtLevel(difficultyLevel);

  // ─── Progress by Question ────────────────────────────────────────────────

  Future<UserProgressData?> getProgressForQuestion(int questionId) {
    return (select(userProgress)
          ..where((p) => p.questionId.equals(questionId)))
        .getSingleOrNull();
  }

  /// Detects the "eager init" footprint from older app versions:
  /// All 282 questions were pre-inserted at stage 0 before lazy-init was
  /// introduced.  If the user has zero real progress (apprentice/guru/master/
  /// burned == 0) we safely wipe those stage-0 rows so the lazy path takes
  /// over and the home screen shows "Available: 43" instead of "Locked: 282".
  Future<void> migrateEagerProgressRows() async {
    final all = await select(userProgress).get();
    if (all.isEmpty) return; // already clean

    // If any real progress exists, do NOT migrate — preserve the user's data.
    final hasRealProgress = all.any((p) => p.srsStage > 0);
    if (hasRealProgress) return;

    // All rows are stage 0 — legacy eager init. Wipe so lazy path takes over.
    await delete(userProgress).go();
  }

  // ─── WaniKani Dashboard Metrics & Forecast ────────────────────────────────

  /// Returns count breakdown across all 5 WaniKani SRS categories.
  ///
  /// With lazy progress initialisation, questions have no [UserProgress] row
  /// until they are first encountered in a lesson.  The [available] count
  /// represents Tier-1 (difficultyLevel == 1) questions that have not yet
  /// started — i.e. no progress row OR progress row at stage 0.
  ///
  /// Categories:
  /// - available: Tier-1 questions not yet started (no row or stage 0)
  /// - apprentice: stage in 1..4
  /// - guru: stage in 5..6
  /// - master: stage == 7
  /// - burned: stage == 8
  Future<SrsStageCounts> getSrsStageCounts() async {
    final allProgress = await select(userProgress).get();
    int apprentice = 0;
    int guru = 0;
    int master = 0;
    int burned = 0;
    final progressMap = <int, int>{};

    for (final p in allProgress) {
      progressMap[p.questionId] = p.srsStage;
      switch (p.srsStage) {
        case 0:
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

    // Determine unlocked levels without calling getSrsStageCounts recursively
    final allQuestions = await select(db.questions).get();
    final totalByLevel = <int, int>{for (int l = 1; l <= 5; l++) l: 0};
    final guruByLevel = <int, int>{for (int l = 1; l <= 5; l++) l: 0};

    for (final q in allQuestions) {
      final lvl = q.difficultyLevel;
      if (lvl >= 1 && lvl <= 5) {
        totalByLevel[lvl] = (totalByLevel[lvl] ?? 0) + 1;
        if ((progressMap[q.id] ?? 0) >= 5) {
          guruByLevel[lvl] = (guruByLevel[lvl] ?? 0) + 1;
        }
      }
    }

    final totalMastered = guru + master + burned;
    final unlockedLevels = <int>[1];
    for (int l = 2; l <= 5; l++) {
      final reqGurus = switch (l) {
        2 => 35,
        3 => 75,
        4 => 150,
        5 => 250,
        _ => 35,
      };
      if (totalMastered >= reqGurus) {
        unlockedLevels.add(l);
        continue;
      }
      final prevTot = totalByLevel[l - 1] ?? 0;
      if (prevTot > 0 && ((guruByLevel[l - 1] ?? 0) / prevTot) >= 0.85) {
        unlockedLevels.add(l);
      } else {
        break;
      }
    }

    int available = 0;
    for (final q in allQuestions) {
      if (unlockedLevels.contains(q.difficultyLevel)) {
        final stage = progressMap[q.id] ?? 0;
        if (stage == 0) {
          available++;
        }
      }
    }

    return SrsStageCounts(
      available: available,
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
          p.nextReviewTime.isBiggerThanValue(AppTime.now()))
      ..orderBy([(p) => OrderingTerm(expression: p.nextReviewTime)]))
      ..limit(1);

    final row = await query.getSingleOrNull();
    return row?.nextReviewTime;
  }

  /// Returns number of items becoming reviewable in given hour intervals.
  Future<ReviewForecast> getReviewForecast() async {
    final now = AppTime.now();
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

  /// Returns questions where the user has recorded 1 or more mistakes,
  /// sorted by most mistakes first.
  Future<List<Question>> getMissedQuestions() async {
    final query = select(userProgress).join([
      innerJoin(db.questions, db.questions.id.equalsExp(userProgress.questionId)),
    ])
      ..where(userProgress.mistakeCount.isBiggerThanValue(0))
      ..orderBy([OrderingTerm.desc(userProgress.mistakeCount)]);

    final rows = await query.get();
    return rows.map((r) => r.readTable(db.questions)).toList();
  }

  /// Live count stream of questions with mistakes.
  Stream<int> watchMissedQuestionsCount() {
    return (select(userProgress)
          ..where((p) => p.mistakeCount.isBiggerThanValue(0)))
        .watch()
        .map((list) => list.length);
  }

  /// Decrements the mistakeCount for a question (min 0) when answered correctly during review.
  Future<void> decrementMistakeCount(int questionId) async {
    final progress = await getProgressForQuestion(questionId);
    if (progress != null && progress.mistakeCount > 0) {
      await (update(userProgress)..where((p) => p.questionId.equals(questionId))).write(
        UserProgressCompanion(
          mistakeCount: Value((progress.mistakeCount - 1).clamp(0, 999999)),
        ),
      );
    }
  }

  /// Clears mistake count (sets to 0) for a specific set of question IDs.
  Future<void> clearMistakesForQuestions(List<int> questionIds) async {
    if (questionIds.isEmpty) return;
    await (update(userProgress)..where((p) => p.questionId.isIn(questionIds))).write(
      const UserProgressCompanion(
        mistakeCount: Value(0),
      ),
    );
  }
}

class SrsStageCounts {
  const SrsStageCounts({
    required this.available,
    required this.apprentice,
    required this.guru,
    required this.master,
    required this.burned,
  });

  /// Tier-1 questions not yet started (shown on home screen as "Available").
  final int available;
  final int apprentice;
  final int guru;
  final int master;
  final int burned;

  int get total => available + apprentice + guru + master + burned;
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
