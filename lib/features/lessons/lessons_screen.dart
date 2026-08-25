import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lesson_provider.dart';
import 'lesson_widgets.dart';
import 'lesson_summary_screen.dart';

/// Main entry point for the Lessons Mode experience.
///
/// Steps through 2 phases:
/// 1. Phase 1 (Concepts): sequential concept teaching cards for the batch.
/// 2. Phase 2 (Quiz Exam): direct questions in randomized order with shuffled choices.
/// Promotes items into SRS mastery upon batch completion.
class LessonsScreen extends ConsumerStatefulWidget {
  const LessonsScreen({super.key, required this.difficultyLevel});

  final int difficultyLevel;

  static Route<void> route(int level) => MaterialPageRoute(
        builder: (_) => LessonsScreen(difficultyLevel: level),
      );

  @override
  ConsumerState<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends ConsumerState<LessonsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Animate out → update state → animate in.
  Future<void> _transitionTo(Future<void> Function() action) async {
    await _animController.reverse();
    await action();
    if (mounted) await _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final batchAsync =
        ref.watch(lessonControllerProvider(widget.difficultyLevel));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Exit Lessons',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: batchAsync.when(
          data: (batch) => Text(
            batch?.phase == LessonPhase.exam
                ? 'Lesson Exam Quiz'
                : 'Lesson Concepts (Level ${widget.difficultyLevel})',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          loading: () => const Text('Loading Lessons...'),
          error: (e, st) => const Text('Lessons'),
        ),
        centerTitle: true,
      ),
      body: batchAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (batch) {
          if (batch == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 64, color: cs.primary),
                    const SizedBox(height: 16),
                    Text(
                      'All caught up for today!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You have completed your daily lesson commitment or finished all cards for this level.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
              ),
            );
          }

          return _LessonFlow(
            difficultyLevel: widget.difficultyLevel,
            state: batch,
            fadeAnim: _fadeAnim,
            onTransition: _transitionTo,
          );
        },
      ),
    );
  }
}

// ─── Lesson flow body ─────────────────────────────────────────────────────────

class _LessonFlow extends ConsumerWidget {
  const _LessonFlow({
    required this.difficultyLevel,
    required this.state,
    required this.fadeAnim,
    required this.onTransition,
  });

  final int difficultyLevel;
  final LessonBatchState state;
  final Animation<double> fadeAnim;
  final Future<void> Function(Future<void> Function()) onTransition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.read(lessonControllerProvider(difficultyLevel).notifier);

    // Batch complete → push summary.
    if (state.isBatchComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LessonSummaryScreen(
              completedCount: state.completedExamIds.length,
              totalCount: state.uniqueExamItemIds.length,
              mistakesCount: state.missedExamIds.length,
              difficultyLevel: difficultyLevel,
            ),
          ),
        );
      });
      return const Center(child: CircularProgressIndicator());
    }

    final item = state.currentItem;

    return FadeTransition(
      opacity: fadeAnim,
      child: state.phase == LessonPhase.learning
          ? ConceptCard(
              conceptText: item.lessonConcept,
              questionNumber: state.currentIndex + 1,
              totalQuestions: state.learningItems.length,
              difficultyLevel: difficultyLevel,
              onContinue: () =>
                  onTransition(() async => controller.nextConcept()),
            )
          : QuestionCard(
              questionText: item.questionText,
              options: state.shuffledOptions ?? [],
              questionNumber: state.currentIndex + 1,
              totalQuestions: state.examItems.length,
              difficultyLevel: difficultyLevel,
              selectedAnswer: state.selectedAnswer,
              correctAnswer:
                  state.step == LessonStep.feedback ? item.correctAnswer : null,
              onOptionSelected: (ans) =>
                  onTransition(() async => controller.submitAnswer(ans)),
              onNext: () =>
                  onTransition(() async => controller.advanceExam()),
            ),
    );
  }
}
