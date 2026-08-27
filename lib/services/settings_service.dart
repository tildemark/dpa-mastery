import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for SharedPreferences instance.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPrefsProvider in main()');
});

/// Manages user settings: Daily Lesson Pace target and rollover accumulation.
class SettingsService extends ChangeNotifier {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const _keyDailyTarget = 'setting_daily_lesson_target'; // 5, 10, 15, 20, 25, 0 (unlimited)
  static const _keyAccumulatedLessons = 'setting_accumulated_lessons';
  static const _keyLastDate = 'setting_last_lesson_date';
  static const _keyShuffleOptions = 'setting_shuffle_options';
  static const _keyUserName = 'setting_user_name';
  static const _keyOnboarded = 'setting_has_onboarded';
  static const _keyApprenticeCap = 'setting_apprentice_cap'; // 50, 75, 100, 0 (disabled)
  static const _keyHighestUnlockedLevel = 'setting_highest_unlocked_level'; // High-water mark

  int get dailyTarget => _prefs.getInt(_keyDailyTarget) ?? 10;
  bool get shuffleOptions => _prefs.getBool(_keyShuffleOptions) ?? true;
  String get userName => _prefs.getString(_keyUserName) ?? 'Guest';
  bool get hasCompletedOnboarding => _prefs.getBool(_keyOnboarded) ?? false;
  int get apprenticeCap => _prefs.getInt(_keyApprenticeCap) ?? 50;
  int get highestUnlockedLevel => _prefs.getInt(_keyHighestUnlockedLevel) ?? 1;

  Future<void> setHighestUnlockedLevel(int level) async {
    final current = highestUnlockedLevel;
    if (level > current) {
      await _prefs.setInt(_keyHighestUnlockedLevel, level);
      notifyListeners();
    }
  }

  Future<void> setApprenticeCap(int cap) async {
    await _prefs.setInt(_keyApprenticeCap, cap);
    notifyListeners();
  }

  Future<void> setDailyTarget(int target) async {
    await _prefs.setInt(_keyDailyTarget, target);
    notifyListeners();
  }

  Future<void> setShuffleOptions(bool value) async {
    await _prefs.setBool(_keyShuffleOptions, value);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    await _prefs.setString(_keyUserName, name.trim().isEmpty ? 'Guest' : name.trim());
    notifyListeners();
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_keyOnboarded, completed);
    notifyListeners();
  }

  /// Resets daily quota back to the daily target.
  Future<void> resetQuota() async {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await _prefs.setString(_keyLastDate, todayStr);
    await _prefs.setInt(_keyAccumulatedLessons, dailyTarget);
    notifyListeners();
  }

  /// Calculates available lessons for today, taking daily quota and rollover into account.
  int getAvailableLessonsToday(int totalUnlearnedCount) {
    if (totalUnlearnedCount == 0) return 0;
    if (dailyTarget == 0) return totalUnlearnedCount; // 0 = unlimited

    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastDateStr = _prefs.getString(_keyLastDate);

    // If never used before (first launch), allocate the full daily target
    if (lastDateStr == null) {
      return dailyTarget > totalUnlearnedCount ? totalUnlearnedCount : dailyTarget;
    }

    int accumulated = _prefs.getInt(_keyAccumulatedLessons) ?? dailyTarget;

    // If date changed, calculate rollover
    if (lastDateStr != todayStr) {
      final lastDate = DateTime.tryParse(lastDateStr);
      if (lastDate != null) {
        final daysPassed = DateTime(now.year, now.month, now.day)
            .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
            .inDays;
        if (daysPassed > 0) {
          // Accumulate quota for each missed day
          accumulated += daysPassed * dailyTarget;
        }
      } else {
        accumulated = dailyTarget;
      }
    }

    if (accumulated > totalUnlearnedCount) {
      accumulated = totalUnlearnedCount;
    }

    return accumulated;
  }

  /// Called when a lesson batch is completed to deduct from available daily quota.
  Future<void> recordCompletedLessons(int count, int totalUnlearnedCount) async {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    int currentAvailable = getAvailableLessonsToday(totalUnlearnedCount);
    int remaining = (currentAvailable - count).clamp(0, totalUnlearnedCount);

    await _prefs.setString(_keyLastDate, todayStr);
    await _prefs.setInt(_keyAccumulatedLessons, remaining);
    notifyListeners();
  }
}

final settingsServiceProvider = ChangeNotifierProvider<SettingsService>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return SettingsService(prefs);
});
