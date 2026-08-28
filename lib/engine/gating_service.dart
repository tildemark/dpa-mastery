import '../db/app_database.dart';
import '../services/settings_service.dart';

/// Controls difficulty-tier progression gating.
///
/// Implements:
/// - Option A: High-water mark (Once a level is unlocked, it remains unlocked forever)
/// - Option C: Absolute Guru milestone threshold (Or >= 85% completion of core items)
class GatingService {
  GatingService(this._db, [this._settings]);

  final AppDatabase _db;
  final SettingsService? _settings;

  static const double _guruThreshold = 0.85;

  /// Absolute Guru milestone counts needed to unlock levels:
  /// Level 2: 35 Gurus
  /// Level 3: 75 Gurus
  /// Level 4: 150 Gurus
  /// Level 5: 250 Gurus
  static const Map<int, int> _absoluteGuruMilestones = {
    2: 35,
    3: 75,
    4: 150,
    5: 250,
  };

  /// Returns true if [targetLevel] is unlocked for the user.
  Future<bool> isLevelUnlocked(int targetLevel) async {
    if (targetLevel <= 1) return true;

    // High-water mark check: If already unlocked in settings, never re-lock
    final settings = _settings;
    if (settings != null && settings.highestUnlockedLevel >= targetLevel) {
      return true;
    }

    // Absolute Guru check across all mastered items
    final totalGurus = await _db.progressDao.getSrsStageCounts();
    final requiredGurus = _absoluteGuruMilestones[targetLevel] ?? 35;
    if (totalGurus.masteredTotal >= requiredGurus) {
      await _settings?.setHighestUnlockedLevel(targetLevel);
      return true;
    }

    // Fallback: Check prerequisite level ratio
    final prerequisiteLevel = targetLevel - 1;
    final total = await _db.progressDao.countTotalAtLevel(prerequisiteLevel);
    if (total == 0) return false;

    final guruCount = await _db.progressDao.countGuruAtLevel(prerequisiteLevel);
    final ratio = guruCount / total;
    if (ratio >= _guruThreshold) {
      await _settings?.setHighestUnlockedLevel(targetLevel);
      return true;
    }

    return false;
  }

  /// Returns the Guru completion ratio (0.0 – 1.0) for [level].
  Future<double> guruRatioForLevel(int level) async {
    final total = await _db.progressDao.countTotalAtLevel(level);
    if (total == 0) return 0.0;
    final guru = await _db.progressDao.countGuruAtLevel(level);
    return guru / total;
  }

  /// Returns all unlocked difficulty levels as a list.
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

