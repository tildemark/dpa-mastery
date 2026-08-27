import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import '../../engine/gating_service.dart';
import '../../engine/srs_engine.dart';
import '../../main.dart';
import '../../services/settings_service.dart';

// ─── Lesson flow state ────────────────────────────────────────────────────────

enum LessonPhase {
  learning, // Phase 1: Walk through concepts
  exam,     // Phase 2: Post-lesson exam quiz without concepts
}

enum LessonStep {
  concept,  // Showing concept teaching card
  question, // Showing question during quiz/exam
  feedback, // Showing answer feedback
}

/// Represents the current state of a single lesson batch with 2-phase learning.
class LessonBatchState {
  const LessonBatchState({
    required this.phase,
    required this.learningItems,
    required this.examItems,
    required this.currentIndex,
    required this.step,
    this.selectedAnswer,
    this.shuffledOptions,
    this.completedExamIds = const [],
    this.missedExamIds = const [],
    this.newTierUnlocked,
  });

  final LessonPhase phase;
  final List<Question> learningItems;
  final List<Question> examItems;
  final int currentIndex;
  final LessonStep step;
  final String? selectedAnswer;
  final List<String>? shuffledOptions;
  final List<int> completedExamIds;
  final List<int> missedExamIds;

  /// Set to the newly unlocked tier number when a tier gate was just crossed.
  /// Null otherwise.
  final int? newTierUnlocked;

  Question get currentItem =>
      phase == LessonPhase.learning ? learningItems[currentIndex] : examItems[currentIndex];

  Set<int> get uniqueExamItemIds => examItems.map((i) => i.id).toSet();

  bool get isBatchComplete =>
      phase == LessonPhase.exam &&
      (currentIndex >= examItems.length ||
          uniqueExamItemIds.every((id) => completedExamIds.contains(id)));

  bool get isCorrect => selectedAnswer == currentItem.correctAnswer;

  LessonBatchState copyWith({
    LessonPhase? phase,
    List<Question>? learningItems,
    List<Question>? examItems,
    int? currentIndex,
    LessonStep? step,
    String? selectedAnswer,
    List<String>? shuffledOptions,
    List<int>? completedExamIds,
    List<int>? missedExamIds,
    int? newTierUnlocked,
    bool clearSelectedAnswer = false,
    bool clearShuffledOptions = false,
    bool clearNewTierUnlocked = false,
  }) =>
      LessonBatchState(
        phase: phase ?? this.phase,
        learningItems: learningItems ?? this.learningItems,
        examItems: examItems ?? this.examItems,
        currentIndex: currentIndex ?? this.currentIndex,
        step: step ?? this.step,
        selectedAnswer:
            clearSelectedAnswer ? null : (selectedAnswer ?? this.selectedAnswer),
        shuffledOptions:
            clearShuffledOptions ? null : (shuffledOptions ?? this.shuffledOptions),
        completedExamIds: completedExamIds ?? this.completedExamIds,
        missedExamIds: missedExamIds ?? this.missedExamIds,
        newTierUnlocked: clearNewTierUnlocked ? null : (newTierUnlocked ?? this.newTierUnlocked),
      );
}

// ─── Lesson controller ────────────────────────────────────────────────────────

/// Manages 2-Phase SRS Lesson Flow:
/// Phase 1 (Learning): Concepts presented sequentially.
/// Phase 2 (Exam): Direct randomized questions with shuffled options and zero concepts.
/// Items are only promoted to Apprentice Stage 1 upon passing the Phase 2 Exam.
class LessonController extends StateNotifier<AsyncValue<LessonBatchState?>> {
  LessonController(this._db, this._settings, this._level)
      : super(const AsyncValue.loading()) {
    _initBatch();
  }

  final AppDatabase _db;
  final SettingsService _settings;
  final int _level;

  Future<void> _initBatch() async {
    try {
      final questions = await _db.questionDao.getUnlearnedQuestions(_level);
      if (questions.isEmpty) {
        state = const AsyncValue.data(null);
        return;
      }

      // Check available daily lesson quota
      final availableToday = _settings.getAvailableLessonsToday(questions.length);
      if (availableToday <= 0) {
        state = const AsyncValue.data(null);
        return;
      }

      // Entropy-seeded random shuffle of unlearned questions
      final mutable = List<Question>.from(questions);
      final random = Random(DateTime.now().microsecondsSinceEpoch);
      mutable.shuffle(random);

      // Take batch size up to 5, bounded by available daily quota
      final batchSize = min(5, availableToday);
      final batch = mutable.take(batchSize).toList();

      state = AsyncValue.data(
        LessonBatchState(
          phase: LessonPhase.learning,
          learningItems: batch,
          examItems: const [],
          currentIndex: 0,
          step: LessonStep.concept,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Advance to the next concept during Phase 1 (or start Phase 2 Exam).
  void nextConcept() {
    state.whenData((s) {
      if (s == null || s.phase != LessonPhase.learning) return;

      if (s.currentIndex < s.learningItems.length - 1) {
        state = AsyncValue.data(
          s.copyWith(
            currentIndex: s.currentIndex + 1,
            step: LessonStep.concept,
          ),
        );
      } else {
        // Phase 1 finished → Launch Phase 2: Post-Lesson Exam Quiz!
        // Shuffled question order
        final examQuestions = List<Question>.from(s.learningItems);
        final random = Random(DateTime.now().microsecondsSinceEpoch);
        examQuestions.shuffle(random);

        final firstQ = examQuestions.first;
        final options = _prepareOptions(firstQ);

        state = AsyncValue.data(
          s.copyWith(
            phase: LessonPhase.exam,
            examItems: examQuestions,
            currentIndex: 0,
            step: LessonStep.question,
            shuffledOptions: options,
            clearSelectedAnswer: true,
          ),
        );
      }
    });
  }

  /// Submit an answer during the Phase 2 Exam.
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

  /// Advance during the Phase 2 Exam.
  /// Correct answers promote to Stage 1; incorrect answers re-queue to the end of the exam.
  Future<void> advanceExam() async {
    final currentVal = state.asData?.value;
    if (currentVal == null || currentVal.phase != LessonPhase.exam) return;

    final currentItem = currentVal.currentItem;
    final isCorrect = currentVal.isCorrect;

    if (isCorrect) {
      // 1. Promote from Stage 0 (Locked) → Stage 1 (Apprentice 1) in database
      final companion = SrsEngine.promoteFromLesson(currentItem.id);
      await _db.progressDao.upsertProgress(companion);

      final updatedCompleted = [...currentVal.completedExamIds, currentItem.id];

      // Check if all unique exam items are completed
      if (currentVal.currentIndex >= currentVal.examItems.length - 1) {
        // Snapshot which tiers were unlocked BEFORE the final promotion
        final gating = GatingService(_db);
        final unlockedBefore = await gating.getUnlockedLevels();

        // Record quota deduction in settings
        final remainingUnlearned =
            await _db.questionDao.getUnlearnedQuestions(_level);
        await _settings.recordCompletedLessons(
          currentVal.uniqueExamItemIds.length,
          remainingUnlearned.length,
        );

        // Check if a new tier was unlocked after this batch
        final unlockedAfter = await gating.getUnlockedLevels();
        int? newlyUnlocked;
        if (unlockedAfter.length > unlockedBefore.length) {
          newlyUnlocked = unlockedAfter.last;
        }

        state = AsyncValue.data(
          currentVal.copyWith(
            completedExamIds: updatedCompleted,
            newTierUnlocked: newlyUnlocked,
          ),
        );
        return;
      }

      final nextItem = currentVal.examItems[currentVal.currentIndex + 1];
      final nextOptions = _prepareOptions(nextItem);

      state = AsyncValue.data(
        currentVal.copyWith(
          currentIndex: currentVal.currentIndex + 1,
          step: LessonStep.question,
          clearSelectedAnswer: true,
          shuffledOptions: nextOptions,
          completedExamIds: updatedCompleted,
        ),
      );
    } else {
      // Record mistake in database for troubled cards drilling
      final existingProgress =
          await _db.progressDao.getProgressForQuestion(currentItem.id);
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

      // Re-queue missed question to the end of the exam
      final updatedExamItems = List<Question>.from(currentVal.examItems)
        ..add(currentItem);
      final updatedMissed = currentVal.missedExamIds.contains(currentItem.id)
          ? currentVal.missedExamIds
          : [...currentVal.missedExamIds, currentItem.id];

      final nextItem = currentVal.examItems[currentVal.currentIndex + 1];
      final nextOptions = _prepareOptions(nextItem);

      state = AsyncValue.data(
        currentVal.copyWith(
          examItems: updatedExamItems,
          currentIndex: currentVal.currentIndex + 1,
          step: LessonStep.question,
          clearSelectedAnswer: true,
          shuffledOptions: nextOptions,
          missedExamIds: updatedMissed,
        ),
      );
    }
  }

  List<String> _prepareOptions(Question q) {
    final rawOptions = (jsonDecode(q.optionsJson) as List).cast<String>();
    if (_settings.shuffleOptions) {
      final mutable = List<String>.from(rawOptions);
      final random = Random(DateTime.now().microsecondsSinceEpoch);
      mutable.shuffle(random);
      return mutable;
    }
    return rawOptions;
  }
}

final lessonControllerProvider = StateNotifierProvider.autoDispose
    .family<LessonController, AsyncValue<LessonBatchState?>, int>((ref, level) {
  final db = ref.read(dbProvider);
  final settings = ref.read(settingsServiceProvider);
  return LessonController(db, settings, level);
});
