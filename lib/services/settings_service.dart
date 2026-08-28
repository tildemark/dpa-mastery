import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_time.dart';

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

  Future<void> resetUnlockedLevels() async {
    await _prefs.setInt(_keyHighestUnlockedLevel, 1);
    notifyListeners();
  }

  /// Resets daily quota back to the daily target.
  Future<void> resetQuota() async {
    final now = AppTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await _prefs.setString(_keyLastDate, todayStr);
    await _prefs.setInt(_keyAccumulatedLessons, dailyTarget == 0 ? 10 : dailyTarget);
    notifyListeners();
  }

  /// Adds rollover daily lesson quota when fast-forwarding time by [duration].
  Future<void> fastForwardQuota(Duration duration) async {
    final days = duration.inDays > 0 ? duration.inDays : (duration.inHours >= 24 ? duration.inHours ~/ 24 : 0);
    if (days > 0 && dailyTarget > 0) {
      final current = _prefs.getInt(_keyAccumulatedLessons) ?? 0;
      final newQuota = current + (days * dailyTarget);
      await _prefs.setInt(_keyAccumulatedLessons, newQuota);
      notifyListeners();
    }
  }

  /// Immediately refills the daily lesson quota to the configured daily target.
  Future<void> refillQuota() async {
    final now = AppTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await _prefs.setString(_keyLastDate, todayStr);
    await _prefs.setInt(_keyAccumulatedLessons, dailyTarget == 0 ? 10 : dailyTarget);
    notifyListeners();
  }

  /// Calculates available lessons for today, taking daily quota and rollover into account.
  int getAvailableLessonsToday(int totalUnlearnedCount) {
    if (totalUnlearnedCount == 0) return 0;
    if (dailyTarget == 0) return totalUnlearnedCount; // 0 = unlimited

    final now = AppTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastDateStr = _prefs.getString(_keyLastDate);

    // If never used before (first launch), allocate the full daily target
    if (lastDateStr == null) {
      final initial = dailyTarget;
      _prefs.setString(_keyLastDate, todayStr);
      _prefs.setInt(_keyAccumulatedLessons, initial);
      return initial > totalUnlearnedCount ? totalUnlearnedCount : initial;
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
      _prefs.setString(_keyLastDate, todayStr);
      _prefs.setInt(_keyAccumulatedLessons, accumulated);
    }

    return accumulated > totalUnlearnedCount ? totalUnlearnedCount : accumulated;
  }

  /// Called when a lesson batch is completed to deduct from available daily quota.
  Future<void> recordCompletedLessons(int count, int totalUnlearnedCount) async {
    final now = AppTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    int currentAccumulated = _prefs.getInt(_keyAccumulatedLessons) ?? dailyTarget;
    if (_prefs.getString(_keyLastDate) != todayStr) {
      currentAccumulated = dailyTarget;
    }
    int remaining = (currentAccumulated - count).clamp(0, 999999);

    await _prefs.setString(_keyLastDate, todayStr);
    await _prefs.setInt(_keyAccumulatedLessons, remaining);
    notifyListeners();
  }
}

final settingsServiceProvider = ChangeNotifierProvider<SettingsService>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return SettingsService(prefs);
});
