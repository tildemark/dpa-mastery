Act as a Principal Mobile & Web Software Architect. Implement the core architecture for "DPA Mastery", an offline-first Flutter application designed for the Philippine NPC Data Privacy Competency Exam.

Key Architectural Requirements:

1. Relational Persistence (Flutter + Drift):
   - Tables: Questions, Tags, QuestionTags (many-to-many), UserProgress.
   - The Questions table must include a `difficultyLevel` (IntColumn, 1-5).
   - UserProgress supports WaniKani tracking: srsStage (0-8), mistakeCount, nextReviewTime, isLessonCompleted, and isCustom.
   - Implement an upsert pipeline using Drift's `insertOrReplace`. When fetching remote JSON from the GitHub Pages static API, update question content, map string arrays to the Tags and QuestionTags tables, and explicitly ensure existing UserProgress records are never overwritten.

2. Progression Engine (Difficulty Tiers & SRS):
   - WaniKani SRS Stages: Stage 0 (Locked). Stages 1-4 (Apprentice: 4h, 8h, 24h, 48h). Stages 5-6 (Guru: 1w, 2w). Stage 7 (Master: 1mo). Stage 8 (Burned).
   - Gating Logic: A user cannot unlock `difficultyLevel` X+1 until at least 85% of `difficultyLevel` X questions are at srsStage >= 5 (Guru).
   - Lessons Mode: Displays `lessonConcept` first, followed by the `questionText`. On success, promote from Stage 0 to Stage 1.
   - Reviews Mode: Queries items where `isLessonCompleted == true` AND `nextReviewTime <= DateTime.now()`. Updates the srsStage and recalculates the next interval upon answer submission.

3. OTA Sync & Dynamic Tagging:
   - Provide a Dart sync service to fetch `manifest.json`. If an update is required, download the corresponding seed files located structurally in `docs/seeds/`.
   - Ensure the query layer allows filtering by flexible text tags (e.g., retrieving all questions tagged 'Scenario' or 'Consent').

Generate the clean, production-ready Dart/Drift code for the database layer, the WaniKani gating and SRS calculation utility, and the sync service.
