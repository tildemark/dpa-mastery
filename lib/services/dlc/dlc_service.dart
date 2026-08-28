import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart';

import '../../db/app_database.dart';
import '../../main.dart';
import '../../services/settings_service.dart';
import 'dlc_model.dart';

final dlcServiceProvider = Provider<DlcService>((ref) {
  final db = ref.watch(dbProvider);
  final prefs = ref.watch(sharedPrefsProvider);
  return DlcService(db, prefs);
});

final installedDlcListProvider = FutureProvider<List<DlcPack>>((ref) async {
  final dlcService = ref.watch(dlcServiceProvider);
  return dlcService.getInstalledPacks();
});

final availableDlcListProvider = FutureProvider<List<DlcPack>>((ref) async {
  final dlcService = ref.watch(dlcServiceProvider);
  return dlcService.getAvailablePacks();
});

/// Service responsible for managing DLC expansion packs.
class DlcService {
  DlcService(this._db, this._prefs);

  final AppDatabase _db;
  final SharedPreferences _prefs;

  static const _keyInstalledDlcIds = 'installed_dlc_pack_ids';

  /// Official built-in DLC catalog definitions.
  static const List<DlcPack> _defaultCatalog = [
    DlcPack(
      id: 'dlc_core_expansion_700',
      title: 'DPA Mastery 700+ Core Curriculum Expansion',
      description:
          'Massive curriculum expansion adding ~700 deep-dive scenario questions across all 7 Modules (Framework, Concepts, Principles, Lawful Criteria, Subject Rights, Penalties, and Breach Management).',
      category: 'Core Curriculum',
      badge: 'Core Expansion',
      totalQuestions: 700,
      estimatedSize: '990 KB',
      version: 1,
      isAvailable: true,
      statusNote: 'Ready to Install',
      tags: ['700 Core', 'Comprehensive', 'Full Curriculum', 'All Modules'],
      assetPath: 'assets/seeds/dlc_700_core_expansion.json',
      remoteUrl: 'https://dpa-mastery.sanchez.ph/seeds/dlc_700_core_expansion.json',
      author: 'DPA Mastery Curriculum Team',
    ),
    DlcPack(
      id: 'dlc_mock_exam_simulation',
      title: 'DPO ACE Certification Mock Exam Suite',
      description:
          'Comprehensive 150-scenario high-difficulty exam pool modeled after the official NPC DPO ACE Exam. Generates balanced 50-question randomized mock exams with full competency diagnostics and digital certification.',
      category: 'Exam Simulation',
      badge: 'ACE Certification',
      totalQuestions: 150,
      estimatedSize: '190 KB',
      version: 1,
      isAvailable: true,
      statusNote: 'Ready to Install',
      tags: ['DPO ACE', '150 Scenarios', 'Mock Exam', 'DPO Certification', 'ACE Exam Simulation'],
      assetPath: 'assets/seeds/dlc_dpo_ace_mock_exam.json',
      remoteUrl: 'https://dpa-mastery.sanchez.ph/seeds/dlc_dpo_ace_mock_exam.json',
      author: 'NPC Certification Taskforce & Advisory Board',
    ),
    DlcPack(
      id: 'dlc_irr_circulars_deepdive',
      title: 'NPC IRR & Landmark Circulars Deep Dive',
      description:
          'Specialized question pack testing the 2016 IRR rules, NPC Circular 16-01 (Security), Circular 16-03 (Breach Management), Circular 2020-01 (Data Sharing), and Circular 2022-01 (Administrative Fines).',
      category: 'Regulatory Rules',
      badge: 'Advanced',
      totalQuestions: 120,
      estimatedSize: '65 KB',
      version: 1,
      isAvailable: false,
      statusNote: 'Coming Soon / In Review',
      tags: ['IRR 2016', 'NPC Circulars', 'Advisory Opinions'],
      author: 'DPA Advisory Board',
    ),
    DlcPack(
      id: 'dlc_industry_scenarios',
      title: 'Industry Scenarios: Healthcare, Fintech & BPO',
      description:
          'Real-world case studies covering Telemedicine, Hospital record retention, BSP/AMLA vs DPA compliance for e-wallets, and BPO cross-border data transfer exemptions under Section 4(g).',
      category: 'Industry Case Studies',
      badge: 'Specialized',
      totalQuestions: 80,
      estimatedSize: '48 KB',
      version: 1,
      isAvailable: false,
      statusNote: 'Coming Soon / In Preparation',
      tags: ['Healthcare', 'Fintech', 'BPO', 'Cross-Border'],
      author: 'Philippine Privacy Association',
    ),
  ];

  Set<String> getInstalledIds() {
    final list = _prefs.getStringList(_keyInstalledDlcIds) ?? [];
    return list.toSet();
  }

  Future<void> _saveInstalledIds(Set<String> ids) async {
    await _prefs.setStringList(_keyInstalledDlcIds, ids.toList());
  }

  /// Ensures that any DLC questions in SQLite whose pack is NOT marked as installed
  /// in [SharedPreferences] are purged from the database.
  Future<void> purgeUninstalledDlcQuestions() async {
    final installed = getInstalledIds();

    for (final pack in _defaultCatalog) {
      if (!installed.contains(pack.id)) {
        final dlcTag = 'DLC: ${pack.title}';
        final taggedQuestions = await _db.questionDao.getQuestionsByTag(dlcTag);
        final ids = taggedQuestions.map((q) => q.id).toSet();

        if (pack.id == 'dlc_core_expansion_700') {
          final extra = await (_db.select(_db.questions)
                ..where((q) => q.id.isBiggerOrEqualValue(283)))
              .get();
          ids.addAll(extra.map((q) => q.id));
        }

        if (ids.isNotEmpty) {
          final idList = ids.toList();
          await (_db.delete(_db.userProgress)..where((p) => p.questionId.isIn(idList))).go();
          await (_db.delete(_db.questionTags)..where((qt) => qt.questionId.isIn(idList))).go();
          await (_db.delete(_db.questions)..where((q) => q.id.isIn(idList))).go();
        }
      }
    }
  }

  /// Checks if a specific DLC is installed.
  bool isDlcInstalled(String dlcId) {
    return getInstalledIds().contains(dlcId);
  }

  /// Retrieves the list of all available DLC packs with their installation status.
  Future<List<DlcPack>> getAvailablePacks() async {
    final installed = getInstalledIds();
    return _defaultCatalog.map((pack) {
      return pack.copyWith(isInstalled: installed.contains(pack.id));
    }).toList();
  }

  /// Retrieves only the installed DLC packs.
  Future<List<DlcPack>> getInstalledPacks() async {
    final installed = getInstalledIds();
    return _defaultCatalog
        .where((pack) => installed.contains(pack.id))
        .map((pack) => pack.copyWith(isInstalled: true))
        .toList();
  }

  /// Installs a DLC pack from local asset, OTA remote URL, or payload and updates SQLite.
  Future<bool> installPack(DlcPack pack, {String? jsonPayload}) async {
    try {
      String? data;
      if (jsonPayload != null && jsonPayload.isNotEmpty) {
        data = jsonPayload;
      } else if (pack.assetPath != null) {
        try {
          data = await rootBundle.loadString(pack.assetPath!);
        } catch (_) {
          // If not in bundled assets, fallback to remoteUrl if provided
          if (pack.remoteUrl != null) {
            final res = await http.get(Uri.parse(pack.remoteUrl!));
            if (res.statusCode == 200) {
              data = utf8.decode(res.bodyBytes);
            }
          }
        }
      } else if (pack.remoteUrl != null) {
        final res = await http.get(Uri.parse(pack.remoteUrl!));
        if (res.statusCode == 200) {
          data = utf8.decode(res.bodyBytes);
        }
      }

      data ??= _generateSyntheticPackJson(pack);

      final parsed = jsonDecode(data) as Map<String, dynamic>;
      final items = (parsed['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      if (items.isNotEmpty) {
        final companions = <QuestionsCompanion>[];
        final questionTagLinks = <int, List<String>>{};

        for (final item in items) {
          final id = item['id'] as int;
          final diff = item['difficulty_level'] as int? ?? 2;
          final lessonConcept = item['lesson_concept'] as String? ?? '';
          final qText = item['question_text'] as String;
          final options = (item['options'] as List).cast<String>();
          final correct = item['correct_answer'] as String;
          final explanation = item['explanation'] as String? ?? '';
          final rawTags = (item['tags'] as List?)?.cast<String>() ?? [];

          // Add the DLC pack ID / Tag to the question's tags for easy filtering
          final dlcTag = 'DLC: ${pack.title}';
          final combinedTags = {...rawTags, dlcTag}.toList();

          companions.add(
            QuestionsCompanion.insert(
              id: Value(id),
              difficultyLevel: Value(diff),
              lessonConcept: lessonConcept,
              questionText: qText,
              optionsJson: jsonEncode(options),
              correctAnswer: correct,
              explanation: explanation,
            ),
          );

          questionTagLinks[id] = combinedTags;
        }

        // Upsert questions safely without wiping UserProgress
        await _db.questionDao.upsertQuestions(companions);

        // Upsert tags & link
        for (final entry in questionTagLinks.entries) {
          for (final tagName in entry.value) {
            final tagId = await _db.questionDao.upsertTag(tagName);
            await _db.questionDao.linkQuestionTag(entry.key, tagId);
          }
        }
      }

      // Mark pack as installed
      final currentInstalled = getInstalledIds();
      currentInstalled.add(pack.id);
      await _saveInstalledIds(currentInstalled);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Calculates the live learning progress statistics for a given DLC pack.
  Future<DlcPackProgress> getPackProgressStats(DlcPack pack) async {
    final dlcTag = 'DLC: ${pack.title}';
    final taggedQuestions = await _db.questionDao.getQuestionsByTag(dlcTag);
    final questionIds = taggedQuestions.map((q) => q.id).toSet();

    if (pack.id == 'dlc_core_expansion_700') {
      final extra = await (_db.select(_db.questions)
            ..where((q) => q.id.isBiggerOrEqualValue(283)))
          .get();
      questionIds.addAll(extra.map((q) => q.id));
    }

    if (questionIds.isEmpty) {
      return DlcPackProgress(
        total: pack.totalQuestions,
        unlearned: pack.totalQuestions,
        apprentice: 0,
        guruPlus: 0,
      );
    }

    final idList = questionIds.toList();
    final progressRows = await (_db.select(_db.userProgress)
          ..where((p) => p.questionId.isIn(idList)))
        .get();

    final progressMap = {for (final p in progressRows) p.questionId: p.srsStage};
    int apprentice = 0;
    int guruPlus = 0;
    int unlearned = 0;

    for (final qId in questionIds) {
      final stage = progressMap[qId] ?? 0;
      if (stage == 0) {
        unlearned++;
      } else if (stage >= 1 && stage <= 4) {
        apprentice++;
      } else if (stage >= 5) {
        guruPlus++;
      }
    }

    return DlcPackProgress(
      total: questionIds.length,
      unlearned: unlearned,
      apprentice: apprentice,
      guruPlus: guruPlus,
    );
  }

  /// Uninstalls / deactivates a DLC pack identifier and removes its questions from the database.
  Future<void> uninstallPack(String dlcId) async {
    final current = getInstalledIds();
    current.remove(dlcId);
    await _saveInstalledIds(current);

    // Find pack definition to identify tag
    final pack = _defaultCatalog.firstWhere(
      (p) => p.id == dlcId,
      orElse: () => DlcPack(
        id: dlcId,
        title: dlcId,
        description: '',
        category: '',
        badge: '',
        totalQuestions: 0,
        estimatedSize: '',
        version: 1,
        tags: const [],
      ),
    );

    final dlcTag = 'DLC: ${pack.title}';
    final taggedQuestions = await _db.questionDao.getQuestionsByTag(dlcTag);
    final ids = taggedQuestions.map((q) => q.id).toSet();

    if (dlcId == 'dlc_core_expansion_700') {
      final extra = await (_db.select(_db.questions)
            ..where((q) => q.id.isBiggerOrEqualValue(283)))
          .get();
      ids.addAll(extra.map((q) => q.id));
    }

    if (ids.isNotEmpty) {
      final idList = ids.toList();
      await (_db.delete(_db.userProgress)..where((p) => p.questionId.isIn(idList))).go();
      await (_db.delete(_db.questionTags)..where((qt) => qt.questionId.isIn(idList))).go();
      await (_db.delete(_db.questions)..where((q) => q.id.isIn(idList))).go();
    }
  }

  /// Helper to generate sample items if an offline asset file is not yet bundled.
  String _generateSyntheticPackJson(DlcPack pack) {
    final list = <Map<String, dynamic>>[];
    final baseId = pack.id.hashCode.abs() % 10000 + 1000;

    for (int i = 1; i <= pack.totalQuestions; i++) {
      list.add({
        'id': baseId + i,
        'difficulty_level': (i % 3) + 2,
        'tags': [...pack.tags, 'Module ${(i % 7) + 1}'],
        'lesson_concept': 'Advanced principle governing ${pack.title} in accordance with Philippine privacy jurisprudence.',
        'question_text': '[${pack.badge}] Practice Simulation Question #$i: Under ${pack.title}, which compliance measure is strictly mandated?',
        'options': [
          'Option A: Implement mandatory technical and organizational safeguards',
          'Option B: Waive all requirements if under 10 employees',
          'Option C: Unilateral processing without documentation',
          'Option D: Publicly post all breach logs online'
        ],
        'correct_answer': 'Option A: Implement mandatory technical and organizational safeguards',
        'explanation': 'Compliance standards under ${pack.title} require strict implementation of organizational and technical measures.'
      });
    }

    return jsonEncode({
      'version': pack.version,
      'module': pack.title,
      'items': list,
    });
  }
}
