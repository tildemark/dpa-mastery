import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart' show rootBundle;

import '../db/app_database.dart';

/// Loads bundled seed JSON assets into the local Drift database.
///
/// Only Module 1 is bundled in the APK (assets/seeds/module1.json).
/// Modules 2–7 are fetched OTA via [OtaSyncService].
///
/// This is safe to call on every cold launch — it uses upsert, so existing
/// [UserProgress] records are never overwritten.
class SeedLoader {
  SeedLoader(this._db);

  final AppDatabase _db;

  /// Loads all bundled seed assets and upserts them into Drift.
  /// Safe to call on every launch (uses non-destructive upsert).
  Future<void> loadBundledSeeds() async {
    const seedFiles = [
      'assets/seeds/module1.json',
      'assets/seeds/module2.json',
      'assets/seeds/module3.json',
      'assets/seeds/module4.json',
      'assets/seeds/module5.json',
      'assets/seeds/module6.json',
      'assets/seeds/module7.json',
      'assets/seeds/update_v5_practice_quiz.json',
      'assets/seeds/update_v6_practice_quiz.json',
      'assets/seeds/update_v7_practice_quiz.json',
      'assets/seeds/update_v9_expanded_batch.json',
    ];

    for (final file in seedFiles) {
      try {
        await _loadSeedAsset(file);
      } catch (_) {
        // Skip missing or invalid asset safely
      }
    }
  }

  /// Parses a seed JSON string and upserts all questions, tags, and
  /// QuestionTag links. Never touches [UserProgress].
  Future<void> applySeedJson(String jsonString) async {
    final Map<String, dynamic> payload = jsonDecode(jsonString);
    final items = payload['items'] as List<dynamic>;

    for (final item in items) {
      final questionId = item['id'] as int;

      // ── Upsert question row ─────────────────────────────────────────────
      await _db.questionDao.upsertQuestions([
        QuestionsCompanion.insert(
          id: Value(questionId),
          difficultyLevel: Value(item['difficulty_level'] as int? ?? 1),
          questionText: item['question_text'] as String,
          lessonConcept: item['lesson_concept'] as String,
          explanation: item['explanation'] as String,
          optionsJson: jsonEncode(item['options']),
          correctAnswer: item['correct_answer'] as String,
        ),
      ]);

      // ── Upsert tags and link them ────────────────────────────────────────
      final rawTags = item['tags'] as List<dynamic>? ?? [];
      for (final tagName in rawTags.cast<String>()) {
        final tagId = await _db.questionDao.upsertTag(tagName);
        await _db.questionDao.linkQuestionTag(questionId, tagId);
      }

      // ── Initialise UserProgress at Stage 0 if not already present ────────
      await _db.progressDao.initProgressIfAbsent(questionId);
    }
  }

  // ─── Private ─────────────────────────────────────────────────────────────

  Future<void> _loadSeedAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    await applySeedJson(jsonString);
  }
}
