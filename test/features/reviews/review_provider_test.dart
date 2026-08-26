import 'package:flutter_test/flutter_test.dart';
import 'package:dpa_mastery/db/app_database.dart';
import 'package:dpa_mastery/features/reviews/review_provider.dart';

void main() {
  group('ReviewSessionState & advance logic', () {
    test('Advancing resets selectedAnswer and newStage for subsequent questions', () {
      final q1 = Question(
        id: 1,
        difficultyLevel: 1,
        lessonConcept: 'Concept 1',
        questionText: 'Question 1',
        optionsJson: '["A", "B", "C", "D"]',
        correctAnswer: 'A',
        explanation: 'Exp 1',
      );
      final q2 = Question(
        id: 2,
        difficultyLevel: 1,
        lessonConcept: 'Concept 2',
        questionText: 'Question 2',
        optionsJson: '["A", "B", "C", "D"]',
        correctAnswer: 'B',
        explanation: 'Exp 2',
      );

      final p1 = UserProgressData(
        questionId: 1,
        srsStage: 1,
        mistakeCount: 0,
        isLessonCompleted: true,
        isCustom: false,
      );
      final p2 = UserProgressData(
        questionId: 2,
        srsStage: 1,
        mistakeCount: 0,
        isLessonCompleted: true,
        isCustom: false,
      );

      var state = ReviewSessionState(
        items: [
          ReviewItem(question: q1, progress: p1),
          ReviewItem(question: q2, progress: p2),
        ],
        currentIndex: 0,
        step: ReviewStep.question,
      );

      // User answers question 1
      state = state.copyWith(
        step: ReviewStep.feedback,
        selectedAnswer: 'A',
        newStage: 2,
      );

      expect(state.selectedAnswer, 'A');
      expect(state.newStage, 2);
      expect(state.step, ReviewStep.feedback);

      // Advance to question 2
      final result = ReviewResult(
        questionId: state.current.question.id,
        wasCorrect: state.isCorrect,
        fromStage: state.current.progress.srsStage,
        toStage: state.newStage ?? state.current.progress.srsStage,
      );
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        step: ReviewStep.question,
        clearSelectedAnswer: true,
        clearNewStage: true,
        results: [result],
      );

      expect(state.currentIndex, 1);
      expect(state.current.question.id, 2);
      expect(state.selectedAnswer, isNull);
      expect(state.newStage, isNull);
      expect(state.step, ReviewStep.question);
    });
  });
}
