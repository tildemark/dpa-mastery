import 'package:drift/drift.dart';

// ─── Questions ───────────────────────────────────────────────────────────────

/// Stores all exam questions. Content is managed via OTA upserts.
/// [difficultyLevel]: 1 (Basic) → 5 (Edge-Case). Used for progression gating.
/// [optionsJson]: serialised JSON array of answer strings, e.g. '["A","B","C","D"]'.
class Questions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get difficultyLevel =>
      integer().withDefault(const Constant(1))();
  TextColumn get questionText => text()();
  TextColumn get lessonConcept => text()();
  TextColumn get explanation => text()();
  TextColumn get optionsJson => text()(); // Serialised List<String>
  TextColumn get correctAnswer => text()();
}

// ─── Tags ─────────────────────────────────────────────────────────────────────

/// Normalised tag bank (e.g. "Consent", "Module 4: Lawful Criteria").
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

// ─── QuestionTags (many-to-many junction) ────────────────────────────────────

/// Maps questions to their tags. Supports flexible tag-based drilling.
class QuestionTags extends Table {
  IntColumn get questionId =>
      integer().references(Questions, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {questionId, tagId};
}

// ─── UserProgress ────────────────────────────────────────────────────────────

/// Tracks per-question SRS state. Never overwritten by OTA content syncs.
///
/// SRS stages:
///   0 = Locked (not yet started in Lessons)
///   1–4 = Apprentice (4h, 8h, 24h, 48h)
///   5–6 = Guru (1 week, 2 weeks)
///   7   = Master (1 month)
///   8   = Burned (retired)
class UserProgress extends Table {
  IntColumn get questionId =>
      integer().references(Questions, #id, onDelete: KeyAction.cascade)();
  IntColumn get srsStage =>
      integer().withDefault(const Constant(0))();
  IntColumn get mistakeCount =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get nextReviewTime => dateTime().nullable()();

  /// true once the item has been completed in Lessons Mode and promoted to Appr 1.
  BoolColumn get isLessonCompleted =>
      boolean().withDefault(const Constant(false))();

  /// true for user-created / imported custom cards (offline sandbox).
  BoolColumn get isCustom =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {questionId};
}
