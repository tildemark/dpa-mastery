import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/gating_service.dart';
import '../../engine/rank_service.dart';
import '../../engine/readiness_service.dart';
import '../../main.dart';
import '../../services/settings_service.dart';
import '../../services/dlc/dlc_service.dart';
import '../../services/dlc/dlc_model.dart';

/// The active scope filter for the Home Dashboard.
enum DashboardScope {
  /// Core 282 DPO Exam Curriculum
  core,
  /// 700+ Expansion & DLC Packs
  dlc,
  /// Combined total library
  all,
}

/// State provider for user's active dashboard filter.
final dashboardScopeProvider = StateProvider<DashboardScope>((ref) => DashboardScope.all);

/// Dual-track progress overview comparing Core vs Expansion.
class DualTrackMetrics {
  const DualTrackMetrics({
    required this.coreTotal,
    required this.coreGuru,
    required this.dlcTotal,
    required this.dlcGuru,
    required this.hasInstalledDlc,
  });

  final int coreTotal;
  final int coreGuru;
  final int dlcTotal;
  final int dlcGuru;
  final bool hasInstalledDlc;

  double get coreRatio => coreTotal > 0 ? (coreGuru / coreTotal).clamp(0.0, 1.0) : 0.0;
  double get dlcRatio => dlcTotal > 0 ? (dlcGuru / dlcTotal).clamp(0.0, 1.0) : 0.0;
}

/// Live provider tracking individual progress for each installed DLC pack.
final installedPacksProgressProvider =
    StreamProvider.autoDispose<List<(DlcPack, DlcPackProgress)>>((ref) {
  final db = ref.watch(dbProvider);
  final dlcService = ref.watch(dlcServiceProvider);

  return db.select(db.userProgress).watch().asyncMap((_) async {
    final installed = await dlcService.getInstalledPacks();
    final results = <(DlcPack, DlcPackProgress)>[];
    for (final pack in installed) {
      final progress = await dlcService.getPackProgressStats(pack);
      results.add((pack, progress));
    }
    return results;
  });
});

/// Combined profile metrics for the top card (Rank + Exam Readiness + Dual-Track).
class HomeProfileMetrics {
  const HomeProfileMetrics({
    required this.rank,
    required this.readiness,
    required this.dualTrack,
  });

  final UserRankProfile? rank;
  final ReadinessResult readiness;
  final DualTrackMetrics dualTrack;
}

/// Live stream provider for home screen profile metrics.
/// Re-computes whenever user progress or questions change using a single efficient snapshot pass.
final homeProfileStreamProvider =
    StreamProvider.autoDispose<HomeProfileMetrics>((ref) {
  final db = ref.watch(dbProvider);
  final readinessService = ReadinessService(db);
  final dlcService = ref.watch(dlcServiceProvider);

  return db.select(db.userProgress).watch().asyncMap((allProgress) async {
    final allQuestions = await db.select(db.questions).get();
    final progressMap = {for (final p in allProgress) p.questionId: p.srsStage};

    // Calculate core (id <= 282) vs DLC (id > 282) in-memory
    int coreTotal = 0;
    int coreGuru = 0;
    int dlcTotal = 0;
    int dlcGuru = 0;

    final totalByLevel = <int, int>{for (int l = 1; l <= 5; l++) l: 0};
    final guruByLevel = <int, int>{for (int l = 1; l <= 5; l++) l: 0};
    int guruPlusTotal = 0;

    for (final q in allQuestions) {
      final stage = progressMap[q.id] ?? 0;
      final isGuru = stage >= 5;

      if (q.id <= 282) {
        coreTotal++;
        if (isGuru) coreGuru++;
      } else {
        dlcTotal++;
        if (isGuru) dlcGuru++;
      }

      final lvl = q.difficultyLevel;
      if (lvl >= 1 && lvl <= 5) {
        totalByLevel[lvl] = (totalByLevel[lvl] ?? 0) + 1;
        if (isGuru) {
          guruByLevel[lvl] = (guruByLevel[lvl] ?? 0) + 1;
          guruPlusTotal++;
        }
      }
    }

    int highestUnlocked = 1;
    for (int l = 2; l <= 5; l++) {
      final tot = totalByLevel[l - 1] ?? 0;
      if (tot == 0) break;
      final g = guruByLevel[l - 1] ?? 0;
      if (g / tot >= 0.85) {
        highestUnlocked = l;
      } else {
        break;
      }
    }

    final title = switch (highestUnlocked) {
      1 => 'Privacy Cadet',
      2 => 'Compliance Practitioner',
      3 => 'Privacy Specialist',
      4 => 'Lead Privacy Architect',
      _ => 'Certified Master DPO',
    };

    final srsCounts = await db.progressDao.getSrsStageCounts();
    final totalQ = allQuestions.length;
    final masteryPercentage = totalQ > 0 ? (guruPlusTotal / totalQ) * 100 : 0.0;

    final rank = UserRankProfile(
      level: highestUnlocked,
      title: title,
      masteryPercentage: masteryPercentage,
      srsCounts: srsCounts,
    );

    final readiness = await readinessService.computeReadiness();
    final dualTrack = DualTrackMetrics(
      coreTotal: coreTotal,
      coreGuru: coreGuru,
      dlcTotal: dlcTotal,
      dlcGuru: dlcGuru,
      hasInstalledDlc: dlcTotal > 0,
    );

    return HomeProfileMetrics(
      rank: rank,
      readiness: readiness,
      dualTrack: dualTrack,
    );
  });
});

/// Tier progression data item for levels 1 through 5.
class TierProgressionItem {
  const TierProgressionItem({
    required this.level,
    required this.isUnlocked,
    required this.guruRatio,
  });

  final int level;
  final bool isUnlocked;
  final double guruRatio;
}

/// Live stream provider for the 5 Tier Progression bars.
/// Pre-computes all ratios and lock states once per progress change.
final tierProgressionStreamProvider =
    StreamProvider.autoDispose<List<TierProgressionItem>>((ref) {
  final db = ref.watch(dbProvider);
  final settings = ref.watch(settingsServiceProvider);
  final gating = GatingService(db, settings);

  return db.select(db.userProgress).watch().asyncMap((allProgress) async {
    final allQuestions = await db.select(db.questions).get();
    final unlockedLevels = await gating.getUnlockedLevels();
    final progressMap = {for (final p in allProgress) p.questionId: p.srsStage};

    final totalByLevel = <int, int>{for (int l = 1; l <= 5; l++) l: 0};
    final guruByLevel = <int, int>{for (int l = 1; l <= 5; l++) l: 0};

    for (final q in allQuestions) {
      final lvl = q.difficultyLevel;
      if (lvl >= 1 && lvl <= 5) {
        totalByLevel[lvl] = (totalByLevel[lvl] ?? 0) + 1;
        if ((progressMap[q.id] ?? 0) >= 5) {
          guruByLevel[lvl] = (guruByLevel[lvl] ?? 0) + 1;
        }
      }
    }

    final items = <TierProgressionItem>[];
    for (var level = 1; level <= 5; level++) {
      final isUnlocked = unlockedLevels.contains(level);
      final tot = totalByLevel[level] ?? 0;
      final ratio = tot > 0 ? (guruByLevel[level] ?? 0) / tot : 0.0;
      items.add(TierProgressionItem(
        level: level,
        isUnlocked: isUnlocked,
        guruRatio: ratio,
      ));
    }

    return items;
  });
});

/// Live count of missed questions (incorrect answers not yet re-reviewed).
/// Extracted into a provider so it can be overridden in widget tests.
final missedQuestionsCountProvider =
    StreamProvider.autoDispose<int>((ref) {
  final db = ref.watch(dbProvider);
  return db.progressDao.watchMissedQuestionsCount();
});
