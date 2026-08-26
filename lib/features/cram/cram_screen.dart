import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import '../../main.dart';

/// Modal bottom sheet to configure a customized Cram / Self-Study session.
/// Modal bottom sheet to configure a customized Cram / Self-Study session.
class CramSetupSheet extends ConsumerStatefulWidget {
  const CramSetupSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CramSetupSheet(),
    );
  }

  @override
  ConsumerState<CramSetupSheet> createState() => _CramSetupSheetState();
}

class _CramSetupSheetState extends ConsumerState<CramSetupSheet> {
  int? _selectedModule; // null = all modules, 1..7
  int? _selectedLevel; // null = all levels, 1..5
  bool _troubledOnly = false;
  int _questionCount = 10; // 5, 10, 20, All (0)
  String? _selectedTag;
  List<String> _availableTags = [];

  static const _moduleNames = {
    1: 'Module 1: General Provisions & Framework',
    2: 'Module 2: Key Concepts & Definitions',
    3: 'Module 3: General Data Privacy Principles',
    4: 'Module 4: Lawful Processing Criteria',
    5: 'Module 5: Data Subject Rights',
    6: 'Module 6: Accountability & Penalties',
    7: 'Module 7: Data Breach Management',
  };

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final db = ref.read(dbProvider);
    final tags = await (db.select(db.tags)).get();
    setState(() {
      _availableTags = tags
          .map((t) => t.name)
          .where((name) => !name.toLowerCase().startsWith('module'))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Header & Drag Handle ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: cs.outlineVariant.withAlpha(150),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Customize Cram Session',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    Text(
                      'Select modules, difficulty tiers, and topics to study on demand.',
                      style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // ── Scrollable Body ──
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  children: [
                    // ── 1. NPC Exam Module Filter (1 to 7) ──
                    const Text('NPC Exam Module', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All Modules'),
                          selected: _selectedModule == null,
                          onSelected: (_) => setState(() => _selectedModule = null),
                        ),
                        ...[1, 2, 3, 4, 5, 6, 7].map((m) {
                          return ChoiceChip(
                            label: Text('Module $m'),
                            selected: _selectedModule == m,
                            onSelected: (val) => setState(() => _selectedModule = val ? m : null),
                          );
                        }),
                      ],
                    ),
                    if (_selectedModule != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withAlpha(120),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _moduleNames[_selectedModule] ?? '',
                          style: TextStyle(fontSize: 12, color: cs.onPrimaryContainer, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // ── 2. Difficulty Level Selector ──
                    const Text('Difficulty Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All Levels'),
                          selected: _selectedLevel == null,
                          onSelected: (_) => setState(() => _selectedLevel = null),
                        ),
                        ...[1, 2, 3, 4, 5].map((level) {
                          return ChoiceChip(
                            label: Text('Level $level'),
                            selected: _selectedLevel == level,
                            onSelected: (val) => setState(() => _selectedLevel = val ? level : null),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── 3. Session Size (Question Count) ──
                    const Text('Session Size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 5, label: Text('5')),
                        ButtonSegment(value: 10, label: Text('10')),
                        ButtonSegment(value: 20, label: Text('20')),
                        ButtonSegment(value: 0, label: Text('All')),
                      ],
                      selected: {_questionCount},
                      onSelectionChanged: (val) => setState(() => _questionCount = val.first),
                    ),
                    const SizedBox(height: 20),

                    // ── 4. Specific Concept / Topic Tag Filter ──
                    if (_availableTags.isNotEmpty) ...[
                      const Text('Specific Topic Tag (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('All Topics'),
                            selected: _selectedTag == null,
                            onSelected: (_) => setState(() => _selectedTag = null),
                          ),
                          ..._availableTags.map((tag) {
                            return ChoiceChip(
                              label: Text(tag),
                              selected: _selectedTag == tag,
                              onSelected: (val) => setState(() => _selectedTag = val ? tag : null),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── 5. Troubled Cards Toggle ──
                    Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile.adaptive(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: const Text('Troubled Cards Only', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Focus exclusively on questions with past mistake records', style: TextStyle(fontSize: 12)),
                        value: _troubledOnly,
                        onChanged: (val) => setState(() => _troubledOnly = val),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // ── Sticky Bottom Action Button ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      CramScreen.route(
                        moduleNumber: _selectedModule,
                        difficultyLevel: _selectedLevel,
                        mistakesOnly: _troubledOnly,
                        limit: _questionCount > 0 ? _questionCount : null,
                        tagName: _selectedTag,
                      ),
                    );
                  },
                  icon: const Icon(Icons.flash_on_rounded),
                  label: const Text('Start Cram Session'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Un-gated Self-Study / Cram Mode (Adventure Mode)
class CramScreen extends ConsumerStatefulWidget {
  const CramScreen({
    super.key,
    this.moduleNumber,
    this.difficultyLevel,
    this.mistakesOnly = false,
    this.limit,
    this.tagName,
  });

  final int? moduleNumber;
  final int? difficultyLevel;
  final bool mistakesOnly;
  final int? limit;
  final String? tagName;

  static Route<void> route({
    int? moduleNumber,
    int? difficultyLevel,
    bool mistakesOnly = false,
    int? limit,
    String? tagName,
  }) =>
      MaterialPageRoute(
        builder: (_) => CramScreen(
          moduleNumber: moduleNumber,
          difficultyLevel: difficultyLevel,
          mistakesOnly: mistakesOnly,
          limit: limit,
          tagName: tagName,
        ),
      );

  @override
  ConsumerState<CramScreen> createState() => _CramScreenState();
}

class _CramScreenState extends ConsumerState<CramScreen> {
  List<Question>? _questions;
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
    List<Question> list;

    if (widget.tagName != null) {
      list = await db.questionDao.getQuestionsByTag(widget.tagName!);
    } else if (widget.difficultyLevel != null && widget.moduleNumber == null && !widget.mistakesOnly) {
      list = await db.questionDao.getQuestionsByDifficulty(widget.difficultyLevel!);
    } else if (widget.mistakesOnly) {
      final progressList = await db.progressDao.getAllLearnedProgress(mistakesOnly: true);
      list = [];
      for (final p in progressList) {
        final q = await db.questionDao.getQuestionById(p.questionId);
        if (q != null) list.add(q);
      }
    } else {
      list = await (db.select(db.questions)).get();
    }

    // Apply Module Filter (e.g. Module 1..7 via tag prefix matching)
    if (widget.moduleNumber != null) {
      final moduleQuestions = await db.questionDao.getQuestionsByTagPrefix('Module ${widget.moduleNumber}');
      final moduleIds = moduleQuestions.map((q) => q.id).toSet();
      list = list.where((q) => moduleIds.contains(q.id)).toList();
    }

    // Apply Difficulty Level Filter if specified
    if (widget.difficultyLevel != null) {
      list = list.where((q) => q.difficultyLevel == widget.difficultyLevel).toList();
    }

    // Entropy-seeded random shuffle
    final random = Random(DateTime.now().microsecondsSinceEpoch);
    list.shuffle(random);

    // Apply question limit if specified
    if (widget.limit != null && widget.limit! > 0 && list.length > widget.limit!) {
      list = list.take(widget.limit!).toList();
    }

    setState(() {
      _questions = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    String title;
    if (widget.moduleNumber != null && widget.difficultyLevel != null) {
      title = 'Cram: Mod ${widget.moduleNumber} (L${widget.difficultyLevel})';
    } else if (widget.moduleNumber != null) {
      title = 'Cram: Module ${widget.moduleNumber}';
    } else if (widget.mistakesOnly) {
      title = 'Drill: Troubled Cards';
    } else if (widget.difficultyLevel != null) {
      title = 'Cram: Level ${widget.difficultyLevel}';
    } else {
      title = 'Self-Study';
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle_rounded),
            tooltip: 'Reshuffle',
            onPressed: () {
              setState(() {
                final random = Random(DateTime.now().microsecondsSinceEpoch);
                _questions?.shuffle(random);
                _currentIndex = 0;
                _selectedAnswer = null;
                _correctCount = 0;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _questions == null || _questions!.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: cs.primary),
                          const SizedBox(height: 16),
                          Text(
                            widget.mistakesOnly
                                ? 'No troubled cards found with mistakes.'
                                : 'No matching study cards found for this filter.',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Back to Home'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _currentIndex >= _questions!.length
                    ? _buildSummary(context)
                    : _buildQuestion(context),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final q = _questions![_currentIndex];
    final options = (jsonDecode(q.optionsJson) as List).cast<String>();
    final hasAnswered = _selectedAnswer != null;
    final isCorrect = _selectedAnswer == q.correctAnswer;
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentIndex + 1} of ${_questions!.length}',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Level ${q.difficultyLevel}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withAlpha(80)),
            ),
            child: Text(
              q.questionText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.45),
            ),
          ),
          const SizedBox(height: 16),

          // Options
          ...options.asMap().entries.map((entry) {
            final idx = entry.key;
            final opt = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: hasAnswered ? null : () => setState(() => _selectedAnswer = opt),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: !hasAnswered
                        ? (_selectedAnswer == opt
                            ? cs.primaryContainer
                            : cs.surfaceContainerHigh)
                        : (opt == q.correctAnswer
                            ? const Color(0xFF1B5E20).withAlpha(200)
                            : (_selectedAnswer == opt
                                ? const Color(0xFFB71C1C).withAlpha(180)
                                : cs.surfaceContainerHigh.withAlpha(100))),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasAnswered && opt == q.correctAnswer
                          ? const Color(0xFF4CAF50)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withAlpha(120),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          String.fromCharCode(65 + idx),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          opt,
                          style: const TextStyle(height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          if (hasAnswered) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCorrect
                    ? const Color(0xFF1B5E20).withAlpha(150)
                    : const Color(0xFFB71C1C).withAlpha(130),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCorrect ? 'Correct!' : 'Incorrect',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    q.explanation,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                if (isCorrect) _correctCount++;
                setState(() {
                  _currentIndex++;
                  _selectedAnswer = null;
                });
              },
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Next Question'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final accuracy = _questions!.isNotEmpty
        ? ((_correctCount / _questions!.length) * 100).toInt()
        : 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, size: 72, color: Color(0xFFF59E0B)),
            const SizedBox(height: 20),
            Text(
              'Cram Session Complete!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Score: $_correctCount / ${_questions!.length} ($accuracy% Accuracy)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Back to Home'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
