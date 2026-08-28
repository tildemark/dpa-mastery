import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central time provider for DPA Mastery.
///
/// In standard production use, [AppTime.now()] returns the actual system [DateTime.now()].
/// In QA/Testing mode, it incorporates a virtual time offset to simulate advancing
/// time (e.g. +1h, +4h, +24h, +3d, +7d), allowing full end-to-end lifecycle testing
/// of SRS review intervals, daily lesson rollovers, and midnight resets.
class AppTime {
  AppTime._();

  static const _keyTimeOffsetMs = 'dev_virtual_time_offset_ms';
  static Duration _offset = Duration.zero;

  /// Listenable for UI widgets that want to rebuild when the simulated time changes.
  static final ValueNotifier<DateTime> timeNotifier = ValueNotifier<DateTime>(DateTime.now());

  /// Initializes the time offset from persistent preferences.
  static void init(SharedPreferences prefs) {
    final ms = prefs.getInt(_keyTimeOffsetMs) ?? 0;
    _offset = Duration(milliseconds: ms);
    timeNotifier.value = now();
  }

  /// Returns the current simulated (or real) [DateTime].
  /// In release mode, this is strictly guaranteed to return [DateTime.now()].
  static DateTime now() {
    if (kReleaseMode || _offset == Duration.zero) {
      return DateTime.now();
    }
    return DateTime.now().add(_offset);
  }

  /// Current simulated time offset.
  static Duration get offset => _offset;

  /// True if the clock has been fast-forwarded into the future.
  static bool get isTimeShifted => _offset != Duration.zero;

  /// Human-readable description of current virtual offset.
  static String get offsetLabel {
    if (_offset == Duration.zero) return 'Real Time';
    final hours = _offset.inHours;
    final days = _offset.inDays;
    if (days >= 1) {
      final remHours = hours % 24;
      return remHours == 0 ? '+$days day${days > 1 ? "s" : ""}' : '+$days d ${remHours}h';
    }
    return '+$hours hr${hours > 1 ? "s" : ""}';
  }

  /// Advances virtual time by [duration] and persists to SharedPreferences.
  static Future<void> addOffset(Duration duration, SharedPreferences prefs) async {
    _offset += duration;
    await prefs.setInt(_keyTimeOffsetMs, _offset.inMilliseconds);
    timeNotifier.value = now();
  }

  /// Resets virtual time back to actual real-time.
  static Future<void> resetOffset(SharedPreferences prefs) async {
    _offset = Duration.zero;
    await prefs.remove(_keyTimeOffsetMs);
    timeNotifier.value = now();
  }
}
