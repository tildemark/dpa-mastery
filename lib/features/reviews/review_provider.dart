import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import '../../engine/srs_engine.dart';
import '../../main.dart';

// ─── Session item ─────────────────────────────────────────────────────────────

/// Pairs a question with its current SRS progress for a review session.
class ReviewItem {
  const ReviewItem({required this.question, required this.progress});

  final Question question;
  final UserProgressData progress;

  List<String> get options =>
      (jsonDecode(question.optionsJson) as List).cast<String>();
}

// ─── Session state ────────────────────────────────────────────────────────────

enum ReviewStep { question, feedback }

class ReviewSessionState {
  const ReviewSessionState({
    required this.items,
    required this.currentIndex,
    required this.step,
    this.selectedAnswer,
    this.newStage,
    this.results = const [],
  });

  final List<ReviewItem> items;
  final int currentIndex;
  final ReviewStep step;
  final String? selectedAnswer;

  /// Stage the item moved to after answering (populated in feedback step).
  final int? newStage;

  /// Accumulates per-item outcomes as the session progresses.
  final List<ReviewResult> results;

  ReviewItem get current => items[currentIndex];
  bool get isLastItem => currentIndex == items.length - 1;
  bool get isSessionComplete => results.length == items.length;
  bool get isCorrect => selectedAnswer == current.question.correctAnswer;
  int get correctCount => results.where((r) => r.wasCorrect).length;
  int get incorrectCount => results.where((r) => !r.wasCorrect).length;

  ReviewSessionState copyWith({
    int? currentIndex,
    ReviewStep? step,
    String? selectedAnswer,
    int? newStage,
    List<ReviewResult>? results,
  }) =>
      ReviewSessionState(
        items: items,
        currentIndex: currentIndex ?? this.currentIndex,
        step: step ?? this.step,
        selectedAnswer: selectedAnswer ?? this.selectedAnswer,
        newStage: newStage ?? this.newStage,
        results: results ?? this.results,
      );
}

class ReviewResult {
  const ReviewResult({
    required this.questionId,
    required this.wasCorrect,
    required this.fromStage,
    required this.toStage,
  });

  final int questionId;
  final bool wasCorrect;
  final int fromStage;
  final int toStage;
}

// ─── Controller ───────────────────────────────────────────────────────────────

class ReviewController extends StateNotifier<ReviewSessionState?> {
  ReviewController(this._db) : super(null);

  final AppDatabase _db;

  /// Seeds the controller with the initial session state (called once).
  void seed(ReviewSessionState initial) {
    if (state == null) state = initial;
  }

  /// Submit the user's answer. Persists stage update immediately, then
  /// transitions to the feedback step.
  Future<void> submitAnswer(String answer) async {
    final s = state;
    if (s == null || s.step != ReviewStep.question) return;

    final isCorrect = answer == s.current.question.correctAnswer;
    final newStage = isCorrect
        ? SrsEngine.advanceStage(s.current.progress.srsStage)
        : SrsEngine.penalizeStage(s.current.progress.srsStage);

    // Persist progress immediately — answers are never lost.
    final companion = SrsEngine.processAnswer(
      progress: s.current.progress,
      isCorrect: isCorrect,
    );
    await _db.progressDao.upsertProgress(companion);

    state = s.copyWith(
      step: ReviewStep.feedback,
      selectedAnswer: answer,
      newStage: newStage,
    );
  }

  /// Record the result and advance to the next item (or finish the session).
  void advance() {
    final s = state;
    if (s == null) return;

    final result = ReviewResult(
      questionId: s.current.question.id,
      wasCorrect: s.isCorrect,
      fromStage: s.current.progress.srsStage,
      toStage: s.newStage ?? s.current.progress.srsStage,
    );
    final updatedResults = [...s.results, result];

    if (s.isLastItem) {
      state = s.copyWith(results: updatedResults);
      return;
    }

    state = s.copyWith(
      currentIndex: s.currentIndex + 1,
      step: ReviewStep.question,
      selectedAnswer: null,
      newStage: null,
      results: updatedResults,
    );
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

/// Loads all items currently due for review, paired with their question data.
final reviewQueueProvider =
    FutureProvider.autoDispose<List<ReviewItem>>((ref) async {
  final db = ref.read(dbProvider);
  final progressRows = await db.progressDao.getReviewQueue();

  final items = <ReviewItem>[];
  for (final p in progressRows) {
    final question = await db.questionDao.getQuestionById(p.questionId);
    if (question != null) {
      items.add(ReviewItem(question: question, progress: p));
    }
  }
  return items;
});

final reviewControllerProvider = StateNotifierProvider.autoDispose<
    ReviewController, ReviewSessionState?>(
  (ref) => ReviewController(ref.read(dbProvider)),
);
