import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db/app_database.dart';
import 'services/app_time.dart';
import 'services/seed_loader.dart';
import 'services/ota_sync_service.dart';
import 'services/settings_service.dart';
import 'features/home/home_screen.dart';

const _manifestUrl =
    'https://dpa-mastery.sanchez.ph/manifest.json';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final prefs = await SharedPreferences.getInstance();
  AppTime.init(prefs);
  final seedLoader = SeedLoader(db);
  final otaSync = OtaSyncService(
    seedLoader: seedLoader,
    manifestUrl: _manifestUrl,
  );

  // Load bundled seed assets on cold launch (upsert — safe to repeat) and purge uninstalled DLC.
  await seedLoader.loadBundledSeeds(prefs: prefs);

  // Attempt OTA sync in the background.
  otaSync.checkAndSync().then((result) {
    debugPrint(result.toString());
  });

  runApp(
    ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const DpaMasteryApp(),
    ),
  );
}

// ─── App-level Riverpod providers ────────────────────────────────────────────

final dbProvider = Provider<AppDatabase>((_) {
  throw UnimplementedError('dbProvider must be overridden at the ProviderScope');
});

// ─── Root widget ─────────────────────────────────────────────────────────────

class DpaMasteryApp extends StatelessWidget {
  const DpaMasteryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DPA Mastery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E6AD2),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
