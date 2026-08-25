# DPA Mastery — Feature Status & Implementation Roadmap (TODO)

This document tracks the current implementation status of **DPA Mastery** against the architectural blueprints in [`docs/architecture.md`](file:///c:/code/dpa-mastery/docs/architecture.md) and [`docs/agents.md`](file:///c:/code/dpa-mastery/docs/agents.md).

---

## 📊 Summary of Implementation Progress

| Component Area | Status | Implemented / Total |
| :--- | :---: | :---: |
| **Relational SQLite Database (Drift)** | 🟢 Completed | 5 / 5 |
| **WaniKani SRS Engine & Progression** | 🟢 Completed | 6 / 6 |
| **2-Phase Lesson Flow & Quiz Exams** | 🟢 Completed | 5 / 5 |
| **Daily Lesson Pace & Rollover Quota** | 🟢 Completed | 4 / 4 |
| **Targeted Drilling & Cram/Self-Study** | 🟢 Completed | 5 / 5 |
| **Static OTA Content & Seed Bundling** | 🟢 Completed | 4 / 4 |
| **Question Suggestion API & Custom Decks** | 🟡 Pending / In Backlog | 0 / 2 |
| **Cloud Sync & Optional Auth (if planned)** | ⚪ Deferred (Offline-First) | 0 / 2 |

---

## ✅ Implemented Features

### 1. Relational Persistence (`Drift / SQLite`)
- [x] **Questions Table**: Stores `id`, `difficultyLevel` (1–5), `questionText`, `lessonConcept`, `explanation`, `optionsJson`, `correctAnswer`.
- [x] **Tags & QuestionTags Tables**: Many-to-many tag relations for module, category, and concept filtering.
- [x] **UserProgress Table**: Stores `srsStage` (0–8), `mistakeCount`, `nextReviewTime`, `isLessonCompleted`, and `isCustom`.
- [x] **Non-Destructive Upsert Pipeline**: Updates question content without overwriting existing user SRS study progress.
- [x] **Live Reactive Streams**: StreamProviders for 5-stage SRS distribution (`srsStageCountsStreamProvider`), review countdown timers, and review forecast buckets (`+1h`, `+4h`, `+24h`, `+3d`, `+7d`).

### 2. WaniKani SRS & Progression Engine
- [x] **8-Stage SRS Model**:
  - `Stage 0`: Locked
  - `Stages 1–4`: Apprentice (4h $\rightarrow$ 8h $\rightarrow$ 24h $\rightarrow$ 48h)
  - `Stages 5–6`: Guru (1 week $\rightarrow$ 2 weeks)
  - `Stage 7`: Master (30 days)
  - `Stage 8`: Burned (Permanent mastery)
- [x] **Penalty & Demotion Logic**:
  - Apprentice penalty: Drop 1 stage (cannot drop below Apprentice 1).
  - Guru penalty: Drop to Apprentice 1.
  - Master penalty: Drop to Guru 1.
- [x] **85% Guru Gating Progression**: Level $X+1$ unlocks strictly when $\ge 85\%$ of Level $X$ questions reach Guru status (Stage $\ge 5$).
- [x] **DPO Certification Rank Scoring**: Dynamic titles from Level 1 (*Privacy Cadet*) to Level 5 (*Senior Privacy Officer / DPO Expert*) with exam-readiness scoring.

### 3. Learning & Review Modes
- [x] **2-Phase Lesson Flow**:
  - **Phase 1**: Sequential concept walkthroughs.
  - **Phase 2**: Post-lesson exam quiz with direct questions, randomized question order, and shuffled MCQ choices (zero concept hints).
- [x] **Strict SRS Promotion**: Cards are promoted to Stage 1 (Apprentice 1) only upon passing the Phase 2 Quiz Exam.
- [x] **Review Mistake Concept Recap**: Displays the original foundational lesson card in review feedback when a question is missed, allowing immediate re-study.
- [x] **Customizable Self-Study / Cram Mode (Adventure Mode)**:
  - Filter by Module (1–7), Difficulty Level (1–5), Topic tags, or Troubled cards (cards with mistakes).
  - Shuffled option choices with random entropy.

### 4. Daily Pace & Quota Settings
- [x] **Daily Lesson Target**: Configurable in Settings (5, 10, 15, 20, or Unlimited per day).
- [x] **Accumulation Rollover**: Unused daily quota accumulates every day for catch-up sessions.
- [x] **Home Dashboard Indicator**: Shows real-time available lessons badge (`"X available today"`).
- [x] **Option Randomization Toggle**: Switch in settings to enable/disable choice shuffling.

### 5. Content & Developer Transparency
- [x] **Bundled Seeds (92 Questions)**: All 10 JSON files (Module 1 through Module 7 + Practice Quizzes) bundled and loaded on cold start.
- [x] **Developer & Credits**: In-app About dialog and README credits for Alfredo Sanchez Jr (`https://sanchez.ph`).
- [x] **100% Offline Privacy Guarantee**: Documented zero-data-collection policy in-app and in `README.md`.

---

## 📝 Unimplemented / Backlog Features (TODO)

### 1. `CustomDecks` Table & User Custom Flashcards
- [ ] **Custom Decks Schema**: `CustomDecks` table mentioned in `architecture.md` diagram for user-created custom cards and decks.
- [ ] **Custom Card Editor UI**: Allow users to create custom flashcards and tag them with `isCustom: true`.
- [ ] **Custom Deck Study Mode**: Interface to browse and cram user-created custom decks alongside official NPC seeds.

### 2. Question Suggestion API (Web / Next.js)
- [ ] **API Endpoint**: Next.js API route `/api/suggest-question` to allow community submission of new DPA exam scenario questions.
- [ ] **Review Dashboard**: Lightweight admin/review interface on the Next.js web portal to review, approve, and export submitted questions into `docs/seeds/`.

### 3. Cloud Sync & Account Linking (Optional / Post-V1)
> *Note: Currently deferred to maintain the 100% Offline Privacy Guarantee.*
- [ ] **Optional Google Sign-In / Token Auth**: Sync progress across multiple devices (e.g. Phone $\leftrightarrow$ Desktop) for users who opt in.
- [ ] **Encrypted Backup & Restore**: Local SQLite export/import file (JSON/DB backup) so users can transfer progress without cloud accounts.

### 4. Audio / Text-to-Speech (TTS) for Rote Concepts (Enhancement)
- [ ] Read statutory definitions and legal concepts aloud during Phase 1 Lesson Walkthroughs.

---

*Last Updated: 2026-08-26*
