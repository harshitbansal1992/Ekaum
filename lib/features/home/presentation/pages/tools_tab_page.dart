import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/glass_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/home_settings_provider.dart';

/// Tools tab: Quick tools (Kundli, Nadi Dosh, Rahu Kaal, Avdhan, Video Satsang)
class ToolsTabPage extends ConsumerWidget {
  const ToolsTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.quickTools,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ref.watch(featureFlagsProvider).when(
                data: (flags) {
                  final items = <Widget>[];
                  if (flags['feature_kundli_lite_enabled'] ?? true) {
                    items.add(_buildToolCard(
                      context,
                      AppLocalizations.of(context)!.kundliLite,
                      AppLocalizations.of(context)!.kundliLiteDescription,
                      Icons.auto_awesome,
                      () => context.push('/kundli-lite'),
                    ));
                  }
                  if (flags['feature_nadi_dosh_enabled'] ?? true) {
                    items.add(_buildToolCard(
                      context,
                      AppLocalizations.of(context)!.nadiDosh,
                      'Check Nadi compatibility',
                      Icons.calculate_outlined,
                      () => context.push('/nadi-dosh-web'),
                    ));
                  }
                  if (flags['feature_rahu_kaal_enabled'] ?? true) {
                    items.add(_buildToolCard(
                      context,
                      AppLocalizations.of(context)!.rahuKaal,
                      'Rahu Kaal, Sandhya Kaal timings',
                      Icons.access_time,
                      () => context.push('/rahu-kaal'),
                    ));
                  }
                  if (flags['feature_avdhan_enabled'] ?? true) {
                    items.add(_buildToolCard(
                      context,
                      AppLocalizations.of(context)!.avdhan,
                      'Spiritual audio content',
                      Icons.headphones,
                      () => context.push('/avdhan'),
                    ));
                  }
                  if (flags['feature_video_satsang_enabled'] ?? true) {
                    items.add(_buildToolCard(
                      context,
                      AppLocalizations.of(context)!.videoSatsang,
                      'YouTube satsang videos',
                      Icons.video_library,
                      () => context.push('/video-satsang'),
                    ));
                  }
                  if (items.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: items,
                    ),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(color: AppTheme.primaryGold),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppTheme.primaryGold, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryGold),
          ],
        ),
      ),
    );
  }
}
