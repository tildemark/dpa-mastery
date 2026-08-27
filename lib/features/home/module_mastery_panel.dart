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
    final ratio = data.masteryRatio;
    final color = _ringColor(ratio);

    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withAlpha(ratio > 0 ? 100 : 40),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular progress ring
          SizedBox(
            width: 48,
            height: 48,
            child: CustomPaint(
              painter: _RingPainter(
                ratio: ratio,
                color: color,
                trackColor: cs.surfaceContainerHighest,
              ),
              child: Center(
                child: Text(
                  data.masteryLabel,
                  style: TextStyle(
                    fontSize: ratio >= 1.0 ? 11 : 12,
                    fontWeight: FontWeight.w800,
                    color: ratio > 0 ? color : cs.outline,
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              height: 1.15,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Color _ringColor(double ratio) {
    if (ratio >= 1.0) return const Color(0xFF10B981); // complete — green
    if (ratio >= 0.5) return const Color(0xFF5E6AD2); // halfway — indigo
    if (ratio > 0.0) return const Color(0xFFF59E0B); // started — amber
    return const Color(0xFF64748B);                  // not started — slate
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ring Painter
// ─────────────────────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.ratio,
    required this.color,
    required this.trackColor,
  });

  final double ratio;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const strokeWidth = 5.0;
    final radius = math.min(cx, cy) - strokeWidth / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Track arc (background)
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

    if (ratio <= 0) return;

    // Progress arc
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * ratio.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.ratio != ratio || old.color != color || old.trackColor != trackColor;
}
