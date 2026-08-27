import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      badge: 'Upcoming Core',
      totalQuestions: 700,
      estimatedSize: '320 KB',
      version: 1,
      isAvailable: false,
      statusNote: 'Authoring in Progress (~700 items)',
      tags: ['700 Core', 'Comprehensive', 'Full Curriculum', 'All Modules'],
      author: 'DPA Mastery Curriculum Team',
    ),
    DlcPack(
      id: 'dlc_mock_exam_simulation',
      title: 'DPO Certification Mock Exam Simulation',
      description:
          'High-stakes 50-question timed practice simulation modeled after the official NPC DPO ACE / Certification Examination. Tests comprehensive scenarios across all 7 modules.',
      category: 'Exam Simulation',
      badge: 'Essential',
      totalQuestions: 50,
      estimatedSize: '35 KB',
      version: 1,
      isAvailable: false,
      statusNote: 'Simulation Pack in Preparation',
      tags: ['Mock Exam', 'DPO Certification', 'ACE Exam Simulation'],
      assetPath: 'docs/seeds/module7-l2.json',
      author: 'NPC Certification Taskforce',
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

  /// Installs a DLC pack from local asset or payload and updates SQLite via QuestionDao.
  Future<bool> installPack(DlcPack pack, {String? jsonPayload}) async {
    try {
      String data;
      if (jsonPayload != null && jsonPayload.isNotEmpty) {
        data = jsonPayload;
      } else if (pack.assetPath != null) {
        try {
          data = await rootBundle.loadString(pack.assetPath!);
        } catch (_) {
          // If asset path is a placeholder or not in assets bundle, create placeholder expansion questions
          data = _generateSyntheticPackJson(pack);
        }
      } else {
        data = _generateSyntheticPackJson(pack);
      }

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

  /// Uninstalls / deactivates a DLC pack identifier.
  Future<void> uninstallPack(String dlcId) async {
    final current = getInstalledIds();
    current.remove(dlcId);
    await _saveInstalledIds(current);
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
