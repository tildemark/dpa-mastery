import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'review_provider.dart';
import 'review_card.dart';
import 'review_summary_screen.dart';

/// Entry point for the Reviews Mode experience.
///
/// Loads the review queue, seeds the [ReviewController], and steps
/// through each due item. On completion, pushes [ReviewSummaryScreen].
class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const ReviewsScreen());

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _transitionTo(Future<void> Function() action) async {
    await _animController.reverse();
    await action();
    if (mounted) await _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(reviewQueueProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Exit Reviews',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Reviews',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: queueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return _EmptyQueue(cs: cs);
          }

          if (!_initialised) {
            _initialised = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(reviewControllerProvider.notifier).seed(
                    ReviewSessionState(
                      items: items,
                      currentIndex: 0,
                      step: ReviewStep.question,
                    ),
                  );
            });
          }

          return _ReviewFlow(
            fadeAnim: _fadeAnim,
            onTransition: _transitionTo,
          );
        },
      ),
    );
  }
}

// ─── Review flow body ─────────────────────────────────────────────────────────

class _ReviewFlow extends ConsumerWidget {
  const _ReviewFlow({
    required this.fadeAnim,
    required this.onTransition,
  });

  final Animation<double> fadeAnim;
  final Future<void> Function(Future<void> Function()) onTransition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewControllerProvider);
    final controller = ref.read(reviewControllerProvider.notifier);

    if (state == null) return const Center(child: CircularProgressIndicator());

    // Session complete → push summary.
    if (state.isSessionComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ReviewSummaryScreen(
              results: state.results,
              totalItems: state.items.length,
            ),
          ),
        );
      });
      return const Center(child: CircularProgressIndicator());
    }

    return FadeTransition(
      opacity: fadeAnim,
      child: ReviewCard(
        item: state.current,
        questionNumber: state.currentIndex + 1,
        totalQuestions: state.items.length,
        selectedAnswer: state.selectedAnswer,
        newStage: state.newStage,
        onOptionSelected: (ans) =>
            onTransition(() => controller.submitAnswer(ans)),
        onNext: () => onTransition(() async => controller.advance()),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_empty_rounded, size: 64, color: cs.primary),
            const SizedBox(height: 20),
            Text(
              'No Reviews Due',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              'All caught up! Come back when your next review is ready.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Back to Home'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
