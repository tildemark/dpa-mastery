import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import 'daos/question_dao.dart';
import 'daos/progress_dao.dart';

export 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Questions, Tags, QuestionTags, UserProgress],
  daos: [QuestionDao, ProgressDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// Schema version — increment when tables change and provide a migration.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Future migrations go here.
        },
      );
}

/// Opens (or creates) the SQLite database file in the app documents directory,
/// or uses IndexedDB / WebAssembly when running on the web.
QueryExecutor _openConnection() {
  if (kIsWeb) {
    return driftDatabase(
      name: 'dpa_mastery',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  return driftDatabase(
    name: 'dpa_mastery',
    native: DriftNativeOptions(
      databasePath: () async {
        final dir = await getApplicationDocumentsDirectory();
        return p.join(dir.path, 'dpa_mastery.db');
      },
    ),
  );
}

