import '../db/app_database.dart';

/// Controls difficulty-tier progression gating.
///
/// A user cannot access [difficultyLevel] X+1 until at least 85% of their
/// [difficultyLevel] X questions have reached Guru status (srsStage >= 5).
class GatingService {
  GatingService(this._db);

  final AppDatabase _db;

  static const double _guruThreshold = 0.85;

  /// Returns true if [targetLevel] is unlocked for the user.
  ///
  /// Level 1 is always unlocked (starting point).
  /// Level X+1 requires >= 85% of Level X questions at Guru (stage 5+).
  Future<bool> isLevelUnlocked(int targetLevel) async {
    if (targetLevel <= 1) return true;

    final prerequisiteLevel = targetLevel - 1;
    final total =
        await _db.progressDao.countTotalAtLevel(prerequisiteLevel);

    // If no questions exist for the prerequisite level, we can't gate.
    if (total == 0) return false;

    final guruCount =
        await _db.progressDao.countGuruAtLevel(prerequisiteLevel);

    final ratio = guruCount / total;
    return ratio >= _guruThreshold;
  }

  /// Returns the Guru completion ratio (0.0 – 1.0) for [level].
  /// Useful for progress ring UI.
  Future<double> guruRatioForLevel(int level) async {
    final total = await _db.progressDao.countTotalAtLevel(level);
    if (total == 0) return 0.0;
    final guru = await _db.progressDao.countGuruAtLevel(level);
    return guru / total;
  }

  /// Returns all unlocked difficulty levels as a list.
  /// Stops as soon as a gated level is reached.
  Future<List<int>> getUnlockedLevels({int maxLevel = 5}) async {
    final unlocked = <int>[];
    for (var level = 1; level <= maxLevel; level++) {
      if (await isLevelUnlocked(level)) {
        unlocked.add(level);
      } else {
        break; // Levels are sequential — no skipping.
      }
    }
    return unlocked;
  }
}
