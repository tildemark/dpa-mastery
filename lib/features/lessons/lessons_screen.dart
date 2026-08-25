import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lesson_provider.dart';
import 'lesson_widgets.dart';
import 'lesson_summary_screen.dart';

/// Main entry point for the Lessons Mode experience.
///
/// Fetches up to 5 unlearned questions for [difficultyLevel], then steps
/// through: Concept Card → Question Card → Feedback → next item.
/// On batch completion, pushes [LessonSummaryScreen].
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
      duration: const Duration(milliseconds: 300),
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
        title: Text(
          'Lessons — Level ${widget.difficultyLevel}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: batchAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (batch) {
          if (batch == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      size: 64, color: cs.primary),
                  const SizedBox(height: 16),
                  Text(
                    'All lessons at this level are complete!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to Home'),
                  ),
                ],
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
        final uniqueItemIds = state.items.map((i) => i.id).toSet();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LessonSummaryScreen(
              completedCount: state.completedIds.length,
              totalCount: uniqueItemIds.length,
              difficultyLevel: difficultyLevel,
            ),
          ),
        );
      });
      return const Center(child: CircularProgressIndicator());
    }

    final item = state.currentItem;
    final options = (jsonDecode(item.optionsJson) as List)
        .map((e) => e as String)
        .toList();

    return FadeTransition(
      opacity: fadeAnim,
      child: switch (state.step) {
        LessonStep.concept => ConceptCard(
            conceptText: item.lessonConcept,
            questionNumber: state.currentIndex + 1,
            totalQuestions: state.items.length,
            difficultyLevel: difficultyLevel,
            onContinue: () =>
                onTransition(() async => controller.proceedToQuestion()),
          ),
        LessonStep.question || LessonStep.feedback => QuestionCard(
            questionText: item.questionText,
            options: options,
            questionNumber: state.currentIndex + 1,
            totalQuestions: state.items.length,
            difficultyLevel: difficultyLevel,
            selectedAnswer: state.selectedAnswer,
            correctAnswer:
                state.step == LessonStep.feedback ? item.correctAnswer : null,
            onOptionSelected: (ans) =>
                onTransition(() async => controller.submitAnswer(ans)),
            onNext: () => onTransition(() async => controller.advance()),
          ),
      },
    );
  }
}
