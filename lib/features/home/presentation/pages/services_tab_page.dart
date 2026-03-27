import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/glass_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/home_settings_provider.dart';

/// Services tab: Service grid (Mantra Notes, Samagam, Patrika, etc.)
class ServicesTabPage extends ConsumerWidget {
  const ServicesTabPage({super.key});

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
                  AppLocalizations.of(context)!.services,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        ref.watch(featureFlagsProvider).when(
              data: (flags) {
                final items = <Widget>[];
                if (flags['feature_mantra_notes_enabled'] ?? true) {
                  items.add(_buildServiceCard(
                    context,
                    AppLocalizations.of(context)!.mantraNotes,
                    AppLocalizations.of(context)!.storeMantras,
                    Icons.menu_book,
                    '/mantra-notes',
                    Colors.deepPurple,
                  ));
                }
                if (flags['feature_samagam_enabled'] ?? true) {
                  items.add(_buildServiceCard(
                    context,
                    AppLocalizations.of(context)!.samagam,
                    AppLocalizations.of(context)!.events,
                    Icons.event_note,
                    '/samagam',
                    Colors.orange,
                  ));
                }
                if (flags['feature_patrika_enabled'] ?? true) {
                  items.add(_buildServiceCard(
                    context,
                    AppLocalizations.of(context)!.patrika,
                    AppLocalizations.of(context)!.monthlyRead,
                    Icons.menu_book,
                    '/patrika',
                    Colors.redAccent,
                  ));
                }
                if (flags['feature_pooja_items_enabled'] ?? true) {
                  items.add(_buildServiceCard(
                    context,
                    AppLocalizations.of(context)!.poojaItems,
                    AppLocalizations.of(context)!.shop,
                    Icons.shopping_bag_outlined,
                    '/pooja-items',
                    Colors.teal,
                  ));
                }
                if (flags['feature_paath_services_enabled'] ?? true) {
                  items.add(_buildServiceCard(
                    context,
                    AppLocalizations.of(context)!.paath,
                    AppLocalizations.of(context)!.services,
                    Icons.volunteer_activism,
                    '/paath-services',
                    Colors.indigoAccent,
                  ));
                }
                if (flags['feature_donation_enabled'] ?? true) {
                  items.add(_buildServiceCard(
                    context,
                    AppLocalizations.of(context)!.donation,
                    AppLocalizations.of(context)!.supportUs,
                    Icons.favorite_border,
                    '/donation',
                    Colors.pinkAccent,
                  ));
                }
                if (flags['feature_social_activities_enabled'] ?? true) {
                  items.add(_buildServiceCard(
                    context,
                    AppLocalizations.of(context)!.socialActivities,
                    AppLocalizations.of(context)!.socialActivitiesSubtitle,
                    Icons.volunteer_activism,
                    '/social-activities',
                    Colors.green,
                  ));
                }
                if (flags['feature_blog_enabled'] ?? true) {
                  items.add(_buildServiceCard(
                    context,
                    AppLocalizations.of(context)!.readBlog,
                    AppLocalizations.of(context)!.readBlogDesc,
                    Icons.article_outlined,
                    '/blog',
                    Colors.brown,
                  ));
                }
                if (flags['feature_bslnd_centers_enabled'] ?? true) {
                  items.add(_buildServiceCard(
                    context,
                    AppLocalizations.of(context)!.bslndCenters,
                    AppLocalizations.of(context)!.bslndCentersDesc,
                    Icons.place_outlined,
                    '/bslnd-centers',
                    Colors.deepOrange,
                  ));
                }
                if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                return SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: items,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(color: AppTheme.primaryGold),
                  ),
                ),
              ),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
    Color accentColor,
  ) {
    return GlassCard(
      onTap: () => context.push(route),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textDim,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
