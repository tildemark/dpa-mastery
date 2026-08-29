import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'module_mastery_provider.dart';

/// Horizontally scrollable row of module mastery cards.
///
/// Shows one card per NPC curriculum module (1–7), each with a circular
/// progress ring and mastery percentage.
class ModuleMasteryPanel extends ConsumerWidget {
  const ModuleMasteryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masteryAsync = ref.watch(moduleMasteryStreamProvider);

    return masteryAsync.when(
      loading: () => const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (modules) {
        if (modules.isEmpty) return const SizedBox.shrink();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              for (int i = 0; i < modules.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                _ModuleCard(data: modules[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single Module Card
// ─────────────────────────────────────────────────────────────────────────────

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.data});

  final ModuleMasteryData data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final masteryRatio = data.masteryRatio;
    final hasStarted = data.startedTotal > 0;
    final primaryColor = _cardAccentColor(data);

    return InkWell(
      onTap: () => _showModuleInspectSheet(context, data),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 112,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withAlpha(hasStarted ? 120 : 40),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular multi-segment progress ring
            SizedBox(
              width: 48,
              height: 48,
              child: CustomPaint(
                painter: _MultiSegmentRingPainter(
                  apprenticeRatio: data.apprenticeRatio,
                  guruRatio: data.guruRatio,
                  masterRatio: data.masterRatio,
                  burnedRatio: data.burnedRatio,
                  apprenticeColor: const Color(0xFFEF5350), // Coral/Red
                  guruColor: const Color(0xFF7C4DFF),       // Purple
                  masterColor: const Color(0xFF1565C0),     // Blue
                  burnedColor: const Color(0xFFF59E0B),     // Gold
                  trackColor: cs.surfaceContainerHighest,
                ),
                child: Center(
                  child: Text(
                    data.masteryLabel,
                    style: TextStyle(
                      fontSize: masteryRatio >= 1.0 ? 11 : 12,
                      fontWeight: FontWeight.w800,
                      color: masteryRatio > 0
                          ? const Color(0xFF10B981)
                          : (data.apprenticeCount > 0 ? const Color(0xFFEF5350) : cs.outline),
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Mod ${data.moduleNumber}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data.shortName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            // Subtitle showing active status
            Text(
              data.apprenticeCount > 0
                  ? '${data.apprenticeCount} learning'
                  : (data.guruPlus > 0 ? '${data.guruPlus} mastered' : '0/${data.total}'),
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                color: data.apprenticeCount > 0
                    ? const Color(0xFFEF5350)
                    : (data.guruPlus > 0 ? const Color(0xFF10B981) : cs.outline),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _cardAccentColor(ModuleMasteryData d) {
    if (d.burnedRatio > 0.5) return const Color(0xFFF59E0B);
    if (d.masterRatio > 0.3) return const Color(0xFF1565C0);
    if (d.guruRatio > 0.0) return const Color(0xFF7C4DFF);
    if (d.apprenticeRatio > 0.0) return const Color(0xFFEF5350);
    return const Color(0xFF64748B);
  }

  void _showModuleInspectSheet(BuildContext context, ModuleMasteryData m) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final cs = Theme.of(context).colorScheme;
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withAlpha(60),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Module ${m.moduleNumber}: ${m.shortName}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${m.name} • ${m.total} Questions Total',
                            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Overall Stats Summary Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat('Mastery', m.masteryLabel, const Color(0xFF10B981)),
                      _buildMiniStat('Mastered', '${m.guruPlus}/${m.total}', const Color(0xFF7C4DFF)),
                      _buildMiniStat('Learning', '${m.apprenticeCount}', const Color(0xFFEF5350)),
                      _buildMiniStat('Unlearned', '${m.availableCount}', const Color(0xFF64748B)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Granular Sub-Stages Progression
                Text(
                  'Granular SRS Stage Breakdown',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Apprentice 1-4 Row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF5350).withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF5350).withAlpha(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.local_fire_department, size: 14, color: Color(0xFFEF5350)),
                          SizedBox(width: 6),
                          Text('Apprentice Stages (Learning)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEF5350))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (int i = 1; i <= 4; i++)
                            Expanded(
                              child: Column(
                                children: [
                                  Text('App $i', style: const TextStyle(fontSize: 10, color: Color(0xFFEF5350))),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${m.subStageCounts[i] ?? 0}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: (m.subStageCounts[i] ?? 0) > 0 ? cs.onSurface : cs.outline,
                                    ),
                                  ),
                                  Text(
                                    i == 1 ? '4h' : (i == 2 ? '8h' : (i == 3 ? '24h' : '48h')),
                                    style: const TextStyle(fontSize: 8.5, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Guru 1-2 & Master & Burned Row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF).withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF7C4DFF).withAlpha(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.workspace_premium, size: 14, color: Color(0xFF7C4DFF)),
                          SizedBox(width: 6),
                          Text('Mastered Stages (Guru, Master, Burned)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStagePill('Guru 1', '${m.subStageCounts[5] ?? 0}', '1 wk', const Color(0xFF7C4DFF), cs),
                          _buildStagePill('Guru 2', '${m.subStageCounts[6] ?? 0}', '2 wk', const Color(0xFF7C4DFF), cs),
                          _buildStagePill('Master', '${m.subStageCounts[7] ?? 0}', '1 mo', const Color(0xFF1565C0), cs),
                          _buildStagePill('Burned', '${m.subStageCounts[8] ?? 0}', 'Perm', const Color(0xFFF59E0B), cs),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStagePill(String label, String count, String interval, Color color, ColorScheme cs) {
    final c = int.tryParse(count) ?? 0;
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: color)),
          const SizedBox(height: 2),
          Text(
            count,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: c > 0 ? cs.onSurface : cs.outline,
            ),
          ),
          Text(interval, style: const TextStyle(fontSize: 8.5, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Multi-Segment Ring Painter (Apprentice, Guru, Master, Burned)
// ─────────────────────────────────────────────────────────────────────────────

class _MultiSegmentRingPainter extends CustomPainter {
  const _MultiSegmentRingPainter({
    required this.apprenticeRatio,
    required this.guruRatio,
    required this.masterRatio,
    required this.burnedRatio,
    required this.apprenticeColor,
    required this.guruColor,
    required this.masterColor,
    required this.burnedColor,
    required this.trackColor,
  });

  final double apprenticeRatio;
  final double guruRatio;
  final double masterRatio;
  final double burnedRatio;
  final Color apprenticeColor;
  final Color guruColor;
  final Color masterColor;
  final Color burnedColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const strokeWidth = 5.0;
    final radius = math.min(cx, cy) - strokeWidth / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // 1. Draw track (background circle)
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    double currentAngle = -math.pi / 2;

    // Helper to draw segment
    void drawSegment(double ratio, Color color) {
      if (ratio <= 0) return;
      final sweep = 2 * math.pi * ratio.clamp(0.0, 1.0);
      canvas.drawArc(
        rect,
        currentAngle,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
      currentAngle += sweep;
    }

    // 2. Burned (Gold)
    drawSegment(burnedRatio, burnedColor);
    // 3. Master (Blue)
    drawSegment(masterRatio, masterColor);
    // 4. Guru (Purple)
    drawSegment(guruRatio, guruColor);
    // 5. Apprentice (Coral/Red)
    drawSegment(apprenticeRatio, apprenticeColor);
  }

  @override
  bool shouldRepaint(_MultiSegmentRingPainter old) =>
      old.apprenticeRatio != apprenticeRatio ||
      old.guruRatio != guruRatio ||
      old.masterRatio != masterRatio ||
      old.burnedRatio != burnedRatio ||
      old.apprenticeColor != apprenticeColor ||
      old.guruColor != guruColor ||
      old.masterColor != masterColor ||
      old.burnedColor != burnedColor ||
      old.trackColor != trackColor;
}
