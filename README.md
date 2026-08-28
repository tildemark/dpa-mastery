# DPA Mastery 🇵🇭

**DPA Mastery** is an offline-first mobile application designed to help privacy professionals, compliance officers, and aspiring Data Protection Officers (DPOs) prepare for the **Philippine National Privacy Commission (NPC) Data Privacy Competency Examination**.

Built using **Flutter**, **Drift (SQLite)**, and **Riverpod**, the app integrates an **8-Stage Spaced Repetition System (SRS)** with a **Difficulty Tier Gating Engine** to ensure comprehensive understanding and long-term retention of Republic Act No. 10173 (The Data Privacy Act of 2012), its IRR, and NPC issuances.

---

## 🚀 Key Features

- **8-Stage Spaced Repetition System (SRS)**:
  - Progression across 9 stages: `Locked (0)` $\rightarrow$ `Apprentice I–IV (1–4)` $\rightarrow$ `Guru I–II (5–6)` $\rightarrow$ `Master (7)` $\rightarrow$ `Burned (8)`.
  - Realistic review intervals: `4h`, `8h`, `24h`, `48h`, `1w`, `2w`, and `1mo`.
  - Strict penalty structure: Incorrect answers demote Guru items to Apprentice I and Master items to Guru I.
- **Reviews-First Gating & Apprentice Cap**:
  - Gated lesson flow requiring pending reviews to be cleared first.
  - Configurable Apprentice capacity (default 50 items) to prevent study overload.
- **Difficulty Gating Engine (85% Guru Rule)**:
  - Progression spans 5 difficulty tiers (from foundational definitions to complex multi-concept scenarios and legal edge cases).
  - Tier $X+1$ unlocks only when at least **85%** of items in Tier $X$ reach **Guru status (Stage 5+)**.
- **2-Phase Guided Lessons & Review Modes**:
  - **Phase 1 (Learning)**: Sequential concept walkthroughs with high-yield study cards.
  - **Phase 2 (Exam)**: Direct question exam with shuffled options and randomized order (promotes to Apprentice 1 upon passing).
- **Targeted Self-Study & Tag Drills**:
  - Practice specific NPC exam topics (e.g., *Scope of DPA*, *Consent*, *Statutory Exclusions*, *Data Breach Management*) without impacting your SRS review schedule.
- **Hybrid Seed & Over-The-Air (OTA) Sync**:
  - Offline-first SQLite database pre-loaded with canonical NPC question seeds (10 modules / batches).
  - Background OTA sync fetches newly updated questions and jurisprudence revisions without overwriting user study progress.

---

## 🏛️ System Architecture

```
dpa-mastery/
├── lib/
│   ├── db/                     # Drift SQLite database & DAOs
│   │   ├── tables.dart         # Questions, Tags, QuestionTags, UserProgress
│   │   ├── app_database.dart   # @DriftDatabase configuration & connection
│   │   └── daos/               # QuestionDao & ProgressDao (safe upsert pipelines)
│   ├── engine/                 # Pure Dart SRS & gating engines
│   │   ├── srs_engine.dart     # 8-Stage SRS state machine & penalty rules
│   │   └── gating_service.dart # 85% Guru progression threshold logic
│   ├── features/               # Presentation & UI layer
│   │   ├── home/               # Dashboard with SRS distribution bar & quick actions
│   │   ├── lessons/            # 2-Phase lesson flow (Concept -> Exam -> Summary)
│   │   ├── reviews/            # Review session flow & post-session breakdown
│   │   ├── drills/             # Tag-filtered drill mode & cram engine
│   │   └── settings/           # Daily pace, Apprentice cap, & profile preferences
│   ├── services/               # Seed loader, OTA sync, & rank service
│   └── main.dart               # Bootstrap & Riverpod ProviderScope setup
├── assets/seeds/               # Bundled canonical JSON seeds for instant offline launch
├── docs/seeds/                 # Seed backup registry
├── web/                        # Next.js static marketing landing page & OTA seed API
└── test/                       # Unit & widget test suites (25 tests passing)
```

---

## 🛠️ Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.12+ recommended)
- Android Studio / Xcode for device emulation
- Node.js (v20+) if building the static OTA web export

### 1. Clone & Install Dependencies

```bash
git clone https://github.com/tildemark/dpa-mastery.git
cd dpa-mastery
flutter pub get
```

### 2. Run Code Generation (Drift)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run Tests

```bash
flutter test
```

### 4. Launch the Flutter App (Debug / Development)

**On Android device / emulator:**

```bash
flutter run
```

**On Windows Desktop:**

```bash
# Ensure Windows runner is enabled (done once):
flutter create --platforms=windows .

# Run on Windows:
flutter run -d windows
```

### 5. Build for Production & Code Signing

#### 📦 Compiled Release Binary Locations (Local Workspace)

| Platform | Target Output File | Local Workspace Path |
| :--- | :--- | :--- |
| **Android (APK)** | Signed Release APK | [`build/app/outputs/flutter-apk/app-release.apk`](file:///c:/code/dpa-mastery/build/app/outputs/flutter-apk/app-release.apk) |
| **Windows (Portable ZIP)** | Standalone Portable ZIP | [`build/dpa_mastery_windows_x64.zip`](file:///c:/code/dpa-mastery/build/dpa_mastery_windows_x64.zip) |
| **Windows (Installer)** | Inno Setup Installer | [`build/dpa_mastery_windows_setup_v1.4.0.exe`](file:///c:/code/dpa-mastery/build) |

---

### Step-by-Step Release Packaging & Signing Guide

#### 📱 1. Android Release APK (Signed Production Keystore)

To avoid "Blocked by Play Protect" or "Unknown app" security warnings on Android, the APK is signed with a release keystore:

1. **One-time Keystore Generation (if setting up on a new PC):**

   ```powershell
   keytool -genkey -v -keystore android\app\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Local Keystore Properties Configuration:**
   Create or verify `android/key.properties` (ignored by Git for security):

   ```properties
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEYSTORE_PASSWORD
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

3. **Build Signed Release APK:**

   ```bash
   flutter build apk --release
   ```

   - **Output Location:** `build/app/outputs/flutter-apk/app-release.apk`
   - *Note: If `android/key.properties` is absent, Gradle automatically falls back to debug signing.*

---

#### 🪟 2. Windows Desktop (Release & Code Signing)

To eliminate Windows SmartScreen ("Windows protected your PC") warnings:

##### Option A: Portable Standalone ZIP (No Admin Required)

```powershell
# 1. Compile native 64-bit Windows release binary:
flutter build windows --release

# 2. Package release folder into a portable standalone .zip:
Compress-Archive -Path build\windows\x64\runner\Release\* -DestinationPath build\dpa_mastery_windows_x64.zip -Force
```

##### Option B: Inno Setup Windows Installer

```powershell
# Compile installer (.exe):
iscc installer.iss
# Output: build/dpa_mastery_windows_setup_v1.4.1.exe
```

##### Option C: Automated Open-Source Code Signing via SignPath.io

1. DPA Mastery uses **[SignPath Foundation](https://signpath.org/apply.html)** for free open-source OV code signing.
2. In GitHub repository secrets, configure:
   - `SIGNPATH_API_TOKEN`
   - `SIGNPATH_ORGANIZATION_ID`
   - `SIGNPATH_PROJECT_SLUG`
   - `SIGNPATH_SIGNING_POLICY_SLUG`
3. Pushing a tag (e.g. `git tag v1.4.0 && git push origin v1.4.0`) automatically builds, signs, and attaches both the signed Windows installer and portable zip to GitHub Releases via `.github/workflows/release-windows.yml`.

---

> **Note on iOS Builds:** Apple requires macOS and Xcode to compile iOS bundles (`.ipa`). On Windows, Android and Windows binaries compile natively. To compile for iOS, run `flutter build ipa --no-codesign` on a Mac or use a macOS GitHub Actions workflow.

---

## 🌐 Static Seed API (Next.js Hub)

To test and build the static OTA repository:

```bash
cd web
npm install
npm run build # Exports static site to /web/out
```

GitHub Actions automatically builds and deploys changes on the `main` branch to **GitHub Pages** via [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml).

---

## 📋 NPC Exam Modules Covered

| Module | Title | Primary Focus |
| :---: | :--- | :--- |
| **1** | **General Provisions & Framework** | Scope of DPA, Constitutional Privacy Rights, NPC Mandate, Statutory Exclusions |
| **2** | **Key Concepts & Definitions** | PI vs. SPI, PIC vs. PIP, Privileged Info, Accountability Principle |
| **3** | **General Data Privacy Principles** | Transparency, Legitimate Purpose, and Proportionality in Practice |
| **4** | **Lawful Processing Criteria** | Sections 12 & 13 criteria, Consent requirements, Legitimate Interest tests |
| **5** | **Data Subject Rights** | Rights to be Informed, Access, Object, Erasure/Blocking, Damages, Portability |
| **6** | **Accountability & Penalties** | DPO role, Security Measures (Physical/Tech/Org), Criminal & Administrative Liabilities |
| **7** | **Data Breach Management** | Incident response, 72-Hour mandatory NPC notification criteria, containment |

---

## 🔧 Troubleshooting

### ADB Device Not Detected / SuperDisplay USB Conflict

If running `adb devices` shows an empty list or your device is hijacked by third-party display apps (e.g., **SuperDisplay**, Spacedesk):

1. **Stop / Uninstall Host PC Display Services**:
   SuperDisplay installs a Windows Background Service and virtual USB driver that intercepts the device connection before standard ADB can bind to it.

   ```powershell
   # In an Administrator PowerShell terminal:
   Stop-Service SuperDisplay
   Set-Service SuperDisplay -StartupType Disabled
   ```

   *(Or uninstall SuperDisplay from Windows Settings $\rightarrow$ Installed Apps).*

2. **Clear Phone Default USB Action**:
   - On your Android device, go to **Settings** $\rightarrow$ **Apps** $\rightarrow$ **Default Apps**.
   - Clear defaults for any USB accessory prompt.

3. **Reset USB Debugging**:
   - On the phone: **Developer Options** $\rightarrow$ **Revoke USB debugging authorizations**.
   - Toggle **USB Debugging** OFF and back ON.
   - Reconnect the USB cable and restart ADB:

     ```bash
     adb kill-server
     adb start-server
     adb devices
     ```

   - Accept the **"Always allow from this computer"** RSA fingerprint prompt on your phone screen until status reads `device`.

---

## 👨‍💻 Developer & Credits

- **Developer**: Alfredo Sanchez Jr
- **Website**: [https://sanchez.ph](https://sanchez.ph)
- **Project**: DPA Mastery — Offline-First SRS Study Platform for the Philippine NPC DPO Examination.

---

## 🛡️ Privacy Policy (100% Offline Guarantee)

**DPA Mastery is strictly 100% offline.**

- **Zero Personal Data Collection**: No telemetry, analytics, tracking, or device identifiers are collected.
- **Local Storage Only**: All flashcard mastery progress, study statistics, and review timestamps reside exclusively on your device in a local SQLite database (`drift`).
- **Privacy by Design**: Built in full compliance with the Data Privacy Act of 2012 (Republic Act No. 10173).

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
