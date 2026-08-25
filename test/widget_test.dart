import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'package:dpa_mastery/main.dart';
import 'package:dpa_mastery/db/app_database.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:dpa_mastery/services/settings_service.dart';

void main() {
  testWidgets('App root smoke test builds successfully', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final inMemoryDb = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(inMemoryDb),
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const DpaMasteryApp(),
      ),
    );

    expect(find.text('DPA Mastery'), findsWidgets);
    expect(find.text('Lessons'), findsOneWidget);
    expect(find.text('Reviews'), findsOneWidget);

    await inMemoryDb.close();
  });
}
