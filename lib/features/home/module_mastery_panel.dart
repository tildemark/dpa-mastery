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
        return SizedBox(
          height: 144,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: modules.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _ModuleCard(data: modules[i]),
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
    final learningRatio = data.learningRatio;
    final hasStarted = data.startedTotal > 0;
    final primaryColor = _ringColor(masteryRatio, learningRatio);

    return Container(
      width: 112,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withAlpha(hasStarted ? 100 : 40),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular progress ring (Dual arc: Learning in Coral/Amber, Mastered in Green/Purple)
          SizedBox(
            width: 48,
            height: 48,
            child: CustomPaint(
              painter: _RingPainter(
                masteryRatio: masteryRatio,
                learningRatio: learningRatio,
                masteryColor: const Color(0xFF10B981),
                learningColor: const Color(0xFFEF5350),
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
                        : (learningRatio > 0 ? const Color(0xFFEF5350) : cs.outline),
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
    );
  }

  Color _ringColor(double masteryRatio, double learningRatio) {
    if (masteryRatio >= 1.0) return const Color(0xFF10B981); // complete — green
    if (masteryRatio >= 0.5) return const Color(0xFF7C4DFF); // halfway guru+ — purple
    if (masteryRatio > 0.0) return const Color(0xFF10B981);  // some guru+
    if (learningRatio > 0.0) return const Color(0xFFEF5350); // learning — coral
    return const Color(0xFF64748B);                         // not started — slate
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ring Painter (Supports Mastered Arc + Learning Arc)
// ─────────────────────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.masteryRatio,
    required this.learningRatio,
    required this.masteryColor,
    required this.learningColor,
    required this.trackColor,
  });

  final double masteryRatio;
  final double learningRatio;
  final Color masteryColor;
  final Color learningColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const strokeWidth = 5.0;
    final radius = math.min(cx, cy) - strokeWidth / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // 1. Track arc (background)
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

    // 2. Learning arc (drawn under or starting after mastery)
    if (learningRatio > 0) {
      final startAngle = -math.pi / 2 + (2 * math.pi * masteryRatio.clamp(0.0, 1.0));
      final sweepAngle = 2 * math.pi * learningRatio.clamp(0.0, 1.0 - masteryRatio);
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = learningColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }

    // 3. Mastery arc (Guru+)
    if (masteryRatio > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * masteryRatio.clamp(0.0, 1.0),
        false,
        Paint()
          ..color = masteryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.masteryRatio != masteryRatio ||
      old.learningRatio != learningRatio ||
      old.masteryColor != masteryColor ||
      old.learningColor != learningColor ||
      old.trackColor != trackColor;
}
