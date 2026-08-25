import '../db/app_database.dart';
import '../db/daos/progress_dao.dart';

/// Service to determine the user's DPO rank, title, and overall certification readiness.
class RankService {
  RankService(this._db);

  final AppDatabase _db;

  /// Returns user rank profile based on highest unlocked difficulty and mastered items.
  Future<UserRankProfile> getUserRankProfile() async {
    final srsCounts = await _db.progressDao.getSrsStageCounts();

    // Check unlocked levels
    int highestUnlocked = 1;
    for (int l = 2; l <= 5; l++) {
      final total = await _db.progressDao.countTotalAtLevel(l - 1);
      if (total == 0) break;
      final guru = await _db.progressDao.countGuruAtLevel(l - 1);
      if (guru / total >= 0.85) {
        highestUnlocked = l;
      } else {
        break;
      }
    }

    final title = switch (highestUnlocked) {
      1 => 'Privacy Cadet',
      2 => 'Privacy Compliance Specialist',
      3 => 'Senior Privacy Officer',
      4 => 'Lead Compliance Architect',
      _ => 'Certified Master DPO',
    };

    final totalQ = srsCounts.total;
    final masteryPercentage = totalQ > 0 ? (srsCounts.masteredTotal / totalQ) * 100 : 0.0;

    return UserRankProfile(
      level: highestUnlocked,
      title: title,
      masteryPercentage: masteryPercentage,
      srsCounts: srsCounts,
    );
  }
}

class UserRankProfile {
  const UserRankProfile({
    required this.level,
    required this.title,
    required this.masteryPercentage,
    required this.srsCounts,
  });

  final int level;
  final String title;
  final double masteryPercentage;
  final SrsStageCounts srsCounts;
}
