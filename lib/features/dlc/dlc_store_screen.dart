import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/dlc/dlc_model.dart';
import '../../services/dlc/dlc_service.dart';

class DlcStoreScreen extends ConsumerStatefulWidget {
  const DlcStoreScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
        builder: (_) => const DlcStoreScreen(),
      );

  @override
  ConsumerState<DlcStoreScreen> createState() => _DlcStoreScreenState();
}

class _DlcStoreScreenState extends ConsumerState<DlcStoreScreen> {
  String? _installingPackId;

  Future<void> _handleInstall(DlcPack pack) async {
    setState(() => _installingPackId = pack.id);
    final service = ref.read(dlcServiceProvider);
    final success = await service.installPack(pack);

    if (mounted) {
      setState(() => _installingPackId = null);
      ref.invalidate(availableDlcListProvider);
      ref.invalidate(installedDlcListProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Successfully installed ${pack.title} (${pack.totalQuestions} Questions)!'
                : 'Failed to install ${pack.title}. Please check storage.',
          ),
          backgroundColor: success ? const Color(0xFF10B981) : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleUninstall(DlcPack pack) async {
    final service = ref.read(dlcServiceProvider);
    await service.uninstallPack(pack.id);
    ref.invalidate(availableDlcListProvider);
    ref.invalidate(installedDlcListProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deactivated ${pack.title}.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final availableAsync = ref.watch(availableDlcListProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Expansion Packs & DLCs'),
        centerTitle: true,
      ),
      body: availableAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading DLC catalog: $err')),
        data: (packs) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primaryContainer, cs.secondaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.extension_rounded, size: 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Expansion Hub',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Install specialized question sets and mock simulations without affecting existing progress.',
                            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Available Content Packs (${packs.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ...packs.map((pack) {
                final isInstalling = _installingPackId == pack.id;

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: pack.isInstalled ? cs.primary.withAlpha(120) : cs.outlineVariant.withAlpha(80),
                      width: pack.isInstalled ? 1.5 : 1,
                    ),
                  ),
                  color: cs.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: pack.isInstalled
                                    ? const Color(0xFF10B981).withAlpha(40)
                                    : cs.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                pack.badge,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: pack.isInstalled ? const Color(0xFF10B981) : cs.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (pack.isInstalled)
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Installed',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                                  ),
                                ],
                              )
                            else if (!pack.isAvailable)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withAlpha(40),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey.withAlpha(80)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.schedule_rounded, size: 13, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      pack.statusNote,
                                      style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          pack.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          pack.description,
                          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant, height: 1.4),
                        ),
                        const SizedBox(height: 14),

                        // Stats bar
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.quiz_outlined, size: 14, color: cs.outline),
                                const SizedBox(width: 4),
                                Text('${pack.totalQuestions} Questions', style: TextStyle(fontSize: 12, color: cs.outline)),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.data_usage_rounded, size: 14, color: cs.outline),
                                const SizedBox(width: 4),
                                Text(pack.estimatedSize, style: TextStyle(fontSize: 12, color: cs.outline)),
                              ],
                            ),
                            Text(
                              'by ${pack.author}',
                              style: TextStyle(fontSize: 11, color: cs.outline, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Action buttons
                        Row(
                          children: [
                            if (pack.isInstalled) ...[
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _handleUninstall(pack),
                                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                                  label: const Text('Deactivate'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: cs.error,
                                    side: BorderSide(color: cs.error.withAlpha(120)),
                                  ),
                                ),
                              ),
                            ] else if (!pack.isAvailable) ...[
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: null, // Disabled / greyed out
                                  icon: const Icon(Icons.hourglass_empty_rounded, size: 18),
                                  label: const Text('Coming Soon'),
                                  style: OutlinedButton.styleFrom(
                                    disabledForegroundColor: Colors.grey.withAlpha(180),
                                    side: BorderSide(color: Colors.grey.withAlpha(80)),
                                  ),
                                ),
                              ),
                            ] else ...[
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: isInstalling ? null : () => _handleInstall(pack),
                                  icon: isInstalling
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Icon(Icons.download_rounded),
                                  label: Text(isInstalling ? 'Installing Pack...' : 'Install Expansion Pack'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
