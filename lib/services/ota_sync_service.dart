import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'seed_loader.dart';

/// Checks the remote GitHub Pages manifest for content updates and
/// downloads / upserts new seed payloads for modules 2–7.
///
/// Already-synced modules at the latest version are skipped entirely.
/// [UserProgress] is never modified.
class OtaSyncService {
  OtaSyncService({
    required this._seedLoader,
    required this._manifestUrl,
  });

  final SeedLoader _seedLoader;
  final String _manifestUrl;

  static const _prefKeyPrefix = 'ota_module_version_';

  /// Fetches the remote manifest and downloads any modules whose remote
  /// version is newer than the locally stored version.
  ///
  /// Should be called on app launch (after bundled seeds are loaded).
  Future<OtaSyncResult> checkAndSync() async {
    try {
      final response = await http
          .get(Uri.parse(_manifestUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return OtaSyncResult.failed(
            'Manifest fetch failed: HTTP ${response.statusCode}');
      }

      final manifest = jsonDecode(response.body) as Map<String, dynamic>;
      final modules = manifest['modules'] as List<dynamic>;
      final prefs = await SharedPreferences.getInstance();

      int updatedCount = 0;

      for (final entry in modules) {
        final moduleName = entry['module'] as String;
        final remoteVersion = entry['version'] as int;
        final url = entry['url'] as String;

        final localVersion = prefs.getInt('$_prefKeyPrefix$moduleName') ?? 0;

        if (remoteVersion > localVersion) {
          await _downloadAndApply(url);
          await prefs.setInt('$_prefKeyPrefix$moduleName', remoteVersion);
          updatedCount++;
        }
      }

      return OtaSyncResult.success(modulesUpdated: updatedCount);
    } catch (e) {
      return OtaSyncResult.failed(e.toString());
    }
  }

  // ─── Private ─────────────────────────────────────────────────────────────

  Future<void> _downloadAndApply(String url) async {
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Failed to download seed: $url (${response.statusCode})');
    }

    await _seedLoader.applySeedJson(response.body);
  }
}

/// Result of an OTA sync attempt.
class OtaSyncResult {
  OtaSyncResult.success({required this.modulesUpdated})
      : succeeded = true,
        errorMessage = null;

  OtaSyncResult.failed(this.errorMessage)
      : succeeded = false,
        modulesUpdated = 0;

  final bool succeeded;
  final int modulesUpdated;
  final String? errorMessage;

  bool get hasUpdates => modulesUpdated > 0;

  @override
  String toString() => succeeded
      ? 'OtaSyncResult: $modulesUpdated module(s) updated'
      : 'OtaSyncResult: failed — $errorMessage';
}
