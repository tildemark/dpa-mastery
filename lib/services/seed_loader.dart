import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../db/app_database.dart';
import 'dlc/dlc_service.dart';

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
  Future<void> loadBundledSeeds({SharedPreferences? prefs}) async {
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

    // Ensure any DLC questions whose pack is not installed in SharedPreferences are purged
    if (prefs != null) {
      final dlcService = DlcService(_db, prefs);
      await dlcService.purgeUninstalledDlcQuestions();
    }

    // Migrate legacy eager-init rows from older app versions.
    // If all UserProgress rows are at stage 0 with zero real progress,
    // wipe them so lazy initialisation takes over (home shows "Available: 43").
    await _db.progressDao.migrateEagerProgressRows();
  }

  /// Completely wipes all questions, tags, and progress, then reloads the core question bank.
  Future<void> resetAndReseedCoreBank({SharedPreferences? prefs}) async {
    await _db.progressDao.clearAllProgress();
    await _db.questionDao.clearAllQuestionsAndTags();
    await loadBundledSeeds(prefs: prefs);
  }

  /// Parses a seed JSON string and upserts all questions, tags, and
  /// QuestionTag links in a single database transaction. Never touches [UserProgress].
  Future<void> applySeedJson(String jsonString) async {
    final Map<String, dynamic> payload = jsonDecode(jsonString);
    final items = payload['items'] as List<dynamic>;

    final questionCompanions = <QuestionsCompanion>[];
    final tagsToLink = <int, List<String>>{};

    for (final item in items) {
      final questionId = item['id'] as int;
      questionCompanions.add(
        QuestionsCompanion.insert(
          id: Value(questionId),
          difficultyLevel: Value(item['difficulty_level'] as int? ?? 1),
          questionText: item['question_text'] as String,
          lessonConcept: item['lesson_concept'] as String,
          explanation: item['explanation'] as String,
          optionsJson: jsonEncode(item['options']),
          correctAnswer: item['correct_answer'] as String,
        ),
      );

      final rawTags = item['tags'] as List<dynamic>? ?? [];
      if (rawTags.isNotEmpty) {
        tagsToLink[questionId] = rawTags.cast<String>();
      }
    }

    // Execute bulk upserts in a single transaction
    await _db.transaction(() async {
      if (questionCompanions.isNotEmpty) {
        await _db.questionDao.upsertQuestions(questionCompanions);
      }

      for (final entry in tagsToLink.entries) {
        for (final tagName in entry.value) {
          final tagId = await _db.questionDao.upsertTag(tagName);
          await _db.questionDao.linkQuestionTag(entry.key, tagId);
        }
      }
    });
  }

  // ─── Private ─────────────────────────────────────────────────────────────

  Future<void> _loadSeedAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    await applySeedJson(jsonString);
  }
}
