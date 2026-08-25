## DPA Mastery: System Architecture & Data Schema (v2.0)

---

### 1. High-Level System Overview

```text
 +-----------------------------------------------------------------------+
 |                     Next.js Static Web & API                          |
 |         (Hosted on GitHub Pages / Tailwind CSS / Shadcn UI)           |
 |         - Exposes `manifest.json` and module `update_vX.json`         |
 +--------------------+------------------------------+-------------------+
                      | (Fetches OTA JSON payloads)  ^ (Submits Suggested
                      v                              |  Questions via API)
 +---------------------------------------------------+-------------------+
 |             Flutter Client (Android, iOS, Windows Desktop)        |
 |  +-----------------------------------------------------------------+  |
 |  |                       Authentication Engine                     |  |
 |  |             Google Sign-In + Cached Local Offline Token         |  |
 |  +-----------------------------------------------------------------+  |
 |  |                         Learning Modes                          |  |
 |  |  +---------------------------+   +---------------------------+  |  |
 |  |  |     Guide / Lessons Mode  |   |       Reviews Mode        |  |  |
 |  |  |  (Gated Difficulty Tiers) |   |    (Spaced Repetition)    |  |  |
 |  |  +-------------+-------------+   +-------------+-------------+  |  |
 |  |                | (Promote to Appr 1)           | (Stage Shifts)|  |
 |  |                +------------->   <-------------+               |  |
 |  +-----------------------------------------------------------------+  |
 |  |                     Drift (SQLite) Persistence                  |  |
 |  |   Questions | Tags | QuestionTags | UserProgress | CustomDecks  |  |
 |  +-----------------------------------------------------------------+  |
 +-----------------------------------------------------------------------+

```

### 2. Difficulty Progression & Content Gating

The app strictly controls the learning curve using a 5-tier system. Users cannot access Level $X+1$ until at least 85% of their Level $X$ questions have reached "Guru" status (Stage 5 or higher).

| Tier Level | Difficulty | Focus Area | Example |
| --- | --- | --- | --- |
| **Level 1** | Basic | Rote Definitions | What is the definition of a Personal Information Processor? |
| **Level 2** | Easy | Core Rules & Distinctions | Differentiating between PI and SPI lawful criteria. |
| **Level 3** | Medium | Single-Concept Application | Applying the 72-hour breach notification rule to an event. |
| **Level 4** | Hard | Multi-Concept Scenarios | Determining liability in cross-border PIP data transfers. |
| **Level 5** | Harder | Edge Cases & Exceptions | Navigating data subject rights exceptions during court proceedings. |

### 3. OTA JSON Structure (Seed Generation)

The Next.js static export handling the OTA JSON payloads can be deployed via GitHub Actions, identical to your existing static site workflows. The JSON schema now strictly enforces the `difficulty_level` integer. Initial seed files are organized within `docs/seeds/`.

```json
{
  "version": 4,
  "release_date": "2026-08-25",
  "module": "Module 7",
  "items": [
    {
      "id": 801,
      "difficulty_level": 4,
      "tags": [
        "Module 7: Data Breach Management",
        "Scenario",
        "PIC Liability"
      ],
      "lesson_concept": "Incident Response within Outsourced Cloud Environments...",
      "question_text": "A tech company developing an offline POS platform suffers a data leak...",
      "options": ["A", "B", "C", "D"],
      "correct_answer": "C",
      "explanation": "..."
    }
  ]
}

```

### 4. Drift Relational Database Schema

The `Questions` table now strictly incorporates the `difficultyLevel` column.

```dart
class Questions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get difficultyLevel => integer().withDefault(const Constant(1))();
  TextColumn get questionText => text()();
  TextColumn get lessonConcept => text()();
  TextColumn get explanation => text()();
  TextColumn get optionsJson => text()(); 
  TextColumn get correctAnswer => text()();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class QuestionTags extends Table {
  IntColumn get questionId => integer().references(Questions, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {questionId, tagId};
}

class UserProgress extends Table {
  IntColumn get questionId => integer().references(Questions, #id)();
  IntColumn get srsStage => integer().withDefault(const Constant(0))(); 
  IntColumn get mistakeCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextReviewTime => dateTime().nullable()();
  BoolColumn get isLessonCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {questionId};
}

```
