import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import '../../engine/mock_exam_service.dart';
import '../../main.dart';
import '../../services/settings_service.dart';
import '../cram/cram_screen.dart';

class MockExamScreen extends ConsumerStatefulWidget {
  const MockExamScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
        builder: (_) => const MockExamScreen(),
      );

  @override
  ConsumerState<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends ConsumerState<MockExamScreen> {
  List<Question>? _questions;
  Map<int, List<String>> _questionOptions = {};
  int _currentIndex = 0;
  final Map<int, String> _answers = {}; // questionId -> selectedOption
  final Set<int> _flaggedQuestionIds = {};
  bool _isLoading = true;
  bool _isSubmitted = false;
  MockExamResult? _result;

  // Timer: 60 minutes = 3600 seconds
  int _remainingSeconds = 3600;
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadExam();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadExam() async {
    final db = ref.read(dbProvider);
    final settings = ref.read(settingsServiceProvider);
    final service = MockExamService(db);
    final list = await service.generateMockExam(count: 50);

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

    if (mounted) {
      setState(() {
        _questions = list;
        _questionOptions = optionsMap;
        _isLoading = false;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          _elapsedSeconds++;
        } else {
          _timer?.cancel();
          _submitExam();
        }
      });
    });
  }

  Future<void> _submitExam() async {
    if (_isSubmitted || _questions == null || _questions!.isEmpty) return;
    _timer?.cancel();

    final db = ref.read(dbProvider);
    final service = MockExamService(db);
    final result = await service.evaluateExam(
      questions: _questions!,
      answers: _answers,
      durationSeconds: _elapsedSeconds,
    );

    if (mounted) {
      setState(() {
        _result = result;
        _isSubmitted = true;
      });
    }
  }

  void _confirmSubmit() {
    final answeredCount = _answers.length;
    final total = _questions?.length ?? 0;
    final unanswered = total - answeredCount;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Simulation?'),
        content: Text(
          unanswered > 0
              ? 'You have $unanswered unanswered questions out of $total. Are you sure you want to finish and submit?'
              : 'You have answered all $total questions. Ready to submit and view your DPO Certification diagnostics?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Reviewing'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _submitExam();
            },
            child: const Text('Submit Now'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSec) {
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('DPO Mock Simulation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions == null || _questions!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('DPO Mock Simulation')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 48),
                const SizedBox(height: 16),
                const Text('No questions found in question bank. Please install question packs.'),
                const SizedBox(height: 16),
                FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Back')),
              ],
            ),
          ),
        ),
      );
    }

    if (_isSubmitted && _result != null) {
      return _buildDiagnosticScreen(context, cs);
    }

    final q = _questions![_currentIndex];
    final options = _questionOptions[q.id] ?? (jsonDecode(q.optionsJson) as List).cast<String>();
    final selectedOption = _answers[q.id];
    final isFlagged = _flaggedQuestionIds.contains(q.id);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('DPO Certification Exam', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              'Time Left: ${_formatTime(_remainingSeconds)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _remainingSeconds < 300 ? cs.error : cs.primary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Question Navigator Grid',
            icon: const Icon(Icons.grid_view_rounded),
            onPressed: () => _showNavigatorSheet(context),
          ),
          IconButton(
            tooltip: 'Flag for review',
            icon: Icon(
              isFlagged ? Icons.bookmark_added_rounded : Icons.bookmark_border_rounded,
              color: isFlagged ? const Color(0xFFF59E0B) : null,
            ),
            onPressed: () {
              setState(() {
                if (isFlagged) {
                  _flaggedQuestionIds.remove(q.id);
                } else {
                  _flaggedQuestionIds.add(q.id);
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions!.length,
            backgroundColor: cs.surfaceContainerHigh,
          ),

          // Main Question View
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentIndex + 1} of ${_questions!.length}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: cs.primary),
                      ),
                      if (isFlagged)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withAlpha(40),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.flag_rounded, size: 12, color: Color(0xFFF59E0B)),
                              SizedBox(width: 4),
                              Text('Flagged', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                            ],
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
                  const SizedBox(height: 20),

                  // Options
                  ...options.map((opt) {
                    final isSelected = selectedOption == opt;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _answers[q.id] = opt;
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? cs.primaryContainer.withAlpha(160) : cs.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? cs.primary : cs.outlineVariant.withAlpha(60),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? cs.primary : cs.outline,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  opt,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(top: BorderSide(color: cs.outlineVariant.withAlpha(80))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _currentIndex > 0 ? () => setState(() => _currentIndex--) : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Prev'),
                ),
                if (_currentIndex == _questions!.length - 1)
                  FilledButton.icon(
                    onPressed: _confirmSubmit,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Finish Exam'),
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  )
                else
                  FilledButton.icon(
                    onPressed: () => setState(() => _currentIndex++),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNavigatorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final cs = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Question Navigator', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Answered ${_answers.length} of ${_questions!.length} • ${_flaggedQuestionIds.length} flagged for review',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _questions!.length,
                  itemBuilder: (context, idx) {
                    final qid = _questions![idx].id;
                    final isAns = _answers.containsKey(qid);
                    final isFlag = _flaggedQuestionIds.contains(qid);
                    final isCurrent = idx == _currentIndex;

                    Color bg = cs.surfaceContainerHigh;
                    if (isAns) bg = cs.primaryContainer;
                    if (isCurrent) bg = cs.primary;

                    return InkWell(
                      onTap: () {
                        setState(() => _currentIndex = idx);
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(8),
                          border: isFlag ? Border.all(color: const Color(0xFFF59E0B), width: 2) : null,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '${idx + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isCurrent ? cs.onPrimary : (isAns ? cs.onPrimaryContainer : cs.onSurface),
                              ),
                            ),
                            if (isFlag)
                              const Positioned(
                                top: 2,
                                right: 2,
                                child: Icon(Icons.flag_rounded, size: 10, color: Color(0xFFF59E0B)),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _confirmSubmit();
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Submit Simulation'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiagnosticScreen(BuildContext context, ColorScheme cs) {
    final res = _result!;
    final passed = res.isPassed;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Exam Diagnostic Report'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Status Banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: passed ? const Color(0xFF10B981).withAlpha(30) : cs.errorContainer.withAlpha(120),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: passed ? const Color(0xFF10B981) : cs.error, width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    passed ? Icons.verified_rounded : Icons.cancel_outlined,
                    size: 64,
                    color: passed ? const Color(0xFF10B981) : cs.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    passed ? 'CERTIFICATION SIMULATION PASSED!' : 'SIMULATION NOT YET PASSED',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: passed ? const Color(0xFF10B981) : cs.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Score: ${res.scorePercentage.toStringAsFixed(1)}% (${res.correctCount} / ${res.totalQuestions}) • Passing Threshold: 75%',
                    style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Module Breakdown Header
            Text(
              'Competency by NPC Exam Module',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Module Breakdown Cards
            ...res.moduleBreakdown.entries.map((entry) {
              final perf = entry.value;
              if (perf.total == 0) return const SizedBox.shrink();
              final isModPass = perf.scorePercentage >= 75.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isModPass ? const Color(0xFF10B981).withAlpha(40) : cs.errorContainer,
                      child: Text(
                        '${perf.moduleNumber}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isModPass ? const Color(0xFF10B981) : cs.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Module ${perf.moduleNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: perf.total > 0 ? (perf.correct / perf.total) : 0,
                            backgroundColor: cs.outlineVariant.withAlpha(80),
                            color: isModPass ? const Color(0xFF10B981) : cs.error,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '${perf.correct}/${perf.total} (${perf.scorePercentage.toInt()}%)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isModPass ? const Color(0xFF10B981) : cs.error,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Badges & Certificate of Achievement (if passed)
            if (passed) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD97706), Color(0xFFB45309)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD97706).withAlpha(60),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                res.scorePercentage >= 90.0 ? 'Honors Distinction Earned!' : 'Official Simulation Credential',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                              ),
                              Text(
                                res.scorePercentage >= 90.0
                                    ? 'Scored ≥90% — Verified High-Honor Competency'
                                    : 'Validated DPO ACE Mock Exam Competency',
                                style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () => _showCertificateDialog(context, res),
                      icon: const Icon(Icons.card_membership_rounded, color: Color(0xFF78350F)),
                      label: const Text(
                        'View DPO ACE Simulation Certificate',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF78350F)),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF3C7),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Drill Weak Modules Button
            if (res.missedQuestions.isNotEmpty) ...[
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    CramScreen.route(
                      overrideQuestions: List.from(res.missedQuestions),
                    ),
                  );
                },
                icon: const Icon(Icons.replay_rounded),
                label: Text('Drill All ${res.missedQuestions.length} Missed Exam Questions'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: cs.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
            ],

            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Back to Home Dashboard'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCertificateDialog(BuildContext context, MockExamResult res) {
    final settings = ref.read(settingsServiceProvider);
    final isHonors = res.scorePercentage >= 90.0;
    final dateStr = DateTime.now().toLocal().toString().split(' ')[0];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF59E0B), width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_rounded, color: Color(0xFFF59E0B), size: 48),
              const SizedBox(height: 8),
              const Text(
                'CERTIFICATE OF MASTERY',
                style: TextStyle(
                  color: Color(0xFFF59E0B),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 2.0,
                ),
              ),
              const Text(
                'DPO ACE CERTIFICATION SIMULATION',
                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
              const Divider(color: Color(0xFFF59E0B), height: 24, thickness: 1),
              const Text(
                'This is to certify that',
                style: TextStyle(color: Colors.white60, fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 6),
              Text(
                settings.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'has successfully passed the comprehensive 50-question simulation with a verified score of ${res.scorePercentage.toStringAsFixed(1)}% (${res.correctCount}/${res.totalQuestions})${isHonors ? " • WITH HONORS DISTINCTION" : ""}.',
                style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date: $dateStr', style: const TextStyle(fontSize: 11, color: Colors.white60)),
                    Text(
                      'ID: ACE-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Educational Simulation Record • Philippine Data Privacy Act (RA 10173) Framework\n*Diagnostic training credential only. Not an official government license issued by the NPC.',
                style: TextStyle(fontSize: 9, color: Colors.white38, height: 1.3),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Close Certificate', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
