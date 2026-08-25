// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $QuestionsTable extends Questions
    with TableInfo<$QuestionsTable, Question> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _difficultyLevelMeta = const VerificationMeta(
    'difficultyLevel',
  );
  @override
  late final GeneratedColumn<int> difficultyLevel = GeneratedColumn<int>(
    'difficulty_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _questionTextMeta = const VerificationMeta(
    'questionText',
  );
  @override
  late final GeneratedColumn<String> questionText = GeneratedColumn<String>(
    'question_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lessonConceptMeta = const VerificationMeta(
    'lessonConcept',
  );
  @override
  late final GeneratedColumn<String> lessonConcept = GeneratedColumn<String>(
    'lesson_concept',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionsJsonMeta = const VerificationMeta(
    'optionsJson',
  );
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
    'options_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctAnswerMeta = const VerificationMeta(
    'correctAnswer',
  );
  @override
  late final GeneratedColumn<String> correctAnswer = GeneratedColumn<String>(
    'correct_answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    difficultyLevel,
    questionText,
    lessonConcept,
    explanation,
    optionsJson,
    correctAnswer,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Question> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('difficulty_level')) {
      context.handle(
        _difficultyLevelMeta,
        difficultyLevel.isAcceptableOrUnknown(
          data['difficulty_level']!,
          _difficultyLevelMeta,
        ),
      );
    }
    if (data.containsKey('question_text')) {
      context.handle(
        _questionTextMeta,
        questionText.isAcceptableOrUnknown(
          data['question_text']!,
          _questionTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionTextMeta);
    }
    if (data.containsKey('lesson_concept')) {
      context.handle(
        _lessonConceptMeta,
        lessonConcept.isAcceptableOrUnknown(
          data['lesson_concept']!,
          _lessonConceptMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lessonConceptMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_explanationMeta);
    }
    if (data.containsKey('options_json')) {
      context.handle(
        _optionsJsonMeta,
        optionsJson.isAcceptableOrUnknown(
          data['options_json']!,
          _optionsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_optionsJsonMeta);
    }
    if (data.containsKey('correct_answer')) {
      context.handle(
        _correctAnswerMeta,
        correctAnswer.isAcceptableOrUnknown(
          data['correct_answer']!,
          _correctAnswerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctAnswerMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Question map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Question(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      difficultyLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty_level'],
      )!,
      questionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_text'],
      )!,
      lessonConcept: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_concept'],
      )!,
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      )!,
      optionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options_json'],
      )!,
      correctAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correct_answer'],
      )!,
    );
  }

  @override
  $QuestionsTable createAlias(String alias) {
    return $QuestionsTable(attachedDatabase, alias);
  }
}

class Question extends DataClass implements Insertable<Question> {
  final int id;
  final int difficultyLevel;
  final String questionText;
  final String lessonConcept;
  final String explanation;
  final String optionsJson;
  final String correctAnswer;
  const Question({
    required this.id,
    required this.difficultyLevel,
    required this.questionText,
    required this.lessonConcept,
    required this.explanation,
    required this.optionsJson,
    required this.correctAnswer,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['difficulty_level'] = Variable<int>(difficultyLevel);
    map['question_text'] = Variable<String>(questionText);
    map['lesson_concept'] = Variable<String>(lessonConcept);
    map['explanation'] = Variable<String>(explanation);
    map['options_json'] = Variable<String>(optionsJson);
    map['correct_answer'] = Variable<String>(correctAnswer);
    return map;
  }

  QuestionsCompanion toCompanion(bool nullToAbsent) {
    return QuestionsCompanion(
      id: Value(id),
      difficultyLevel: Value(difficultyLevel),
      questionText: Value(questionText),
      lessonConcept: Value(lessonConcept),
      explanation: Value(explanation),
      optionsJson: Value(optionsJson),
      correctAnswer: Value(correctAnswer),
    );
  }

  factory Question.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Question(
      id: serializer.fromJson<int>(json['id']),
      difficultyLevel: serializer.fromJson<int>(json['difficultyLevel']),
      questionText: serializer.fromJson<String>(json['questionText']),
      lessonConcept: serializer.fromJson<String>(json['lessonConcept']),
      explanation: serializer.fromJson<String>(json['explanation']),
      optionsJson: serializer.fromJson<String>(json['optionsJson']),
      correctAnswer: serializer.fromJson<String>(json['correctAnswer']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'difficultyLevel': serializer.toJson<int>(difficultyLevel),
      'questionText': serializer.toJson<String>(questionText),
      'lessonConcept': serializer.toJson<String>(lessonConcept),
      'explanation': serializer.toJson<String>(explanation),
      'optionsJson': serializer.toJson<String>(optionsJson),
      'correctAnswer': serializer.toJson<String>(correctAnswer),
    };
  }

  Question copyWith({
    int? id,
    int? difficultyLevel,
    String? questionText,
    String? lessonConcept,
    String? explanation,
    String? optionsJson,
    String? correctAnswer,
  }) => Question(
    id: id ?? this.id,
    difficultyLevel: difficultyLevel ?? this.difficultyLevel,
    questionText: questionText ?? this.questionText,
    lessonConcept: lessonConcept ?? this.lessonConcept,
    explanation: explanation ?? this.explanation,
    optionsJson: optionsJson ?? this.optionsJson,
    correctAnswer: correctAnswer ?? this.correctAnswer,
  );
  Question copyWithCompanion(QuestionsCompanion data) {
    return Question(
      id: data.id.present ? data.id.value : this.id,
      difficultyLevel: data.difficultyLevel.present
          ? data.difficultyLevel.value
          : this.difficultyLevel,
      questionText: data.questionText.present
          ? data.questionText.value
          : this.questionText,
      lessonConcept: data.lessonConcept.present
          ? data.lessonConcept.value
          : this.lessonConcept,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      optionsJson: data.optionsJson.present
          ? data.optionsJson.value
          : this.optionsJson,
      correctAnswer: data.correctAnswer.present
          ? data.correctAnswer.value
          : this.correctAnswer,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Question(')
          ..write('id: $id, ')
          ..write('difficultyLevel: $difficultyLevel, ')
          ..write('questionText: $questionText, ')
          ..write('lessonConcept: $lessonConcept, ')
          ..write('explanation: $explanation, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('correctAnswer: $correctAnswer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    difficultyLevel,
    questionText,
    lessonConcept,
    explanation,
    optionsJson,
    correctAnswer,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Question &&
          other.id == this.id &&
          other.difficultyLevel == this.difficultyLevel &&
          other.questionText == this.questionText &&
          other.lessonConcept == this.lessonConcept &&
          other.explanation == this.explanation &&
          other.optionsJson == this.optionsJson &&
          other.correctAnswer == this.correctAnswer);
}

class QuestionsCompanion extends UpdateCompanion<Question> {
  final Value<int> id;
  final Value<int> difficultyLevel;
  final Value<String> questionText;
  final Value<String> lessonConcept;
  final Value<String> explanation;
  final Value<String> optionsJson;
  final Value<String> correctAnswer;
  const QuestionsCompanion({
    this.id = const Value.absent(),
    this.difficultyLevel = const Value.absent(),
    this.questionText = const Value.absent(),
    this.lessonConcept = const Value.absent(),
    this.explanation = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.correctAnswer = const Value.absent(),
  });
  QuestionsCompanion.insert({
    this.id = const Value.absent(),
    this.difficultyLevel = const Value.absent(),
    required String questionText,
    required String lessonConcept,
    required String explanation,
    required String optionsJson,
    required String correctAnswer,
  }) : questionText = Value(questionText),
       lessonConcept = Value(lessonConcept),
       explanation = Value(explanation),
       optionsJson = Value(optionsJson),
       correctAnswer = Value(correctAnswer);
  static Insertable<Question> custom({
    Expression<int>? id,
    Expression<int>? difficultyLevel,
    Expression<String>? questionText,
    Expression<String>? lessonConcept,
    Expression<String>? explanation,
    Expression<String>? optionsJson,
    Expression<String>? correctAnswer,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (difficultyLevel != null) 'difficulty_level': difficultyLevel,
      if (questionText != null) 'question_text': questionText,
      if (lessonConcept != null) 'lesson_concept': lessonConcept,
      if (explanation != null) 'explanation': explanation,
      if (optionsJson != null) 'options_json': optionsJson,
      if (correctAnswer != null) 'correct_answer': correctAnswer,
    });
  }

  QuestionsCompanion copyWith({
    Value<int>? id,
    Value<int>? difficultyLevel,
    Value<String>? questionText,
    Value<String>? lessonConcept,
    Value<String>? explanation,
    Value<String>? optionsJson,
    Value<String>? correctAnswer,
  }) {
    return QuestionsCompanion(
      id: id ?? this.id,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      questionText: questionText ?? this.questionText,
      lessonConcept: lessonConcept ?? this.lessonConcept,
      explanation: explanation ?? this.explanation,
      optionsJson: optionsJson ?? this.optionsJson,
      correctAnswer: correctAnswer ?? this.correctAnswer,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (difficultyLevel.present) {
      map['difficulty_level'] = Variable<int>(difficultyLevel.value);
    }
    if (questionText.present) {
      map['question_text'] = Variable<String>(questionText.value);
    }
    if (lessonConcept.present) {
      map['lesson_concept'] = Variable<String>(lessonConcept.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    if (correctAnswer.present) {
      map['correct_answer'] = Variable<String>(correctAnswer.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionsCompanion(')
          ..write('id: $id, ')
          ..write('difficultyLevel: $difficultyLevel, ')
          ..write('questionText: $questionText, ')
          ..write('lessonConcept: $lessonConcept, ')
          ..write('explanation: $explanation, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('correctAnswer: $correctAnswer')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  const Tag({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(id: Value(id), name: Value(name));
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Tag copyWith({int? id, String? name}) =>
      Tag(id: id ?? this.id, name: name ?? this.name);
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag && other.id == this.id && other.name == this.name);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  TagsCompanion.insert({this.id = const Value.absent(), required String name})
    : name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  TagsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return TagsCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $QuestionTagsTable extends QuestionTags
    with TableInfo<$QuestionTagsTable, QuestionTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES questions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [questionId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestionTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId, tagId};
  @override
  QuestionTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionTag(
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $QuestionTagsTable createAlias(String alias) {
    return $QuestionTagsTable(attachedDatabase, alias);
  }
}

class QuestionTag extends DataClass implements Insertable<QuestionTag> {
  final int questionId;
  final int tagId;
  const QuestionTag({required this.questionId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<int>(questionId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  QuestionTagsCompanion toCompanion(bool nullToAbsent) {
    return QuestionTagsCompanion(
      questionId: Value(questionId),
      tagId: Value(tagId),
    );
  }

  factory QuestionTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionTag(
      questionId: serializer.fromJson<int>(json['questionId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questionId': serializer.toJson<int>(questionId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  QuestionTag copyWith({int? questionId, int? tagId}) => QuestionTag(
    questionId: questionId ?? this.questionId,
    tagId: tagId ?? this.tagId,
  );
  QuestionTag copyWithCompanion(QuestionTagsCompanion data) {
    return QuestionTag(
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionTag(')
          ..write('questionId: $questionId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(questionId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionTag &&
          other.questionId == this.questionId &&
          other.tagId == this.tagId);
}

class QuestionTagsCompanion extends UpdateCompanion<QuestionTag> {
  final Value<int> questionId;
  final Value<int> tagId;
  final Value<int> rowid;
  const QuestionTagsCompanion({
    this.questionId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionTagsCompanion.insert({
    required int questionId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : questionId = Value(questionId),
       tagId = Value(tagId);
  static Insertable<QuestionTag> custom({
    Expression<int>? questionId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionTagsCompanion copyWith({
    Value<int>? questionId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return QuestionTagsCompanion(
      questionId: questionId ?? this.questionId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionTagsCompanion(')
          ..write('questionId: $questionId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProgressTable extends UserProgress
    with TableInfo<$UserProgressTable, UserProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES questions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _srsStageMeta = const VerificationMeta(
    'srsStage',
  );
  @override
  late final GeneratedColumn<int> srsStage = GeneratedColumn<int>(
    'srs_stage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mistakeCountMeta = const VerificationMeta(
    'mistakeCount',
  );
  @override
  late final GeneratedColumn<int> mistakeCount = GeneratedColumn<int>(
    'mistake_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextReviewTimeMeta = const VerificationMeta(
    'nextReviewTime',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewTime =
      GeneratedColumn<DateTime>(
        'next_review_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isLessonCompletedMeta = const VerificationMeta(
    'isLessonCompleted',
  );
  @override
  late final GeneratedColumn<bool> isLessonCompleted = GeneratedColumn<bool>(
    'is_lesson_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_lesson_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    questionId,
    srsStage,
    mistakeCount,
    nextReviewTime,
    isLessonCompleted,
    isCustom,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    }
    if (data.containsKey('srs_stage')) {
      context.handle(
        _srsStageMeta,
        srsStage.isAcceptableOrUnknown(data['srs_stage']!, _srsStageMeta),
      );
    }
    if (data.containsKey('mistake_count')) {
      context.handle(
        _mistakeCountMeta,
        mistakeCount.isAcceptableOrUnknown(
          data['mistake_count']!,
          _mistakeCountMeta,
        ),
      );
    }
    if (data.containsKey('next_review_time')) {
      context.handle(
        _nextReviewTimeMeta,
        nextReviewTime.isAcceptableOrUnknown(
          data['next_review_time']!,
          _nextReviewTimeMeta,
        ),
      );
    }
    if (data.containsKey('is_lesson_completed')) {
      context.handle(
        _isLessonCompletedMeta,
        isLessonCompleted.isAcceptableOrUnknown(
          data['is_lesson_completed']!,
          _isLessonCompletedMeta,
        ),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId};
  @override
  UserProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProgressData(
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_id'],
      )!,
      srsStage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}srs_stage'],
      )!,
      mistakeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mistake_count'],
      )!,
      nextReviewTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_time'],
      ),
      isLessonCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_lesson_completed'],
      )!,
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
    );
  }

  @override
  $UserProgressTable createAlias(String alias) {
    return $UserProgressTable(attachedDatabase, alias);
  }
}

class UserProgressData extends DataClass
    implements Insertable<UserProgressData> {
  final int questionId;
  final int srsStage;
  final int mistakeCount;
  final DateTime? nextReviewTime;

  /// true once the item has been completed in Lessons Mode and promoted to Appr 1.
  final bool isLessonCompleted;

  /// true for user-created / imported custom cards (offline sandbox).
  final bool isCustom;
  const UserProgressData({
    required this.questionId,
    required this.srsStage,
    required this.mistakeCount,
    this.nextReviewTime,
    required this.isLessonCompleted,
    required this.isCustom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<int>(questionId);
    map['srs_stage'] = Variable<int>(srsStage);
    map['mistake_count'] = Variable<int>(mistakeCount);
    if (!nullToAbsent || nextReviewTime != null) {
      map['next_review_time'] = Variable<DateTime>(nextReviewTime);
    }
    map['is_lesson_completed'] = Variable<bool>(isLessonCompleted);
    map['is_custom'] = Variable<bool>(isCustom);
    return map;
  }

  UserProgressCompanion toCompanion(bool nullToAbsent) {
    return UserProgressCompanion(
      questionId: Value(questionId),
      srsStage: Value(srsStage),
      mistakeCount: Value(mistakeCount),
      nextReviewTime: nextReviewTime == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReviewTime),
      isLessonCompleted: Value(isLessonCompleted),
      isCustom: Value(isCustom),
    );
  }

  factory UserProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProgressData(
      questionId: serializer.fromJson<int>(json['questionId']),
      srsStage: serializer.fromJson<int>(json['srsStage']),
      mistakeCount: serializer.fromJson<int>(json['mistakeCount']),
      nextReviewTime: serializer.fromJson<DateTime?>(json['nextReviewTime']),
      isLessonCompleted: serializer.fromJson<bool>(json['isLessonCompleted']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questionId': serializer.toJson<int>(questionId),
      'srsStage': serializer.toJson<int>(srsStage),
      'mistakeCount': serializer.toJson<int>(mistakeCount),
      'nextReviewTime': serializer.toJson<DateTime?>(nextReviewTime),
      'isLessonCompleted': serializer.toJson<bool>(isLessonCompleted),
      'isCustom': serializer.toJson<bool>(isCustom),
    };
  }

  UserProgressData copyWith({
    int? questionId,
    int? srsStage,
    int? mistakeCount,
    Value<DateTime?> nextReviewTime = const Value.absent(),
    bool? isLessonCompleted,
    bool? isCustom,
  }) => UserProgressData(
    questionId: questionId ?? this.questionId,
    srsStage: srsStage ?? this.srsStage,
    mistakeCount: mistakeCount ?? this.mistakeCount,
    nextReviewTime: nextReviewTime.present
        ? nextReviewTime.value
        : this.nextReviewTime,
    isLessonCompleted: isLessonCompleted ?? this.isLessonCompleted,
    isCustom: isCustom ?? this.isCustom,
  );
  UserProgressData copyWithCompanion(UserProgressCompanion data) {
    return UserProgressData(
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      srsStage: data.srsStage.present ? data.srsStage.value : this.srsStage,
      mistakeCount: data.mistakeCount.present
          ? data.mistakeCount.value
          : this.mistakeCount,
      nextReviewTime: data.nextReviewTime.present
          ? data.nextReviewTime.value
          : this.nextReviewTime,
      isLessonCompleted: data.isLessonCompleted.present
          ? data.isLessonCompleted.value
          : this.isLessonCompleted,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressData(')
          ..write('questionId: $questionId, ')
          ..write('srsStage: $srsStage, ')
          ..write('mistakeCount: $mistakeCount, ')
          ..write('nextReviewTime: $nextReviewTime, ')
          ..write('isLessonCompleted: $isLessonCompleted, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    questionId,
    srsStage,
    mistakeCount,
    nextReviewTime,
    isLessonCompleted,
    isCustom,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProgressData &&
          other.questionId == this.questionId &&
          other.srsStage == this.srsStage &&
          other.mistakeCount == this.mistakeCount &&
          other.nextReviewTime == this.nextReviewTime &&
          other.isLessonCompleted == this.isLessonCompleted &&
          other.isCustom == this.isCustom);
}

class UserProgressCompanion extends UpdateCompanion<UserProgressData> {
  final Value<int> questionId;
  final Value<int> srsStage;
  final Value<int> mistakeCount;
  final Value<DateTime?> nextReviewTime;
  final Value<bool> isLessonCompleted;
  final Value<bool> isCustom;
  const UserProgressCompanion({
    this.questionId = const Value.absent(),
    this.srsStage = const Value.absent(),
    this.mistakeCount = const Value.absent(),
    this.nextReviewTime = const Value.absent(),
    this.isLessonCompleted = const Value.absent(),
    this.isCustom = const Value.absent(),
  });
  UserProgressCompanion.insert({
    this.questionId = const Value.absent(),
    this.srsStage = const Value.absent(),
    this.mistakeCount = const Value.absent(),
    this.nextReviewTime = const Value.absent(),
    this.isLessonCompleted = const Value.absent(),
    this.isCustom = const Value.absent(),
  });
  static Insertable<UserProgressData> custom({
    Expression<int>? questionId,
    Expression<int>? srsStage,
    Expression<int>? mistakeCount,
    Expression<DateTime>? nextReviewTime,
    Expression<bool>? isLessonCompleted,
    Expression<bool>? isCustom,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (srsStage != null) 'srs_stage': srsStage,
      if (mistakeCount != null) 'mistake_count': mistakeCount,
      if (nextReviewTime != null) 'next_review_time': nextReviewTime,
      if (isLessonCompleted != null) 'is_lesson_completed': isLessonCompleted,
      if (isCustom != null) 'is_custom': isCustom,
    });
  }

  UserProgressCompanion copyWith({
    Value<int>? questionId,
    Value<int>? srsStage,
    Value<int>? mistakeCount,
    Value<DateTime?>? nextReviewTime,
    Value<bool>? isLessonCompleted,
    Value<bool>? isCustom,
  }) {
    return UserProgressCompanion(
      questionId: questionId ?? this.questionId,
      srsStage: srsStage ?? this.srsStage,
      mistakeCount: mistakeCount ?? this.mistakeCount,
      nextReviewTime: nextReviewTime ?? this.nextReviewTime,
      isLessonCompleted: isLessonCompleted ?? this.isLessonCompleted,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (srsStage.present) {
      map['srs_stage'] = Variable<int>(srsStage.value);
    }
    if (mistakeCount.present) {
      map['mistake_count'] = Variable<int>(mistakeCount.value);
    }
    if (nextReviewTime.present) {
      map['next_review_time'] = Variable<DateTime>(nextReviewTime.value);
    }
    if (isLessonCompleted.present) {
      map['is_lesson_completed'] = Variable<bool>(isLessonCompleted.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressCompanion(')
          ..write('questionId: $questionId, ')
          ..write('srsStage: $srsStage, ')
          ..write('mistakeCount: $mistakeCount, ')
          ..write('nextReviewTime: $nextReviewTime, ')
          ..write('isLessonCompleted: $isLessonCompleted, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $QuestionsTable questions = $QuestionsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $QuestionTagsTable questionTags = $QuestionTagsTable(this);
  late final $UserProgressTable userProgress = $UserProgressTable(this);
  late final QuestionDao questionDao = QuestionDao(this as AppDatabase);
  late final ProgressDao progressDao = ProgressDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    questions,
    tags,
    questionTags,
    userProgress,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'questions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('question_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('question_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'questions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_progress', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$QuestionsTableCreateCompanionBuilder =
    QuestionsCompanion Function({
      Value<int> id,
      Value<int> difficultyLevel,
      required String questionText,
      required String lessonConcept,
      required String explanation,
      required String optionsJson,
      required String correctAnswer,
    });
typedef $$QuestionsTableUpdateCompanionBuilder =
    QuestionsCompanion Function({
      Value<int> id,
      Value<int> difficultyLevel,
      Value<String> questionText,
      Value<String> lessonConcept,
      Value<String> explanation,
      Value<String> optionsJson,
      Value<String> correctAnswer,
    });

final class $$QuestionsTableReferences
    extends BaseReferences<_$AppDatabase, $QuestionsTable, Question> {
  $$QuestionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$QuestionTagsTable, List<QuestionTag>>
  _questionTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.questionTags,
    aliasName: $_aliasNameGenerator(
      db.questions.id,
      db.questionTags.questionId,
    ),
  );

  $$QuestionTagsTableProcessedTableManager get questionTagsRefs {
    final manager = $$QuestionTagsTableTableManager(
      $_db,
      $_db.questionTags,
    ).filter((f) => f.questionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_questionTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserProgressTable, List<UserProgressData>>
  _userProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userProgress,
    aliasName: $_aliasNameGenerator(
      db.questions.id,
      db.userProgress.questionId,
    ),
  );

  $$UserProgressTableProcessedTableManager get userProgressRefs {
    final manager = $$UserProgressTableTableManager(
      $_db,
      $_db.userProgress,
    ).filter((f) => f.questionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userProgressRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$QuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficultyLevel => $composableBuilder(
    column: $table.difficultyLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonConcept => $composableBuilder(
    column: $table.lessonConcept,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> questionTagsRefs(
    Expression<bool> Function($$QuestionTagsTableFilterComposer f) f,
  ) {
    final $$QuestionTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questionTags,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionTagsTableFilterComposer(
            $db: $db,
            $table: $db.questionTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userProgressRefs(
    Expression<bool> Function($$UserProgressTableFilterComposer f) f,
  ) {
    final $$UserProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProgress,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgressTableFilterComposer(
            $db: $db,
            $table: $db.userProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficultyLevel => $composableBuilder(
    column: $table.difficultyLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonConcept => $composableBuilder(
    column: $table.lessonConcept,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get difficultyLevel => $composableBuilder(
    column: $table.difficultyLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lessonConcept => $composableBuilder(
    column: $table.lessonConcept,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => column,
  );

  Expression<T> questionTagsRefs<T extends Object>(
    Expression<T> Function($$QuestionTagsTableAnnotationComposer a) f,
  ) {
    final $$QuestionTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questionTags,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.questionTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userProgressRefs<T extends Object>(
    Expression<T> Function($$UserProgressTableAnnotationComposer a) f,
  ) {
    final $$UserProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProgress,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.userProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionsTable,
          Question,
          $$QuestionsTableFilterComposer,
          $$QuestionsTableOrderingComposer,
          $$QuestionsTableAnnotationComposer,
          $$QuestionsTableCreateCompanionBuilder,
          $$QuestionsTableUpdateCompanionBuilder,
          (Question, $$QuestionsTableReferences),
          Question,
          PrefetchHooks Function({bool questionTagsRefs, bool userProgressRefs})
        > {
  $$QuestionsTableTableManager(_$AppDatabase db, $QuestionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> difficultyLevel = const Value.absent(),
                Value<String> questionText = const Value.absent(),
                Value<String> lessonConcept = const Value.absent(),
                Value<String> explanation = const Value.absent(),
                Value<String> optionsJson = const Value.absent(),
                Value<String> correctAnswer = const Value.absent(),
              }) => QuestionsCompanion(
                id: id,
                difficultyLevel: difficultyLevel,
                questionText: questionText,
                lessonConcept: lessonConcept,
                explanation: explanation,
                optionsJson: optionsJson,
                correctAnswer: correctAnswer,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> difficultyLevel = const Value.absent(),
                required String questionText,
                required String lessonConcept,
                required String explanation,
                required String optionsJson,
                required String correctAnswer,
              }) => QuestionsCompanion.insert(
                id: id,
                difficultyLevel: difficultyLevel,
                questionText: questionText,
                lessonConcept: lessonConcept,
                explanation: explanation,
                optionsJson: optionsJson,
                correctAnswer: correctAnswer,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QuestionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({questionTagsRefs = false, userProgressRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (questionTagsRefs) db.questionTags,
                    if (userProgressRefs) db.userProgress,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (questionTagsRefs)
                        await $_getPrefetchedData<
                          Question,
                          $QuestionsTable,
                          QuestionTag
                        >(
                          currentTable: table,
                          referencedTable: $$QuestionsTableReferences
                              ._questionTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QuestionsTableReferences(
                                db,
                                table,
                                p0,
                              ).questionTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.questionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userProgressRefs)
                        await $_getPrefetchedData<
                          Question,
                          $QuestionsTable,
                          UserProgressData
                        >(
                          currentTable: table,
                          referencedTable: $$QuestionsTableReferences
                              ._userProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QuestionsTableReferences(
                                db,
                                table,
                                p0,
                              ).userProgressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.questionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$QuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionsTable,
      Question,
      $$QuestionsTableFilterComposer,
      $$QuestionsTableOrderingComposer,
      $$QuestionsTableAnnotationComposer,
      $$QuestionsTableCreateCompanionBuilder,
      $$QuestionsTableUpdateCompanionBuilder,
      (Question, $$QuestionsTableReferences),
      Question,
      PrefetchHooks Function({bool questionTagsRefs, bool userProgressRefs})
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({Value<int> id, required String name});
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({Value<int> id, Value<String> name});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$QuestionTagsTable, List<QuestionTag>>
  _questionTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.questionTags,
    aliasName: $_aliasNameGenerator(db.tags.id, db.questionTags.tagId),
  );

  $$QuestionTagsTableProcessedTableManager get questionTagsRefs {
    final manager = $$QuestionTagsTableTableManager(
      $_db,
      $_db.questionTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_questionTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> questionTagsRefs(
    Expression<bool> Function($$QuestionTagsTableFilterComposer f) f,
  ) {
    final $$QuestionTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questionTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionTagsTableFilterComposer(
            $db: $db,
            $table: $db.questionTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> questionTagsRefs<T extends Object>(
    Expression<T> Function($$QuestionTagsTableAnnotationComposer a) f,
  ) {
    final $$QuestionTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questionTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.questionTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool questionTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => TagsCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  TagsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({questionTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (questionTagsRefs) db.questionTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (questionTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, QuestionTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._questionTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).questionTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool questionTagsRefs})
    >;
typedef $$QuestionTagsTableCreateCompanionBuilder =
    QuestionTagsCompanion Function({
      required int questionId,
      required int tagId,
      Value<int> rowid,
    });
typedef $$QuestionTagsTableUpdateCompanionBuilder =
    QuestionTagsCompanion Function({
      Value<int> questionId,
      Value<int> tagId,
      Value<int> rowid,
    });

final class $$QuestionTagsTableReferences
    extends BaseReferences<_$AppDatabase, $QuestionTagsTable, QuestionTag> {
  $$QuestionTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $QuestionsTable _questionIdTable(_$AppDatabase db) =>
      db.questions.createAlias(
        $_aliasNameGenerator(db.questionTags.questionId, db.questions.id),
      );

  $$QuestionsTableProcessedTableManager get questionId {
    final $_column = $_itemColumn<int>('question_id')!;

    final manager = $$QuestionsTableTableManager(
      $_db,
      $_db.questions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) => db.tags.createAlias(
    $_aliasNameGenerator(db.questionTags.tagId, db.tags.id),
  );

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuestionTagsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionTagsTable> {
  $$QuestionTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$QuestionsTableFilterComposer get questionId {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableFilterComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionTagsTable> {
  $$QuestionTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$QuestionsTableOrderingComposer get questionId {
    final $$QuestionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableOrderingComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionTagsTable> {
  $$QuestionTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$QuestionsTableAnnotationComposer get questionId {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionTagsTable,
          QuestionTag,
          $$QuestionTagsTableFilterComposer,
          $$QuestionTagsTableOrderingComposer,
          $$QuestionTagsTableAnnotationComposer,
          $$QuestionTagsTableCreateCompanionBuilder,
          $$QuestionTagsTableUpdateCompanionBuilder,
          (QuestionTag, $$QuestionTagsTableReferences),
          QuestionTag,
          PrefetchHooks Function({bool questionId, bool tagId})
        > {
  $$QuestionTagsTableTableManager(_$AppDatabase db, $QuestionTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> questionId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionTagsCompanion(
                questionId: questionId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int questionId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => QuestionTagsCompanion.insert(
                questionId: questionId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QuestionTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questionId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (questionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.questionId,
                                referencedTable: $$QuestionTagsTableReferences
                                    ._questionIdTable(db),
                                referencedColumn: $$QuestionTagsTableReferences
                                    ._questionIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$QuestionTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$QuestionTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuestionTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionTagsTable,
      QuestionTag,
      $$QuestionTagsTableFilterComposer,
      $$QuestionTagsTableOrderingComposer,
      $$QuestionTagsTableAnnotationComposer,
      $$QuestionTagsTableCreateCompanionBuilder,
      $$QuestionTagsTableUpdateCompanionBuilder,
      (QuestionTag, $$QuestionTagsTableReferences),
      QuestionTag,
      PrefetchHooks Function({bool questionId, bool tagId})
    >;
typedef $$UserProgressTableCreateCompanionBuilder =
    UserProgressCompanion Function({
      Value<int> questionId,
      Value<int> srsStage,
      Value<int> mistakeCount,
      Value<DateTime?> nextReviewTime,
      Value<bool> isLessonCompleted,
      Value<bool> isCustom,
    });
typedef $$UserProgressTableUpdateCompanionBuilder =
    UserProgressCompanion Function({
      Value<int> questionId,
      Value<int> srsStage,
      Value<int> mistakeCount,
      Value<DateTime?> nextReviewTime,
      Value<bool> isLessonCompleted,
      Value<bool> isCustom,
    });

final class $$UserProgressTableReferences
    extends
        BaseReferences<_$AppDatabase, $UserProgressTable, UserProgressData> {
  $$UserProgressTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $QuestionsTable _questionIdTable(_$AppDatabase db) =>
      db.questions.createAlias(
        $_aliasNameGenerator(db.userProgress.questionId, db.questions.id),
      );

  $$QuestionsTableProcessedTableManager get questionId {
    final $_column = $_itemColumn<int>('question_id')!;

    final manager = $$QuestionsTableTableManager(
      $_db,
      $_db.questions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserProgressTableFilterComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get srsStage => $composableBuilder(
    column: $table.srsStage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mistakeCount => $composableBuilder(
    column: $table.mistakeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewTime => $composableBuilder(
    column: $table.nextReviewTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLessonCompleted => $composableBuilder(
    column: $table.isLessonCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  $$QuestionsTableFilterComposer get questionId {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableFilterComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get srsStage => $composableBuilder(
    column: $table.srsStage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mistakeCount => $composableBuilder(
    column: $table.mistakeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewTime => $composableBuilder(
    column: $table.nextReviewTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLessonCompleted => $composableBuilder(
    column: $table.isLessonCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  $$QuestionsTableOrderingComposer get questionId {
    final $$QuestionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableOrderingComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProgressTable> {
  $$UserProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get srsStage =>
      $composableBuilder(column: $table.srsStage, builder: (column) => column);

  GeneratedColumn<int> get mistakeCount => $composableBuilder(
    column: $table.mistakeCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReviewTime => $composableBuilder(
    column: $table.nextReviewTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLessonCompleted => $composableBuilder(
    column: $table.isLessonCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  $$QuestionsTableAnnotationComposer get questionId {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProgressTable,
          UserProgressData,
          $$UserProgressTableFilterComposer,
          $$UserProgressTableOrderingComposer,
          $$UserProgressTableAnnotationComposer,
          $$UserProgressTableCreateCompanionBuilder,
          $$UserProgressTableUpdateCompanionBuilder,
          (UserProgressData, $$UserProgressTableReferences),
          UserProgressData,
          PrefetchHooks Function({bool questionId})
        > {
  $$UserProgressTableTableManager(_$AppDatabase db, $UserProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> questionId = const Value.absent(),
                Value<int> srsStage = const Value.absent(),
                Value<int> mistakeCount = const Value.absent(),
                Value<DateTime?> nextReviewTime = const Value.absent(),
                Value<bool> isLessonCompleted = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
              }) => UserProgressCompanion(
                questionId: questionId,
                srsStage: srsStage,
                mistakeCount: mistakeCount,
                nextReviewTime: nextReviewTime,
                isLessonCompleted: isLessonCompleted,
                isCustom: isCustom,
              ),
          createCompanionCallback:
              ({
                Value<int> questionId = const Value.absent(),
                Value<int> srsStage = const Value.absent(),
                Value<int> mistakeCount = const Value.absent(),
                Value<DateTime?> nextReviewTime = const Value.absent(),
                Value<bool> isLessonCompleted = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
              }) => UserProgressCompanion.insert(
                questionId: questionId,
                srsStage: srsStage,
                mistakeCount: mistakeCount,
                nextReviewTime: nextReviewTime,
                isLessonCompleted: isLessonCompleted,
                isCustom: isCustom,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (questionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.questionId,
                                referencedTable: $$UserProgressTableReferences
                                    ._questionIdTable(db),
                                referencedColumn: $$UserProgressTableReferences
                                    ._questionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProgressTable,
      UserProgressData,
      $$UserProgressTableFilterComposer,
      $$UserProgressTableOrderingComposer,
      $$UserProgressTableAnnotationComposer,
      $$UserProgressTableCreateCompanionBuilder,
      $$UserProgressTableUpdateCompanionBuilder,
      (UserProgressData, $$UserProgressTableReferences),
      UserProgressData,
      PrefetchHooks Function({bool questionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$QuestionsTableTableManager get questions =>
      $$QuestionsTableTableManager(_db, _db.questions);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$QuestionTagsTableTableManager get questionTags =>
      $$QuestionTagsTableTableManager(_db, _db.questionTags);
  $$UserProgressTableTableManager get userProgress =>
      $$UserProgressTableTableManager(_db, _db.userProgress);
}
