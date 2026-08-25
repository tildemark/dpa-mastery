import 'dart:math';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import '../../engine/srs_engine.dart';
import '../../main.dart';

// ─── Lesson flow state ────────────────────────────────────────────────────────

enum LessonStep { concept, question, feedback }

/// Represents the current state of a single lesson batch.
class LessonBatchState {
  const LessonBatchState({
    required this.items,
    required this.currentIndex,
    required this.step,
    this.selectedAnswer,
    this.completedIds = const [],
    this.missedIds = const [],
  });

  final List<Question> items;
  final int currentIndex;
  final LessonStep step;
  final String? selectedAnswer;
  final List<int> completedIds;
  final List<int> missedIds;

  Question get currentItem => items[currentIndex];
  Set<int> get uniqueItemIds => items.map((i) => i.id).toSet();
  bool get isBatchComplete =>
      currentIndex >= items.length ||
      uniqueItemIds.every((id) => completedIds.contains(id));
  bool get isCorrect => selectedAnswer == currentItem.correctAnswer;

  LessonBatchState copyWith({
    List<Question>? items,
    int? currentIndex,
    LessonStep? step,
    String? selectedAnswer,
    List<int>? completedIds,
    List<int>? missedIds,
    bool clearSelectedAnswer = false,
  }) =>
      LessonBatchState(
        items: items ?? this.items,
        currentIndex: currentIndex ?? this.currentIndex,
        step: step ?? this.step,
        selectedAnswer:
            clearSelectedAnswer ? null : (selectedAnswer ?? this.selectedAnswer),
        completedIds: completedIds ?? this.completedIds,
        missedIds: missedIds ?? this.missedIds,
      );
}

// ─── Lesson controller ────────────────────────────────────────────────────────

/// Manages in-session lesson flow mutations:
/// 1. Concept Card → Question Card → Feedback.
/// 2. If incorrect: marks question as missed (increments mistakeCount in DB),
///    and appends the question to the end of the lesson queue until answered correctly.
/// 3. If correct: marks as completed and promotes to Apprentice 1 (Stage 1).
class LessonController extends StateNotifier<AsyncValue<LessonBatchState?>> {
  LessonController(this._db, this._level) : super(const AsyncValue.loading()) {
    _initBatch();
  }

  final AppDatabase _db;
  final int _level;

  Future<void> _initBatch() async {
    try {
      final questions = await _db.questionDao.getUnlearnedQuestions(_level);
      if (questions.isEmpty) {
        state = const AsyncValue.data(null);
      } else {
        // Entropy-seeded random shuffle of unlearned questions at this level
        final mutable = List<Question>.from(questions);
        final random = Random(DateTime.now().microsecondsSinceEpoch);
        mutable.shuffle(random);

        final batch = mutable.take(5).toList();
        state = AsyncValue.data(
          LessonBatchState(
            items: batch,
            currentIndex: 0,
            step: LessonStep.concept,
          ),
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Move from concept view to question view.
  void proceedToQuestion() {
    state.whenData((s) {
      if (s == null) return;
      state = AsyncValue.data(
        s.copyWith(
          step: LessonStep.question,
          clearSelectedAnswer: true,
        ),
      );
    });
  }

  /// Submit the user's answer. Transitions to feedback step.
  void submitAnswer(String answer) {
    state.whenData((s) {
      if (s == null || s.step != LessonStep.question) return;
      state = AsyncValue.data(
        s.copyWith(
          step: LessonStep.feedback,
          selectedAnswer: answer,
        ),
      );
    });
  }

  /// Advance to the next item.
  /// - If correct: promotes to Stage 1 (Apprentice 1), records completion.
  /// - If incorrect: records mistake, re-queues question to the end of the batch.
  Future<void> advance() async {
    final currentVal = state.asData?.value;
    if (currentVal == null) return;

    final currentItem = currentVal.currentItem;
    final isCorrect = currentVal.isCorrect;

    if (isCorrect) {
      // Promote from Lesson (Stage 0 -> Stage 1)
      final companion = SrsEngine.promoteFromLesson(currentItem.id);
      await _db.progressDao.upsertProgress(companion);

      final updatedCompleted = [...currentVal.completedIds, currentItem.id];

      // Check if all items in current batch are completed
      if (currentVal.currentIndex >= currentVal.items.length - 1) {
        state = AsyncValue.data(
          currentVal.copyWith(
            completedIds: updatedCompleted,
            step: LessonStep.concept,
          ),
        );
        return;
      }

      state = AsyncValue.data(
        currentVal.copyWith(
          currentIndex: currentVal.currentIndex + 1,
          step: LessonStep.concept,
          clearSelectedAnswer: true,
          completedIds: updatedCompleted,
        ),
      );
    } else {
      // Record mistake count in database for troubled cards drilling
      final existingProgress = await _db.progressDao.getProgressForQuestion(currentItem.id);
      final currentMistakes = existingProgress?.mistakeCount ?? 0;
      await _db.progressDao.upsertProgress(
        UserProgressCompanion(
          questionId: Value(currentItem.id),
          srsStage: Value(existingProgress?.srsStage ?? 0),
          mistakeCount: Value(currentMistakes + 1),
          isLessonCompleted: Value(existingProgress?.isLessonCompleted ?? false),
          isCustom: Value(existingProgress?.isCustom ?? false),
        ),
      );

      // Re-queue the missed question at the end of the current batch (WaniKani style loop)
      final updatedItems = List<Question>.from(currentVal.items)..add(currentItem);
      final updatedMissed = currentVal.missedIds.contains(currentItem.id)
          ? currentVal.missedIds
          : [...currentVal.missedIds, currentItem.id];

      state = AsyncValue.data(
        currentVal.copyWith(
          items: updatedItems,
          currentIndex: currentVal.currentIndex + 1,
          step: LessonStep.concept,
          clearSelectedAnswer: true,
          missedIds: updatedMissed,
        ),
      );
    }
  }
}

final lessonControllerProvider = StateNotifierProvider.autoDispose
    .family<LessonController, AsyncValue<LessonBatchState?>, int>((ref, level) {
  final db = ref.read(dbProvider);
  return LessonController(db, level);
});
