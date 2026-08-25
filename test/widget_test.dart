import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'package:dpa_mastery/main.dart';
import 'package:dpa_mastery/db/app_database.dart';

void main() {
  testWidgets('App root smoke test builds successfully', (WidgetTester tester) async {
    // Instantiate test DB with in-memory SQLite (synchronous executor without driftDatabase background isolate)
    final inMemoryDb = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(inMemoryDb),
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
