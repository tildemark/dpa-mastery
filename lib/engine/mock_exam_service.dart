import 'dart:math';
import '../db/app_database.dart';

/// Diagnostic summary of a completed DPO Certification Mock Exam.
class MockExamResult {
  const MockExamResult({
    required this.totalQuestions,
    required this.correctCount,
    required this.scorePercentage,
    required this.isPassed,
    required this.durationSeconds,
    required this.moduleBreakdown,
    required this.weakestModules,
    required this.missedQuestions,
  });

  final int totalQuestions;
  final int correctCount;
  final double scorePercentage;
  final bool isPassed; // >= 75%
  final int durationSeconds;
  final Map<int, ModulePerformance> moduleBreakdown;
  final List<int> weakestModules;
  final List<Question> missedQuestions;
}

class ModulePerformance {
  const ModulePerformance({
    required this.moduleNumber,
    required this.total,
    required this.correct,
  });

  final int moduleNumber;
  final int total;
  final int correct;

  double get scorePercentage => total > 0 ? (correct / total) * 100 : 0.0;
}

/// Service to generate balanced mock exams and compute diagnostics.
class MockExamService {
  MockExamService(this._db);

  final AppDatabase _db;

  static const int standardExamQuestionCount = 50;
  static const double passingThresholdPercentage = 75.0;

  /// Generates a randomized, balanced 50-question mock exam pool.
  /// Prioritizes questions from the DPO ACE Exam DLC pool (150 questions) if available.
  Future<List<Question>> generateMockExam({int count = standardExamQuestionCount}) async {
    final allQuestions = await _db.select(_db.questions).get();
    if (allQuestions.isEmpty) return [];

    final tagLinks = await _db.select(_db.questionTags).get();
    final allTags = await _db.select(_db.tags).get();
    final tagMap = {for (final t in allTags) t.id: t.name};

    // Filter to DPO ACE questions if installed (id >= 1001 or tagged 'DPO ACE Exam')
    final aceQuestions = allQuestions.where((q) {
      if (q.id >= 1001 && q.id <= 1200) return true;
      final qTagIds = tagLinks.where((tl) => tl.questionId == q.id).map((tl) => tl.tagId).toSet();
      return qTagIds.any((tid) => tagMap[tid]?.contains('DPO ACE') == true);
    }).toList();

    final sourcePool = aceQuestions.length >= count ? aceQuestions : allQuestions;

    // Group questions by Module 1..7
    final moduleBuckets = <int, List<Question>>{for (int m = 1; m <= 7; m++) m: []};
    final uncategorized = <Question>[];

    for (final q in sourcePool) {
      final qTagIds = tagLinks.where((tl) => tl.questionId == q.id).map((tl) => tl.tagId).toSet();
      int? foundModule;
      for (final tid in qTagIds) {
        final tagName = tagMap[tid] ?? '';
        for (int m = 1; m <= 7; m++) {
          if (tagName.startsWith('Module $m')) {
            foundModule = m;
            break;
          }
        }
        if (foundModule != null) break;
      }

      if (foundModule != null) {
        moduleBuckets[foundModule]!.add(q);
      } else {
        uncategorized.add(q);
      }
    }

    final random = Random(DateTime.now().microsecondsSinceEpoch);
    final examPool = <Question>[];
    final targetPerModule = (count / 7).floor(); // 7 per module = 49

    // Sample 7 from each module
    for (int m = 1; m <= 7; m++) {
      final list = List<Question>.from(moduleBuckets[m]!)..shuffle(random);
      final takeCount = min(list.length, targetPerModule);
      examPool.addAll(list.take(takeCount));
    }

    // Fill the 50th question (and any gaps) from remaining pool
    if (examPool.length < count) {
      final remaining = sourcePool.where((q) => !examPool.contains(q)).toList()..shuffle(random);
      final needed = count - examPool.length;
      examPool.addAll(remaining.take(needed));
    }

    examPool.shuffle(random);
    return examPool.take(count).toList();
  }

  /// Evaluates submitted answers and generates diagnostic breakdown.
  Future<MockExamResult> evaluateExam({
    required List<Question> questions,
    required Map<int, String> answers, // questionId -> selectedOption
    required int durationSeconds,
  }) async {
    final tagLinks = await _db.select(_db.questionTags).get();
    final allTags = await _db.select(_db.tags).get();
    final tagMap = {for (final t in allTags) t.id: t.name};

    int correct = 0;
    final missed = <Question>[];
    final modTotals = <int, int>{};
    final modCorrect = <int, int>{};

    for (final q in questions) {
      final selected = answers[q.id];
      final isRight = selected == q.correctAnswer;

      if (isRight) {
        correct++;
      } else {
        missed.add(q);
      }

      // Determine module
      final qTagIds = tagLinks.where((tl) => tl.questionId == q.id).map((tl) => tl.tagId).toSet();
      int? foundModule;
      for (final tid in qTagIds) {
        final tagName = tagMap[tid] ?? '';
        for (int m = 1; m <= 7; m++) {
          if (tagName.startsWith('Module $m')) {
            foundModule = m;
            break;
          }
        }
        if (foundModule != null) break;
      }

      final modIndex = foundModule ?? 1;
      modTotals[modIndex] = (modTotals[modIndex] ?? 0) + 1;
      if (isRight) {
        modCorrect[modIndex] = (modCorrect[modIndex] ?? 0) + 1;
      }
    }

    final breakdown = <int, ModulePerformance>{};
    for (int m = 1; m <= 7; m++) {
      breakdown[m] = ModulePerformance(
        moduleNumber: m,
        total: modTotals[m] ?? 0,
        correct: modCorrect[m] ?? 0,
      );
    }

    final weak = breakdown.entries
        .where((e) => e.value.total > 0 && e.value.scorePercentage < passingThresholdPercentage)
        .map((e) => e.key)
        .toList();

    final scorePct = questions.isNotEmpty ? (correct / questions.length) * 100 : 0.0;
    final isPassed = scorePct >= passingThresholdPercentage;

    return MockExamResult(
      totalQuestions: questions.length,
      correctCount: correct,
      scorePercentage: scorePct,
      isPassed: isPassed,
      durationSeconds: durationSeconds,
      moduleBreakdown: breakdown,
      weakestModules: weak,
      missedQuestions: missed,
    );
  }
}
