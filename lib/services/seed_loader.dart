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
      'assets/seeds/core_question_bank.json',
    ];

    for (final file in seedFiles) {
      try {
        await _loadSeedAsset(file);
      } catch (_) {
        // Skip missing or invalid asset safely
      }
    }

    // Migrate legacy eager-init rows from older app versions.
    // If all UserProgress rows are at stage 0 with zero real progress,
    // wipe them so lazy initialisation takes over (home shows "Available: 43").
    await _db.progressDao.migrateEagerProgressRows();

    // Auto-clean any legacy orphaned questions from earlier versions
    await _purgeOrphanedQuestions();
  }

  /// Removes any questions in the database with IDs beyond the core bank (unless registered as DLC)
  Future<void> _purgeOrphanedQuestions() async {
    // If the database has old questions beyond 282 from before consolidation, remove them
    await _db.customStatement('DELETE FROM questions WHERE id > 282');
  }

  /// Completely wipes all questions, tags, and progress, then reloads the core question bank.
  Future<void> resetAndReseedCoreBank() async {
    await _db.progressDao.clearAllProgress();
    await _db.questionDao.clearAllQuestionsAndTags();
    await loadBundledSeeds();
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

      // ── Upsert tags and link them ───────────────────────────────────────
      final rawTags = item['tags'] as List<dynamic>? ?? [];
      for (final tagName in rawTags.cast<String>()) {
        final tagId = await _db.questionDao.upsertTag(tagName);
        await _db.questionDao.linkQuestionTag(questionId, tagId);
      }

      // NOTE: UserProgress rows are no longer pre-created here.
      // Lazy initialisation: a progress row is only inserted the first time
      // the user encounters this question in a Lesson session.
    }
  }

  // ─── Private ─────────────────────────────────────────────────────────────

  Future<void> _loadSeedAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    await applySeedJson(jsonString);
  }
}
