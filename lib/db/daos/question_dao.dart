import 'package:drift/drift.dart';

import '../app_database.dart';

part 'question_dao.g.dart';

@DriftAccessor(tables: [Questions, Tags, QuestionTags])
class QuestionDao extends DatabaseAccessor<AppDatabase>
    with _$QuestionDaoMixin {
  QuestionDao(super.db);

  // ─── Upsert ──────────────────────────────────────────────────────────────

  /// Inserts or replaces question content from OTA / seed payloads.
  /// Never touches [UserProgress].
  Future<void> upsertQuestions(List<QuestionsCompanion> rows) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(questions, rows);
    });
  }

  /// Inserts or resolves a tag by name, returning its id.
  Future<int> upsertTag(String tagName) async {
    final existing = await (select(tags)
          ..where((t) => t.name.equals(tagName)))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return into(tags).insert(TagsCompanion.insert(name: tagName));
  }

  /// Inserts a QuestionTag link if it doesn't already exist.
  Future<void> linkQuestionTag(int questionId, int tagId) async {
    await into(questionTags).insertOnConflictUpdate(
      QuestionTagsCompanion.insert(
        questionId: questionId,
        tagId: tagId,
      ),
    );
  }

  // ─── Queries ─────────────────────────────────────────────────────────────

  /// All questions at a given difficulty level.
  Future<List<Question>> getQuestionsByDifficulty(int level) {
    return (select(questions)
          ..where((q) => q.difficultyLevel.equals(level)))
        .get();
  }

  /// All questions associated with a given tag name (flexible drilling).
  ///
  /// Example: getQuestionsByTag('Consent') returns every question
  /// tagged "Consent", regardless of module.
  Future<List<Question>> getQuestionsByTag(String tagName) {
    final query = select(questions).join([
      innerJoin(questionTags,
          questionTags.questionId.equalsExp(questions.id)),
      innerJoin(tags, tags.id.equalsExp(questionTags.tagId)),
    ])
      ..where(tags.name.equals(tagName));

    return query.map((row) => row.readTable(questions)).get();
  }

  /// Fetches a single question by its primary key.
  Future<Question?> getQuestionById(int id) {
    return (select(questions)..where((q) => q.id.equals(id)))
        .getSingleOrNull();
  }

  /// All questions at a given difficulty level that still have srsStage == 0.
  /// Used by Lessons Mode to determine which items are awaiting their first lesson.
  Future<List<Question>> getUnlearnedQuestions(int difficultyLevel) {
    final query = select(questions).join([
      leftOuterJoin(
        db.userProgress,
        db.userProgress.questionId.equalsExp(questions.id),
      ),
    ])
      ..where(questions.difficultyLevel.equals(difficultyLevel) &
          (db.userProgress.srsStage.equals(0) |
              db.userProgress.srsStage.isNull()));

    return query.map((row) => row.readTable(questions)).get();
  }

  /// Returns all tags stored in the database.
  Future<List<Tag>> getAllTags() {
    return select(tags).get();
  }

  /// Returns all tags associated with a specific question.
  Future<List<Tag>> getTagsForQuestion(int questionId) {
    final query = select(tags).join([
      innerJoin(
        questionTags,
        questionTags.tagId.equalsExp(tags.id),
      ),
    ])
      ..where(questionTags.questionId.equals(questionId));

    return query.map((row) => row.readTable(tags)).get();
  }

  /// Returns questions matching any tag that begins with [prefix] (e.g. 'Module 1').
  Future<List<Question>> getQuestionsByTagPrefix(String prefix) {
    final query = select(questions).join([
      innerJoin(
        questionTags,
        questionTags.questionId.equalsExp(questions.id),
      ),
      innerJoin(
        tags,
        tags.id.equalsExp(questionTags.tagId),
      ),
    ])
      ..where(tags.name.like('$prefix%'));

    return query.map((row) => row.readTable(questions)).get();
  }
}
