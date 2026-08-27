import 'package:flutter/material.dart';

/// Full-screen animated dialog shown when the user unlocks a new tier.
///
/// Triggered from [LessonSummaryScreen] or [LessonsScreen] after a batch
/// completion that caused a tier gate to open.
class TierUnlockDialog extends StatefulWidget {
  const TierUnlockDialog({
    super.key,
    required this.newTierNumber,
    required this.newTierName,
  });

  final int newTierNumber;
  final String newTierName;

  /// Convenience method to show the dialog.
  static Future<void> show(
    BuildContext context, {
    required int newTierNumber,
    required String newTierName,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TierUnlockDialog(
        newTierNumber: newTierNumber,
        newTierName: newTierName,
      ),
    );
  }

  @override
  State<TierUnlockDialog> createState() => _TierUnlockDialogState();
}

class _TierUnlockDialogState extends State<TierUnlockDialog>
    with TickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeIn);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _scaleCtrl.forward();
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color _tierColor(int t) => switch (t) {
        1 => const Color(0xFF5E6AD2),
        2 => const Color(0xFF0EA5E9),
        3 => const Color(0xFF10B981),
        4 => const Color(0xFFF59E0B),
        _ => const Color(0xFFEF4444),
      };

  @override
  Widget build(BuildContext context) {
    final color = _tierColor(widget.newTierNumber);
    final cs = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: color.withAlpha(120), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(60),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing badge
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, child) => Transform.scale(
                  scale: _pulseAnim.value,
                  child: child,
                ),
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [color.withAlpha(200), color.withAlpha(60)],
                      ),
                      border: Border.all(color: color, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: color.withAlpha(80),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'T${widget.newTierNumber}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // "Tier Unlocked!" heading
              Text(
                'Tier ${widget.newTierNumber} Unlocked!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.newTierName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You\'ve mastered 85% of the previous tier!\nNew questions are now available in your lessons.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Continue Studying',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
