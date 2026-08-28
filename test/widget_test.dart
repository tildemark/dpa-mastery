import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dpa_mastery/main.dart';
import 'package:dpa_mastery/db/app_database.dart';
import 'package:dpa_mastery/db/daos/progress_dao.dart';
import 'package:dpa_mastery/engine/readiness_service.dart';
import 'package:dpa_mastery/features/home/home_providers.dart';
import 'package:dpa_mastery/features/home/module_mastery_provider.dart';
import 'package:dpa_mastery/features/reviews/review_provider.dart';
import 'package:dpa_mastery/services/settings_service.dart';
import 'package:dpa_mastery/services/dlc/dlc_model.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Smoke test — verifies the app root mounts without triggering drift streams.
//
// Strategy: override ALL StreamProviders with Stream.value() static stubs so
// the real DB's change-notification machinery (StreamQueryStore.markAsClosed)
// is never exercised during the test's fake-async zone.  The DB is still
// provided to satisfy the provider graph but is never actually queried.
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late AppDatabase inMemoryDb;

  setUp(() {
    inMemoryDb = AppDatabase(NativeDatabase.memory());
  });

  // Close DB after the test completes — outside the fake-async zone used by
  // testWidgets, so drift's Timer.run() teardown call is never seen by the
  // test framework.
  tearDown(() async {
    await inMemoryDb.close();
  });

  testWidgets(
    'App root smoke test builds successfully',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      const emptyCounts = SrsStageCounts(
        available: 0,
        apprentice: 0,
        guru: 0,
        master: 0,
        burned: 0,
      );
      const emptyForecast = ReviewForecast(
        within1h: 0,
        within4h: 0,
        within24h: 0,
        within3d: 0,
        within7d: 0,
      );
      const emptyReadiness = ReadinessResult(
        score: 0,
        depth: 0,
        breadth: 0,
        totalQuestions: 0,
        guruPlusTotal: 0,
        remainingItemsToGuru: 0,
      );
      final emptyTiers = List.generate(
        5,
        (i) => TierProgressionItem(
          level: i + 1,
          isUnlocked: i == 0,
          guruRatio: 0.0,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dbProvider.overrideWithValue(inMemoryDb),
            sharedPrefsProvider.overrideWithValue(prefs),
            // Override ALL stream providers with static Stream.value() stubs.
            // This is the critical guard: it prevents drift's StreamQueryStore
            // from registering any watchers, so no Timer.run() teardown fires
            // inside testWidgets' fake-async zone.
            reviewQueueProvider.overrideWith(
              (ref) => Stream.value(<ReviewItem>[]),
            ),
            srsStageCountsStreamProvider.overrideWith(
              (ref) => Stream.value(emptyCounts),
            ),
            reviewForecastStreamProvider.overrideWith(
              (ref) => Stream.value(emptyForecast),
            ),
            nextReviewTimeStreamProvider.overrideWith(
              (ref) => Stream<DateTime?>.value(null),
            ),
            homeProfileStreamProvider.overrideWith(
              (ref) => Stream.value(
                const HomeProfileMetrics(
                  rank: null,
                  readiness: emptyReadiness,
                  dualTrack: DualTrackMetrics(
                    coreTotal: 282,
                    coreGuru: 0,
                    dlcTotal: 0,
                    dlcGuru: 0,
                    hasInstalledDlc: false,
                  ),
                ),
              ),
            ),
            tierProgressionStreamProvider.overrideWith(
              (ref) => Stream.value(emptyTiers),
            ),
            missedQuestionsCountProvider.overrideWith(
              (ref) => Stream.value(0),
            ),
            moduleMasteryStreamProvider.overrideWith(
              (ref) => Stream.value(<ModuleMasteryData>[]),
            ),
            installedPacksProgressProvider.overrideWith(
              (ref) => Stream.value(<(DlcPack, DlcPackProgress)>[]),
            ),
          ],
          child: const DpaMasteryApp(),
        ),
      );

      // Deliver stream values and settle the first frame.
      await tester.pump();

      expect(find.text('DPA Mastery'), findsWidgets);
      expect(find.text('Lessons'), findsOneWidget);
      expect(find.text('Reviews'), findsOneWidget);
    },
  );
}
