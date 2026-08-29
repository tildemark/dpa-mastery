import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import '../../main.dart';
import '../../services/settings_service.dart';

/// Screen for freely drilling questions associated with a specific Tag or
/// drilling questions where the user recorded mistakes (Troubled / Missed Items).
class TagDrillScreen extends ConsumerStatefulWidget {
  const TagDrillScreen({
    super.key,
    this.tagName,
    this.missedQuestionsMode = false,
  }) : assert(missedQuestionsMode || tagName != null, 'Must provide tagName or enable missedQuestionsMode');

  final String? tagName;
  final bool missedQuestionsMode;

  static Route<void> route(String tagName) => MaterialPageRoute(
        builder: (_) => TagDrillScreen(tagName: tagName),
      );

  static Route<void> missedQuestionsRoute() => MaterialPageRoute(
        builder: (_) => const TagDrillScreen(missedQuestionsMode: true),
      );

  @override
  ConsumerState<TagDrillScreen> createState() => _TagDrillScreenState();
}

class _TagDrillScreenState extends ConsumerState<TagDrillScreen> {
  List<Question>? _questions;
  Map<int, List<String>> _questionOptions = {};
  int _currentIndex = 0;
  String? _selectedAnswer;
  int _correctCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final db = ref.read(dbProvider);
    final settings = ref.read(settingsServiceProvider);
    List<Question> list;
    if (widget.missedQuestionsMode) {
      list = await db.progressDao.getMissedQuestions();
    } else {
      list = await db.questionDao.getQuestionsByTag(widget.tagName!);
    }

    final optionsMap = <int, List<String>>{};
    for (final q in list) {
      final raw = (jsonDecode(q.optionsJson) as List).cast<String>();
      final opts = List<String>.from(raw);
      if (settings.shuffleOptions) {
        final random = Random(DateTime.now().microsecondsSinceEpoch + q.id);
        opts.shuffle(random);
      }
      optionsMap[q.id] = opts;
    }

    setState(() {
      _questions = list;
      _questionOptions = optionsMap;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final title = widget.missedQuestionsMode
        ? 'Missed Questions Review'
        : 'Drill: ${widget.tagName}';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _questions == null || _questions!.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        widget.missedQuestionsMode
                            ? 'No missed questions recorded yet! Keep studying.'
                            : 'No questions found for tag "${widget.tagName}".',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _currentIndex >= _questions!.length
                    ? _buildDrillSummary(context)
                    : _buildQuestionCard(context),
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context) {
    final q = _questions![_currentIndex];
    final options = _questionOptions[q.id] ?? (jsonDecode(q.optionsJson) as List).cast<String>();
    final hasAnswered = _selectedAnswer != null;
    final isCorrect = _selectedAnswer == q.correctAnswer;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Question ${_currentIndex + 1} of ${_questions!.length}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              q.questionText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.4),
            ),
          ),
          const SizedBox(height: 20),
          ...options.asMap().entries.map((e) {
            final idx = e.key;
            final opt = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: hasAnswered ? null : () => setState(() => _selectedAnswer = opt),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: !hasAnswered
                        ? (_selectedAnswer == opt
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest)
                        : (opt == q.correctAnswer
                            ? const Color(0xFF1B5E20).withAlpha(200)
                            : (_selectedAnswer == opt
                                ? const Color(0xFFB71C1C).withAlpha(180)
                                : Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100))),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasAnswered && opt == q.correctAnswer
                          ? const Color(0xFF4CAF50)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text('${String.fromCharCode(65 + idx)}. ',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(opt)),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (hasAnswered) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCorrect
                    ? const Color(0xFF1B5E20).withAlpha(150)
                    : const Color(0xFFB71C1C).withAlpha(130),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Explanation: ${q.explanation}',
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final db = ref.read(dbProvider);
                if (isCorrect) {
                  _correctCount++;
                  if (widget.missedQuestionsMode) {
                    await db.progressDao.decrementMistakeCount(q.id);
                  }
                }
                if (mounted) {
                  setState(() {
                    _currentIndex++;
                    _selectedAnswer = null;
                  });
                }
              },
              child: const Text('Next'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrillSummary(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, size: 64, color: Color(0xFFF59E0B)),
            const SizedBox(height: 16),
            Text(
              widget.missedQuestionsMode ? 'Review Complete!' : 'Drill Complete!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Score: $_correctCount / ${_questions!.length} correct',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (widget.missedQuestionsMode && _correctCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_correctCount mistake${_correctCount > 1 ? "s" : ""} reduced/cleared!',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (widget.missedQuestionsMode && _questions!.isNotEmpty) ...[
              OutlinedButton.icon(
                onPressed: () async {
                  final db = ref.read(dbProvider);
                  final ids = _questions!.map((q) => q.id).toList();
                  await db.progressDao.clearMistakesForQuestions(ids);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All practiced mistakes cleared!')),
                    );
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Clear All Practiced Mistakes'),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: Text(widget.missedQuestionsMode ? 'Back to Home' : 'Back to Drills'),
            ),
          ],
        ),
      ),
    );
  }
}
