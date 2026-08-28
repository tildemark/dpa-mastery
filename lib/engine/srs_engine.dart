import 'package:drift/drift.dart' show Value;

import '../db/app_database.dart';
import '../services/app_time.dart';

/// WaniKani-style SRS engine for DPA Mastery.
///
/// Stages:
///   0 = Locked (initial state, awaiting Lessons Mode)
///   1 = Apprentice 1  → 4 hours
///   2 = Apprentice 2  → 8 hours
///   3 = Apprentice 3  → 24 hours
///   4 = Apprentice 4  → 48 hours
///   5 = Guru 1        → 1 week
///   6 = Guru 2        → 2 weeks
///   7 = Master        → 1 month (30 days)
///   8 = Burned        → retired (no nextReviewTime)
class SrsEngine {
  SrsEngine._();

  // ─── Stage intervals ──────────────────────────────────────────────────────

  static const Map<int, Duration> _intervals = {
    1: Duration(hours: 4),
    2: Duration(hours: 8),
    3: Duration(hours: 24),
    4: Duration(hours: 48),
    5: Duration(days: 7),
    6: Duration(days: 14),
    7: Duration(days: 30),
  };

  /// Returns the review interval for [stage].
  /// Returns null for Stage 0 (Locked) and Stage 8 (Burned).
  static Duration? intervalForStage(int stage) => _intervals[stage];

  // ─── Stage transitions ────────────────────────────────────────────────────

  /// Advances [currentStage] by 1 on a correct answer.
  /// Clamps at Stage 8 (Burned).
  static int advanceStage(int currentStage) {
    if (currentStage >= 8) return 8;
    return currentStage + 1;
  }

  /// Applies WaniKani penalty on an incorrect answer:
  ///
  /// - Apprentice (1–4): drop 1 stage (minimum Stage 1).
  /// - Guru (5–6):       demote to Apprentice 1 (Stage 1).
  /// - Master (7):       demote to Guru 1 (Stage 5).
  /// - Burned / Locked:  no change.
  static int penalizeStage(int currentStage) {
    if (currentStage >= 1 && currentStage <= 4) {
      return (currentStage - 1).clamp(1, 4);
    }
    if (currentStage == 5 || currentStage == 6) {
      return 1; // → Apprentice 1
    }
    if (currentStage == 7) {
      return 5; // → Guru 1
    }
    return currentStage; // 0 or 8 — no change
  }

  // ─── Next review time ─────────────────────────────────────────────────────

  /// Calculates the next review DateTime based on [newStage].
  /// Returns null for Stage 0 and Stage 8 (no review scheduled).
  static DateTime? calcNextReviewTime(int newStage) {
    final interval = intervalForStage(newStage);
    if (interval == null) return null;
    return AppTime.now().add(interval);
  }

  // ─── Full answer processing ───────────────────────────────────────────────

  /// Processes an answer in Reviews Mode and returns an updated
  /// [UserProgressCompanion] ready to be persisted.
  ///
  /// [progress] — the current progress row.
  /// [isCorrect] — whether the user answered correctly.
  static UserProgressCompanion processAnswer({
    required UserProgressData progress,
    required bool isCorrect,
  }) {
    final newStage = isCorrect
        ? advanceStage(progress.srsStage)
        : penalizeStage(progress.srsStage);

    final nextReview = calcNextReviewTime(newStage);

    return UserProgressCompanion(
      questionId: Value(progress.questionId),
      srsStage: Value(newStage),
      mistakeCount: Value(
        isCorrect ? progress.mistakeCount : progress.mistakeCount + 1,
      ),
      nextReviewTime: Value(nextReview),
      isLessonCompleted: const Value(true),
      isCustom: Value(progress.isCustom),
    );
  }

  /// Promotes a question from Stage 0 → Stage 1 after a successful Lessons
  /// Mode completion. Sets the first review timer to now + 4 hours.
  static UserProgressCompanion promoteFromLesson(int questionId) {
    return UserProgressCompanion(
      questionId: Value(questionId),
      srsStage: const Value(1),
      mistakeCount: const Value(0),
      nextReviewTime: Value(AppTime.now().add(const Duration(hours: 4))),
      isLessonCompleted: const Value(true),
      isCustom: const Value(false),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  /// Human-readable label for a stage index.
  static String stageLabel(int stage) {
    return switch (stage) {
      0 => 'Locked',
      1 => 'Apprentice 1',
      2 => 'Apprentice 2',
      3 => 'Apprentice 3',
      4 => 'Apprentice 4',
      5 => 'Guru 1',
      6 => 'Guru 2',
      7 => 'Master',
      8 => 'Burned',
      _ => 'Unknown',
    };
  }
}
