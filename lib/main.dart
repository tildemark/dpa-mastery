import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db/app_database.dart';
import 'services/app_time.dart';
import 'services/seed_loader.dart';
import 'services/ota_sync_service.dart';
import 'services/settings_service.dart';
import 'features/home/home_screen.dart';

const _manifestUrl = 'https://dpa-mastery.sanchez.ph/manifest.json';

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
      home: const SplashScreen(),
    );
  }
}

// ─── Splash / Loading Screen ──────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  String _version = 'v1.7.0';
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();

    _loadVersionAndNavigate();
  }

  Future<void> _loadVersionAndNavigate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = 'v${info.version}+${info.buildNumber}';
        });
      }
    } catch (_) {}

    // Smooth presentation pause before transition
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, anim, secAnim) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070913),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                // App Logo
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x556366F1),
                        blurRadius: 30,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 96,
                      height: 96,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                const Text(
                  'DPA Mastery',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                // Subtitle
                const Text(
                  'Philippine Data Privacy Assessment & SRS Engine',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 16),
                // Version Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF6366F1).withAlpha(100)),
                  ),
                  child: Text(
                    _version,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF818CF8),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                // Loading Spinner
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Initializing offline privacy ledger...',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
