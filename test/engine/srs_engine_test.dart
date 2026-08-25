import 'package:flutter_test/flutter_test.dart';

import 'package:dpa_mastery/engine/srs_engine.dart';

void main() {
  group('SrsEngine — advanceStage', () {
    test('Stage 0 (Locked) → 1 (Apprentice 1)', () {
      expect(SrsEngine.advanceStage(0), 1);
    });

    test('Stage 4 (Apprentice 4) → 5 (Guru 1)', () {
      expect(SrsEngine.advanceStage(4), 5);
    });

    test('Stage 6 (Guru 2) → 7 (Master)', () {
      expect(SrsEngine.advanceStage(6), 7);
    });

    test('Stage 7 (Master) → 8 (Burned)', () {
      expect(SrsEngine.advanceStage(7), 8);
    });

    test('Stage 8 (Burned) stays at 8', () {
      expect(SrsEngine.advanceStage(8), 8);
    });
  });

  group('SrsEngine — penalizeStage', () {
    test('Apprentice 4 → Apprentice 3 (drop 1)', () {
      expect(SrsEngine.penalizeStage(4), 3);
    });

    test('Apprentice 2 → Apprentice 1 (drop 1)', () {
      expect(SrsEngine.penalizeStage(2), 1);
    });

    test('Apprentice 1 stays at Apprentice 1 (cannot drop below 1)', () {
      expect(SrsEngine.penalizeStage(1), 1);
    });

    test('Guru 1 (Stage 5) → Apprentice 1 (Stage 1)', () {
      expect(SrsEngine.penalizeStage(5), 1);
    });

    test('Guru 2 (Stage 6) → Apprentice 1 (Stage 1)', () {
      expect(SrsEngine.penalizeStage(6), 1);
    });

    test('Master (Stage 7) → Guru 1 (Stage 5)', () {
      expect(SrsEngine.penalizeStage(7), 5);
    });

    test('Burned (Stage 8) — no change', () {
      expect(SrsEngine.penalizeStage(8), 8);
    });

    test('Locked (Stage 0) — no change', () {
      expect(SrsEngine.penalizeStage(0), 0);
    });
  });

  group('SrsEngine — intervalForStage', () {
    test('Stage 1 → 4 hours', () {
      expect(SrsEngine.intervalForStage(1), const Duration(hours: 4));
    });

    test('Stage 4 → 48 hours', () {
      expect(SrsEngine.intervalForStage(4), const Duration(hours: 48));
    });

    test('Stage 5 → 7 days', () {
      expect(SrsEngine.intervalForStage(5), const Duration(days: 7));
    });

    test('Stage 7 → 30 days', () {
      expect(SrsEngine.intervalForStage(7), const Duration(days: 30));
    });

    test('Stage 8 (Burned) → null', () {
      expect(SrsEngine.intervalForStage(8), isNull);
    });

    test('Stage 0 (Locked) → null', () {
      expect(SrsEngine.intervalForStage(0), isNull);
    });
  });

  group('SrsEngine — calcNextReviewTime', () {
    test('Returns null for Stage 0', () {
      expect(SrsEngine.calcNextReviewTime(0), isNull);
    });

    test('Returns null for Stage 8', () {
      expect(SrsEngine.calcNextReviewTime(8), isNull);
    });

    test('Stage 1 next review is ~4 hours from now', () {
      final before = DateTime.now().add(const Duration(hours: 4));
      final result = SrsEngine.calcNextReviewTime(1);
      final after = DateTime.now().add(const Duration(hours: 4, seconds: 1));
      expect(result, isNotNull);
      expect(result!.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue);
      expect(result.isBefore(after), isTrue);
    });
  });

  group('SrsEngine — stageLabel', () {
    test('Labels are correct', () {
      expect(SrsEngine.stageLabel(0), 'Locked');
      expect(SrsEngine.stageLabel(1), 'Apprentice 1');
      expect(SrsEngine.stageLabel(5), 'Guru 1');
      expect(SrsEngine.stageLabel(7), 'Master');
      expect(SrsEngine.stageLabel(8), 'Burned');
    });
  });
}
