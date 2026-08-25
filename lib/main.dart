import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/app_database.dart';
import 'services/seed_loader.dart';
import 'services/ota_sync_service.dart';
import 'features/home/home_screen.dart';

// TODO(Phase 6): Replace with the real GitHub Pages URL once deployed.
const _manifestUrl =
    'https://tildeapp.github.io/dpa-mastery/seeds/manifest.json';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final seedLoader = SeedLoader(db);
  final otaSync = OtaSyncService(
    seedLoader: seedLoader,
    manifestUrl: _manifestUrl,
  );

  // Load bundled Module 1 seed on every cold launch (upsert — safe to repeat).
  await seedLoader.loadBundledSeeds();

  // Attempt OTA sync for modules 2–7 in the background.
  otaSync.checkAndSync().then((result) {
    debugPrint(result.toString());
  });

  runApp(
    ProviderScope(
      overrides: [
        // Make AppDatabase available app-wide via Riverpod.
        dbProvider.overrideWithValue(db),
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
