import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/settings_service.dart';

/// Modal dialog for first-launch onboarding name entry or editing existing profile name.
class ProfileDialog extends ConsumerStatefulWidget {
  const ProfileDialog({
    super.key,
    this.isOnboarding = false,
  });

  final bool isOnboarding;

  static Future<String?> show(BuildContext context, {bool isOnboarding = false}) {
    return showDialog<String>(
      context: context,
      barrierDismissible: !isOnboarding,
      builder: (_) => ProfileDialog(isOnboarding: isOnboarding),
    );
  }

  @override
  ConsumerState<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends ConsumerState<ProfileDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsServiceProvider);
    final initialName = widget.isOnboarding ? '' : (settings.userName == 'Guest' ? '' : settings.userName);
    _controller = TextEditingController(text: initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(String name) async {
    final settings = ref.read(settingsServiceProvider);
    final finalName = name.trim().isEmpty ? 'Guest' : name.trim();
    await settings.setUserName(finalName);
    if (widget.isOnboarding) {
      await settings.setOnboardingCompleted(true);
    }
    if (mounted) {
      Navigator.of(context).pop(finalName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: cs.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_rounded, color: Color(0xFF818CF8), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isOnboarding ? 'Welcome Cadet!' : 'Edit Profile',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.isOnboarding
                            ? 'Enter your name to personalize your DPO journey.'
                            : 'Update your display name.',
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Your Name or Alias',
                hintText: 'e.g. Alfredo, Maria, Alex',
                filled: true,
                fillColor: cs.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.badge_outlined, size: 20),
              ),
              onSubmitted: _submit,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981).withAlpha(80)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, size: 18, color: Color(0xFF10B981)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Zero-Knowledge Privacy Guarantee: Your name is strictly stored on your own device and never transmitted to or collected by any remote server. Only public cryptographic URL parameters are used when you choose to open, share, or verify your certificate.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFE2E8F0),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (widget.isOnboarding)
                  TextButton(
                    onPressed: () => _submit('Guest'),
                    child: Text(
                      'Continue as Guest',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                FilledButton(
                  onPressed: () => _submit(_controller.text),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(widget.isOnboarding ? 'Get Started' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
