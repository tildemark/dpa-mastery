import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../engine/gating_service.dart';
import '../../main.dart';
import '../lessons/lessons_screen.dart';
import '../reviews/reviews_screen.dart';
import '../reviews/review_provider.dart';
import '../drills/tag_drill_screen.dart';
import '../cram/cram_screen.dart';
import '../dlc/dlc_store_screen.dart';
import '../mock_exam/mock_exam_screen.dart';
import '../../services/dlc/dlc_service.dart';
import '../../services/settings_service.dart';
import '../../services/certificate_service.dart';
import '../../services/app_time.dart';
import '../settings/settings_screen.dart';
import '../profile/profile_dialog.dart';
import 'home_providers.dart';
import 'module_mastery_panel.dart';
import 'srs_breakdown_sheet.dart';
import 'srs_explainer_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsServiceProvider);
      if (!settings.hasCompletedOnboarding) {
        ProfileDialog.show(context, isOnboarding: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'DPA Mastery',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: const [
          _HomeAppBarActions(),
        ],
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 0b. Scope Selector Pill Bar ──
              const _ScopeSelectorBar(),
              const SizedBox(height: 14),

              // ── 1. DPO Rank & Certification Profile Card (Dual-Track) ──
              const _ProfileMetricsCard(),
              const SizedBox(height: 18),

              // ── 2. Primary Study Action Cards ──
              const _PrimaryActionCards(),
              const SizedBox(height: 12),

              // ── 3. Cram / Self-Study Quick Banner ──
              const _CramBanner(),
              const SizedBox(height: 12),

              // ── 3b. DPO Certification Mock Exam Simulation Hero Card ──
              const _MockExamCard(),
              const SizedBox(height: 24),

              // ── 4. SRS Stage Distribution Bar ──
              const _SrsDistributionSection(),
              const SizedBox(height: 24),

              // ── 4b. Module Curriculum Mastery ──
              const _ModuleMasterySection(),
              const SizedBox(height: 24),

              // ── 5. Review Forecast (Upcoming Countdowns) ──
              const _ReviewForecastSection(),
              const SizedBox(height: 24),

              // ── 6. Tier Progression (85% Guru Gating) ──
              const _TierProgressionSection(),
              const SizedBox(height: 24),

              // ── 6b. Expansion Packs & DLC Mastery (Dedicated Section) ──
              const _ExpansionPacksSection(),
              const SizedBox(height: 24),

              // ── 7. Missed Questions Review & Weak Areas ──
              const _MissedQuestionsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 0: App Bar Actions
// ─────────────────────────────────────────────────────────────────────────────

class _HomeAppBarActions extends StatelessWidget {
  const _HomeAppBarActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.extension_outlined),
          tooltip: 'Expansion Packs & DLCs',
          onPressed: () => Navigator.of(context).push(DlcStoreScreen.route()),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Study Settings',
          onPressed: () => SettingsSheet.show(context),
        ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          tooltip: 'About & Credits',
          onPressed: () async {
            final packageInfo = await PackageInfo.fromPlatform();
            final versionStr = 'v${packageInfo.version}+${packageInfo.buildNumber}';

            if (!context.mounted) return;

            showAboutDialog(
              context: context,
              applicationName: 'DPA Mastery',
              applicationVersion: versionStr,
              applicationIcon: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                ),
              ),
              applicationLegalese: '© 2026 Alfredo Sanchez Jr.\nAll rights reserved.',
              children: const [
                SizedBox(height: 16),
                Text(
                  'Developer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text('Alfredo Sanchez Jr\nhttps://sanchez.ph'),
                SizedBox(height: 14),
                Text(
                  'Privacy Policy & Offline Guarantee',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  'DPA Mastery is 100% offline. Zero telemetry, zero user tracking, and zero personal data collection. All SRS progress, study history, and question records reside strictly in your local device SQLite database in full compliance with the Data Privacy Act of 2012 (RA 10173).',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
                SizedBox(height: 14),
                Text(
                  'Certification Focus',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  'National Privacy Commission (NPC) Certified DPO (Data Protection Officer) Assessment & Compliance Framework.',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 1: Profile & Exam Readiness Card
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Section 0b: Scope Selector Bar (Core vs DLC vs All)
// ─────────────────────────────────────────────────────────────────────────────

class _ScopeSelectorBar extends ConsumerWidget {
  const _ScopeSelectorBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final currentScope = ref.watch(dashboardScopeProvider);
    final metrics = ref.watch(homeProfileStreamProvider).valueOrNull;
    final dualTrack = metrics?.dualTrack;

    if (dualTrack == null || !dualTrack.hasInstalledDlc) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withAlpha(80)),
      ),
      child: Row(
        children: [
          _buildScopePill(
            context: context,
            ref: ref,
            scope: DashboardScope.all,
            label: 'All Questions (${dualTrack.coreTotal + dualTrack.dlcTotal})',
            icon: Icons.public_rounded,
            isSelected: currentScope == DashboardScope.all,
          ),
          const SizedBox(width: 4),
          _buildScopePill(
            context: context,
            ref: ref,
            scope: DashboardScope.core,
            label: 'Core (${dualTrack.coreTotal})',
            icon: Icons.menu_book_rounded,
            isSelected: currentScope == DashboardScope.core,
          ),
          const SizedBox(width: 4),
          _buildScopePill(
            context: context,
            ref: ref,
            scope: DashboardScope.dlc,
            label: 'DLC (${dualTrack.dlcTotal})',
            icon: Icons.extension_rounded,
            isSelected: currentScope == DashboardScope.dlc,
          ),
        ],
      ),
    );
  }

  Widget _buildScopePill({
    required BuildContext context,
    required WidgetRef ref,
    required DashboardScope scope,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: Material(
        color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => ref.read(dashboardScopeProvider.notifier).state = scope,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 13,
                  color: isSelected ? Colors.white : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 1: Profile & Exam Readiness Card (Dual-Track)
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileMetricsCard extends ConsumerWidget {
  const _ProfileMetricsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsServiceProvider);
    final metrics = ref.watch(homeProfileStreamProvider).valueOrNull;
    final srsCounts = ref.watch(srsStageCountsStreamProvider).valueOrNull;

    final rank = metrics?.rank;
    final readinessResult = metrics?.readiness;
    final readinessScore = readinessResult?.score ?? 0;
    final estimatedTimeStr = readinessResult?.estimatedTimeToReady(settings.dailyTarget) ?? 'Calculating...';
    final dualTrack = metrics?.dualTrack;
    final hasDlc = dualTrack != null && dualTrack.hasInstalledDlc;

    final corePercent = dualTrack != null ? (dualTrack.coreRatio * 100).round() : readinessScore;
    final dlcPercent = dualTrack != null ? (dualTrack.dlcRatio * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E293B),
            cs.surfaceContainerHigh,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF6366F1).withAlpha(90), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF6366F1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Color(0xFF818CF8), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Tier ${rank?.level ?? 1}',
                      style: const TextStyle(
                        color: Color(0xFF818CF8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$readinessScore% Exam Ready',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _showEditNameDialog(context, ref, settings.userName),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      '${settings.userName} • ${rank?.title ?? "Privacy Cadet"}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF818CF8)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Dual-Track Progress Bars ──
          if (hasDlc) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Core Certification Standard',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                ),
                Text(
                  '$corePercent% (${dualTrack.coreGuru}/${dualTrack.coreTotal} Guru+)',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: dualTrack.coreRatio,
                minHeight: 6,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Expansion Packs & Deep Dives',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF818CF8)),
                ),
                Text(
                  '$dlcPercent% (${dualTrack.dlcGuru}/${dualTrack.dlcTotal} Guru+)',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF818CF8)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: dualTrack.dlcRatio,
                minHeight: 6,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF818CF8)),
              ),
            ),
          ] else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: readinessScore / 100,
                minHeight: 6,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: dynamicSize(context),
                  children: [
                    const Icon(Icons.schedule_rounded, size: 13, color: Color(0xFF818CF8)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Est. Ready: $estimatedTimeStr',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF818CF8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${srsCounts?.total ?? 282} Qs Bank',
                style: TextStyle(
                  fontSize: 11,
                  color: cs.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // ── Verifiable Certificate Quick Access ──
          if (ref.watch(sharedPrefsProvider).getBool('dpo_ace_mock_has_passed') == true) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0284C7).withAlpha(100)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded, color: Color(0xFF38BDF8), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DPO ACE Credential Verified',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFF8FAFC)),
                        ),
                        Text(
                          CertificateService.generateSerial(name: settings.userName),
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final serial = CertificateService.generateSerial(name: settings.userName);
                      final url = CertificateService.buildCertificateUrl(name: settings.userName, serial: serial);
                      final uri = Uri.parse(url);
                      try {
                        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                        if (!launched) {
                          await launchUrl(uri, mode: LaunchMode.platformDefault);
                        }
                      } catch (e) {
                        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                      }
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 14, color: Color(0xFF38BDF8)),
                    label: const Text('Certificate', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      backgroundColor: const Color(0xFF0284C7).withAlpha(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName == 'Guest' ? '' : currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.badge_rounded, color: Color(0xFF0284C7)),
            SizedBox(width: 8),
            Text('Official Scholar Name', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your official full name as you would like it to appear on your Philippine Data Privacy Certificate of Mastery and LinkedIn credentials:',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'e.g. Atty. Juan Dela Cruz, CIPM',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref.read(settingsServiceProvider).setUserName(newName);
              }
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
            child: const Text('Save Name'),
          ),
        ],
      ),
    );
  }

  MainAxisSize dynamicSize(BuildContext context) => MainAxisSize.min;
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 2: Primary Study Action Cards (Lessons & Reviews)
// ─────────────────────────────────────────────────────────────────────────────

class _PrimaryActionCards extends ConsumerWidget {
  const _PrimaryActionCards();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsServiceProvider);
    final reviewQueueAsync = ref.watch(reviewQueueProvider);
    final srsCountsAsync = ref.watch(srsStageCountsStreamProvider);
    final nextReviewAsync = ref.watch(nextReviewTimeStreamProvider);

    final counts = srsCountsAsync.valueOrNull;
    final isCountsLoading = srsCountsAsync.isLoading || counts == null;
    final availableLessons = counts != null ? settings.getAvailableLessonsToday(counts.available) : 0;
    final pendingReviewsCount = reviewQueueAsync.asData?.value.length ?? 0;
    final nextTime = nextReviewAsync.asData?.value;

    // Review Gating & Apprentice Cap Logic
    final hasPendingReviews = pendingReviewsCount > 0;
    final isApprenticeCapped = settings.apprenticeCap > 0 &&
        counts != null &&
        counts.apprentice >= settings.apprenticeCap;
    final isLessonThrottled = (hasPendingReviews || isApprenticeCapped) && availableLessons > 0;

    String lessonSubtitle;
    if (isCountsLoading) {
      lessonSubtitle = 'Loading lessons...';
    } else if (hasPendingReviews) {
      lessonSubtitle = 'Complete $pendingReviewsCount reviews first';
    } else if (isApprenticeCapped) {
      lessonSubtitle = 'Apprentice cap reached (${counts.apprentice}/${settings.apprenticeCap})';
    } else if (availableLessons > 0) {
      lessonSubtitle = '$availableLessons available today';
    } else if (counts.available == 0 && counts.learnedTotal == counts.total) {
      lessonSubtitle = 'All lessons completed';
    } else {
      lessonSubtitle = 'Daily quota complete';
    }

    String reviewSubtitle;
    if (reviewQueueAsync.asData != null && reviewQueueAsync.asData!.value.isNotEmpty) {
      reviewSubtitle = '${reviewQueueAsync.asData!.value.length} due now';
    } else if (nextTime != null) {
      final diff = nextTime.difference(AppTime.now());
      if (diff.isNegative) {
        reviewSubtitle = 'Available now';
      } else if (diff.inHours > 0) {
        reviewSubtitle = 'Next in ${diff.inHours}h ${diff.inMinutes % 60}m';
      } else {
        reviewSubtitle = 'Next in ${diff.inMinutes}m';
      }
    } else {
      reviewSubtitle = 'All caught up';
    }

    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            title: 'Lessons',
            subtitle: lessonSubtitle,
            icon: Icons.school_rounded,
            color: const Color(0xFF5E6AD2),
            badgeCount: isLessonThrottled ? 0 : availableLessons,
            isLocked: isLessonThrottled,
            onTap: () async {
              if (hasPendingReviews) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.repeat_rounded, color: Color(0xFF10B981)),
                        SizedBox(width: 10),
                        Text('Reviews Pending'),
                      ],
                    ),
                    content: Text(
                      'You have $pendingReviewsCount review(s) waiting for you! Clearing pending reviews first strengthens memory consolidation and prevents study overload.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Later'),
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).push(ReviewsScreen.route());
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start Reviews'),
                      ),
                    ],
                  ),
                );
                return;
              }

              if (isApprenticeCapped) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Colors.amber),
                        SizedBox(width: 10),
                        Text('Apprentice Cap Reached'),
                      ],
                    ),
                    content: Text(
                      'You currently have ${counts.apprentice} active Apprentice items (limit: ${settings.apprenticeCap}).\n\nTo prevent review overload, advance existing items to Guru (Stage 5+) by completing reviews before unlocking more lessons.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('OK'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          SettingsSheet.show(context);
                        },
                        child: const Text('Adjust Cap'),
                      ),
                    ],
                  ),
                );
                return;
              }

              final db = ref.read(dbProvider);
              final gating = GatingService(db, settings);
              final unlocked = await gating.getUnlockedLevels();
              int targetLevel = unlocked.isNotEmpty ? unlocked.first : 1;
              for (final level in unlocked) {
                final unlearned = await db.questionDao.getUnlearnedQuestions(level);
                if (unlearned.isNotEmpty) {
                  targetLevel = level;
                  break;
                }
              }
              if (context.mounted) {
                Navigator.of(context).push(LessonsScreen.route(targetLevel));
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            title: 'Reviews',
            subtitle: reviewSubtitle,
            icon: Icons.repeat_rounded,
            color: const Color(0xFF10B981),
            badgeCount: pendingReviewsCount,
            onTap: () {
              Navigator.of(context).push(ReviewsScreen.route());
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 3: Cram Mode Banner
// ─────────────────────────────────────────────────────────────────────────────

class _CramBanner extends StatelessWidget {
  const _CramBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF59E0B).withAlpha(90)),
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B), size: 26),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Self-Study / Cram Mode',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 2),
                Text(
                  'Practice cards freely anytime without review timers.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () => CramSetupSheet.show(context),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Configure'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 3b: Mock Exam Card
// ─────────────────────────────────────────────────────────────────────────────

class _MockExamCard extends ConsumerWidget {
  const _MockExamCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final dlcService = ref.watch(dlcServiceProvider);

    final isMockDlcInstalled = dlcService.isDlcInstalled('dlc_mock_exam_simulation');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isMockDlcInstalled
              ? [const Color(0xFF10B981).withAlpha(45), const Color(0xFF059669).withAlpha(20)]
              : [const Color(0xFF0284C7).withAlpha(45), const Color(0xFF0369A1).withAlpha(20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMockDlcInstalled
              ? const Color(0xFF10B981).withAlpha(140)
              : const Color(0xFF0284C7).withAlpha(140),
          width: 1.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isMockDlcInstalled
                  ? const Color(0xFF10B981).withAlpha(40)
                  : const Color(0xFF0284C7).withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMockDlcInstalled
                  ? Icons.verified_rounded
                  : Icons.workspace_premium_rounded,
              color: isMockDlcInstalled
                  ? const Color(0xFF10B981)
                  : const Color(0xFF38BDF8),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'DPO ACE Mock Examination',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isMockDlcInstalled
                            ? const Color(0xFF10B981).withAlpha(30)
                            : const Color(0xFF0284C7).withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isMockDlcInstalled
                              ? const Color(0xFF10B981)
                              : const Color(0xFF0284C7),
                        ),
                      ),
                      child: Text(
                        isMockDlcInstalled ? '150-Q POOL' : 'CORE POOL',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isMockDlcInstalled
                              ? const Color(0xFF10B981)
                              : const Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isMockDlcInstalled
                      ? '50 Random Scenario Qs • 60-min timer • 75% Passing mark'
                      : '50-Question Timed Simulation • Verified Certification',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isMockDlcInstalled
                        ? const Color(0xFF10B981)
                        : const Color(0xFF38BDF8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => Navigator.of(context).push(MockExamScreen.route()),
            style: FilledButton.styleFrom(
              backgroundColor: isMockDlcInstalled ? const Color(0xFF10B981) : const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Start Exam', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 4: SRS Stage Distribution Section
// ─────────────────────────────────────────────────────────────────────────────

class _SrsDistributionSection extends ConsumerWidget {
  const _SrsDistributionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final counts = ref.watch(srsStageCountsStreamProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'SRS Mastery Breakdown',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurfaceVariant,
                      ),
                ),
                IconButton(
                  icon: Icon(Icons.info_outline_rounded, size: 16, color: cs.primary),
                  padding: const EdgeInsets.only(left: 6),
                  constraints: const BoxConstraints(),
                  tooltip: 'How SRS Mastery Works',
                  onPressed: () => SrsExplainerSheet.show(context),
                ),
              ],
            ),
            Text(
              'Tap for details',
              style: TextStyle(
                fontSize: 11,
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SrsStageMetric(
                label: 'Available',
                count: counts?.available ?? 0,
                color: const Color(0xFF64748B),
                icon: Icons.lock_open_rounded,
              ),
              _SrsStageMetric(
                label: 'Apprentice',
                count: counts?.apprentice ?? 0,
                color: const Color(0xFFEF5350),
                icon: Icons.local_fire_department,
              ),
              _SrsStageMetric(
                label: 'Guru',
                count: counts?.guru ?? 0,
                color: const Color(0xFF7C4DFF),
                icon: Icons.auto_awesome,
              ),
              _SrsStageMetric(
                label: 'Master',
                count: counts?.master ?? 0,
                color: const Color(0xFF1565C0),
                icon: Icons.workspace_premium,
              ),
              _SrsStageMetric(
                label: 'Burned',
                count: counts?.burned ?? 0,
                color: const Color(0xFFF59E0B),
                icon: Icons.whatshot,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 4b: Module Curriculum Mastery Section
// ─────────────────────────────────────────────────────────────────────────────

class _ModuleMasterySection extends StatelessWidget {
  const _ModuleMasterySection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Curriculum Mastery by Module',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurfaceVariant,
                      ),
                ),
                IconButton(
                  icon: Icon(Icons.info_outline_rounded, size: 16, color: cs.primary),
                  padding: const EdgeInsets.only(left: 6),
                  constraints: const BoxConstraints(),
                  tooltip: 'Mastery Explanation',
                  onPressed: () => SrsExplainerSheet.show(context),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'NPC DPO exam modules — Active Learning & Mastered (Guru+)',
          style: TextStyle(fontSize: 11, color: cs.outline),
        ),
        const SizedBox(height: 10),
        const ModuleMasteryPanel(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 5: Review Forecast Section
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewForecastSection extends ConsumerWidget {
  const _ReviewForecastSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final forecastAsync = ref.watch(reviewForecastStreamProvider);
    final fc = forecastAsync.asData?.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Review Forecast',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ForecastSlot(label: '+1h', count: fc?.within1h ?? 0),
              _ForecastSlot(label: '+4h', count: fc?.within4h ?? 0),
              _ForecastSlot(label: '+24h', count: fc?.within24h ?? 0),
              _ForecastSlot(label: '+3d', count: fc?.within3d ?? 0),
              _ForecastSlot(label: '+7d', count: fc?.within7d ?? 0),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 6: Tier Progression Section
// ─────────────────────────────────────────────────────────────────────────────

class _TierProgressionSection extends ConsumerWidget {
  const _TierProgressionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tierProgressionAsync = ref.watch(tierProgressionStreamProvider);
    final reviewQueueAsync = ref.watch(reviewQueueProvider);
    final srsCountsAsync = ref.watch(srsStageCountsStreamProvider);
    final settings = ref.watch(settingsServiceProvider);

    final counts = srsCountsAsync.valueOrNull;
    final pendingReviewsCount = reviewQueueAsync.asData?.value.length ?? 0;
    final hasPendingReviews = pendingReviewsCount > 0;
    final isApprenticeCapped = settings.apprenticeCap > 0 &&
        counts != null &&
        counts.apprentice >= settings.apprenticeCap;

    final tierItems = tierProgressionAsync.valueOrNull ??
        List.generate(
          5,
          (i) => TierProgressionItem(
            level: i + 1,
            isUnlocked: i == 0,
            guruRatio: 0.0,
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tier Progression',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 10),
        Column(
          children: tierItems.map((item) {
            final level = item.level;
            final isUnlocked = item.isUnlocked;
            final ratio = item.guruRatio;

            return _LevelProgressTile(
              level: level,
              isUnlocked: isUnlocked,
              ratio: ratio,
              onTap: isUnlocked
                  ? () async {
                      if (hasPendingReviews) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please complete your $pendingReviewsCount pending review(s) before starting Tier $level lessons.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      if (isApprenticeCapped) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Apprentice cap reached (${counts.apprentice}/${settings.apprenticeCap}). Complete reviews first.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      final db = ref.read(dbProvider);
                      final unlearned = await db.questionDao.getUnlearnedQuestions(level);
                      if (unlearned.isEmpty) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('All lessons in Tier $level are already completed!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        return;
                      }
                      if (context.mounted) {
                        Navigator.of(context).push(LessonsScreen.route(level));
                      }
                    }
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 7: Missed Questions Section
// ─────────────────────────────────────────────────────────────────────────────

class _MissedQuestionsSection extends ConsumerWidget {
  const _MissedQuestionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final missedCount = ref.watch(missedQuestionsCountProvider).valueOrNull ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Missed Questions Review',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurfaceVariant,
                  ),
            ),
            if (missedCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEF4444).withAlpha(100)),
                ),
                child: Text(
                  '$missedCount missed',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: missedCount > 0
                  ? const Color(0xFFEF4444).withAlpha(90)
                  : cs.outlineVariant.withAlpha(80),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (missedCount > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  missedCount > 0 ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  color: missedCount > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      missedCount > 0 ? '$missedCount questions need review' : 'No missed questions!',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      missedCount > 0
                          ? 'Drill the exact questions you answered incorrectly during lessons & reviews.'
                          : 'Great comprehension! Keep going through lessons and reviews.',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: missedCount > 0
                    ? () => Navigator.of(context).push(TagDrillScreen.missedQuestionsRoute())
                    : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Review'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 6b: Expansion Packs & DLC Mastery Section
// ─────────────────────────────────────────────────────────────────────────────

class _ExpansionPacksSection extends ConsumerWidget {
  const _ExpansionPacksSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final packsAsync = ref.watch(installedPacksProgressProvider);

    return packsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (installedPacks) {
        if (installedPacks.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Installed Expansion Packs',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurfaceVariant,
                      ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(DlcStoreScreen.route()),
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 14),
                  label: const Text('Store', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final (pack, progress) in installedPacks) ...[
              Builder(
                builder: (context) {
                  final isSimulationPack = pack.id == 'dlc_mock_exam_simulation' || pack.category == 'Exam Simulation';
                  final prefs = ref.watch(sharedPrefsProvider);
                  final hasPassed = prefs.getBool('dpo_ace_mock_has_passed') ?? false;
                  final bestScore = prefs.getDouble('dpo_ace_mock_best_score') ?? 0.0;
                  final attempts = prefs.getInt('dpo_ace_mock_attempts_count') ?? 0;

                  final badgeColor = isSimulationPack
                      ? (hasPassed ? const Color(0xFF10B981) : (attempts > 0 ? const Color(0xFFF59E0B) : const Color(0xFF6366F1)))
                      : const Color(0xFF6366F1);

                  final badgeLabel = isSimulationPack
                      ? (hasPassed
                          ? 'PASSED (${bestScore.toStringAsFixed(0)}%)'
                          : (attempts > 0 ? 'Diagnostic: ${bestScore.toStringAsFixed(0)}%' : 'Ready for Simulation'))
                      : '${progress.percentageLabel} Mastered';

                  final subLabel = isSimulationPack
                      ? (hasPassed
                          ? '🏆 Certified Simulation Credential Earned • $attempts Attempt(s)'
                          : (attempts > 0
                              ? 'Best: ${bestScore.toStringAsFixed(1)}% (Pass threshold: 75%) • $attempts Attempt(s)'
                              : '150 Scenarios Pool • Timed 50-Question Simulation'))
                      : '${progress.guruPlus} Guru+ • ${progress.apprentice} Learning • ${progress.unlearned} Available';

                  final progressRatio = isSimulationPack
                      ? (bestScore / 100.0).clamp(0.0, 1.0)
                      : progress.guruRatio;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: badgeColor.withAlpha(80)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                pack.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: badgeColor.withAlpha(100)),
                              ),
                              child: Text(
                                badgeLabel,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: badgeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subLabel,
                          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progressRatio,
                            minHeight: 5,
                            backgroundColor: cs.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SrsStageMetric extends StatelessWidget {
  const _SrsStageMetric({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        SrsBreakdownSheet.show(
          context,
          stageName: label,
          stageColor: color,
          stageIcon: icon,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForecastSlot extends StatelessWidget {
  const _ForecastSlot({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeCount = 0,
    this.isLocked = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int badgeCount;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isLocked ? Colors.grey : color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: effectiveColor.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: effectiveColor.withAlpha(80), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  isLocked ? Icons.lock_outline_rounded : icon,
                  color: effectiveColor,
                  size: 30,
                ),
                if (badgeCount > 0 && !isLocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: effectiveColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                else if (isLocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Paused',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.grey : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isLocked ? Colors.amber[700] : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isLocked ? FontWeight.w500 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelProgressTile extends StatelessWidget {
  const _LevelProgressTile({
    required this.level,
    required this.isUnlocked,
    required this.ratio,
    this.onTap,
  });

  final int level;
  final bool isUnlocked;
  final double ratio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _levelColor(level);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isUnlocked ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                  color: isUnlocked ? color : cs.outline,
                  size: 20,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tier $level: ${_levelLabel(level)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isUnlocked ? cs.onSurface : cs.outline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 4,
                          backgroundColor: cs.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(ratio * 100).toInt()}% Guru',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? color : cs.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _levelLabel(int l) => switch (l) {
        1 => 'Foundations',
        2 => 'Compliance Practitioner',
        3 => 'Privacy Specialist',
        4 => 'Lead Privacy Architect',
        _ => 'Master DPO',
      };

  Color _levelColor(int l) => switch (l) {
        1 => const Color(0xFF5E6AD2),
        2 => const Color(0xFF0EA5E9),
        3 => const Color(0xFF10B981),
        4 => const Color(0xFFF59E0B),
        _ => const Color(0xFFEF4444),
      };
}
