import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/components/glass_card.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../avdhan/data/models/avdhan_audio.dart';
import '../../../patrika/data/models/patrika_issue.dart';
import '../../../video_satsang/data/models/video_satsang_item.dart';
import '../providers/home_settings_provider.dart';
import '../providers/favourites_provider.dart';
import '../../data/models/favourite_item.dart';
import 'more_tab_page.dart';

/// Home tab: Favourites first, then hero, panchang, daily ekaum, announcements, upcoming samagams
class HomeTabPage extends ConsumerWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final theme = Theme.of(context);
    final favourites = ref.watch(favouritesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(homeHeroTextProvider);
        ref.invalidate(dailyEkaumProvider);
        ref.invalidate(panchangProvider);
        ref.invalidate(featureFlagsProvider);
        ref.invalidate(upcomingSamagamsProvider);
        ref.invalidate(announcementsProvider);
        await Future.wait([
          ref.read(homeHeroTextProvider.future),
          ref.read(dailyEkaumProvider.future),
          ref.read(panchangProvider.future),
          ref.read(featureFlagsProvider.future),
          ref.read(upcomingSamagamsProvider.future),
          ref.read(announcementsProvider.future),
        ]);
      },
      color: AppTheme.primaryGold,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildHeader(context, ref, user, theme),
          _buildFavouritesSection(context, ref, favourites, theme),
          _buildHeroSection(context, ref, theme),
          _buildPanchangSection(context, ref, theme),
          _buildDailyEkaumSection(context, ref, theme),
          _buildAnnouncementsSection(context, ref, theme),
          _buildUpcomingSamagamsSection(context, ref, theme),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, user, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.namoNarayan,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.primaryGold,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.name ?? AppLocalizations.of(context)!.devotee,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassCard(
                  borderRadius: 50,
                  padding: const EdgeInsets.all(8),
                  onTap: () => context.push('/search'),
                  child: const Icon(Icons.search, color: AppTheme.primaryGold),
                ),
                const SizedBox(width: 8),
                GlassCard(
                  borderRadius: 50,
                  padding: const EdgeInsets.all(8),
                  onTap: () => MoreTabPage.showProfileDialog(context, ref),
                  child: const Icon(Icons.person_outline, color: AppTheme.primaryGold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavouritesSection(
    BuildContext context,
    WidgetRef ref,
    List<FavouriteItem> favourites,
    ThemeData theme,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: AppTheme.primaryGold, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.favourites,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.titleGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (favourites.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    AppLocalizations.of(context)!.addFavouritesHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textDim,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                ...favourites.map((f) => _FavouriteCard(
                    item: f,
                    theme: theme,
                    onTap: () => _navigateToFavourite(context, f),
                    onRemove: () => ref.read(favouritesProvider.notifier).remove(f.type, f.id),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToFavourite(BuildContext context, FavouriteItem f) {
    switch (f.type) {
      case 'avdhan':
        final extra = f.extra;
        if (extra != null) {
          final audio = AvdhanAudio.fromJson(extra);
          context.push('/avdhan/${f.id}', extra: audio);
        }
        break;
      case 'video_satsang':
        final extra = f.extra;
        if (extra != null) {
          final video = VideoSatsangItem.fromJson(extra);
          context.push('/video-satsang/${f.id}', extra: video);
        }
        break;
      case 'patrika':
        final extra = f.extra;
        if (extra != null) {
          final issue = PatrikaIssue.fromJson(extra);
          context.push('/patrika/${f.id}', extra: issue);
        }
        break;
      case 'samagam':
        context.push('/samagam');
        break;
      case 'tool':
        final route = f.extra?['route'] as String?;
        if (route != null) context.push(route);
        break;
    }
  }

  Widget _buildHeroSection(BuildContext context, WidgetRef ref, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: AppTheme.primaryGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.shreeMykhanaJi,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.titleGold,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.auto_awesome, color: AppTheme.primaryGold, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              ref.watch(homeHeroTextProvider).when(
                    data: (text) => Text(
                      text,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.8,
                      ),
                    ),
                    loading: () => Text(
                      kDefaultHeroText,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.8,
                      ),
                    ),
                    error: (_, __) => Text(
                      kDefaultHeroText,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.8,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanchangSection(BuildContext context, WidgetRef ref, ThemeData theme) {
    return SliverToBoxAdapter(
      child: ref.watch(featureFlagsProvider).when(
            data: (flags) {
              if (flags['feature_panchang_enabled'] != true) return const SizedBox.shrink();
              return ref.watch(panchangProvider).when(
                    data: (panchang) {
                      if (panchang == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: _buildPanchangCard(context, panchang, theme),
                      );
                    },
                    loading: () => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGold),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.loadingPanchang,
                                style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textDim),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
    );
  }

  Widget _buildPanchangCard(BuildContext context, Map<String, dynamic> panchang, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final angas = panchang['angas'] as Map<String, dynamic>?;
    final paksha = panchang['paksha'] as Map<String, dynamic>?;
    final saka = panchang['saka_era_calendar_date'] as Map<String, dynamic>?;

    String? tithiName, nakshatraName, varaName;
    if (angas != null) {
      final tithis = angas['tithis'] as List?;
      if (tithis != null && tithis.isNotEmpty) {
        final t = tithis[0] as Map<String, dynamic>?;
        tithiName = (t?['localized_name'] ?? t?['name']) as String?;
      }
      final nakshatras = angas['nakshatras'] as List?;
      if (nakshatras != null && nakshatras.isNotEmpty) {
        final n = nakshatras[0] as Map<String, dynamic>?;
        nakshatraName = (n?['localized_name'] ?? n?['name']) as String?;
      }
      final vara = angas['vara'] as Map<String, dynamic>?;
      varaName = (vara?['localized_name'] ?? vara?['name']) as String?;
    }
    final pakshaName = (paksha?['localized_name'] ?? paksha?['name']) as String?;

    String sakaStr = '';
    if (saka != null) {
      final d = saka['day'] as Map?;
      final m = saka['month'] as Map?;
      final y = saka['year'] as Map?;
      if (d?['number'] != null && m?['name'] != null && y?['number'] != null) {
        sakaStr = '${d!['number']} ${m!['name']} ${y!['number']}';
      }
    }

    final rows = <List<String>>[];
    if (tithiName != null) rows.add([l10n.tithi, tithiName]);
    if (nakshatraName != null) rows.add([l10n.nakshatra, nakshatraName]);
    if (varaName != null) rows.add([l10n.vara, varaName]);
    if (pakshaName != null) rows.add([l10n.paksha, pakshaName]);
    if (sakaStr.isNotEmpty) rows.add(['Saka Era', sakaStr]);
    if (rows.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: AppTheme.primaryGold, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.todaysPanchang,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.titleGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.hinduCalendar,
                      style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(row[0], style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim)),
                    ),
                    Expanded(
                      child: Text(
                        row[1],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDailyEkaumSection(BuildContext context, WidgetRef ref, ThemeData theme) {
    return SliverToBoxAdapter(
      child: ref.watch(featureFlagsProvider).when(
            data: (flags) {
              if (flags['feature_daily_ekaum_enabled'] != true) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ref.watch(dailyEkaumProvider).when(
                      data: (dailyEkaum) {
                        if (dailyEkaum == null) return const SizedBox.shrink();
                        return _DailyEkaumRevealCard(dailyEkaum: dailyEkaum, theme: theme);
                      },
                      loading: () => GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGold),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.loadingDailyPassword,
                                style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textDim),
                              ),
                            ),
                          ],
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
    );
  }

  Widget _buildAnnouncementsSection(BuildContext context, WidgetRef ref, ThemeData theme) {
    return SliverToBoxAdapter(
      child: ref.watch(featureFlagsProvider).when(
            data: (flags) {
              if (flags['feature_announcements_enabled'] != true) return const SizedBox.shrink();
              return ref.watch(announcementsProvider).when(
                    data: (announcements) {
                      if (announcements.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.campaign, color: AppTheme.primaryGold, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!.visheshSandesh,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: AppTheme.titleGold,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...announcements.map((a) {
                                final json = a as Map<String, dynamic>;
                                return _VisheshSandeshCard(
                                  title: json['title'] as String? ?? '',
                                  description: json['description'] as String? ?? '',
                                  theme: theme,
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
    );
  }

  Widget _buildUpcomingSamagamsSection(BuildContext context, WidgetRef ref, ThemeData theme) {
    return SliverToBoxAdapter(
      child: ref.watch(featureFlagsProvider).when(
            data: (flags) {
              if (flags['feature_samagam_enabled'] != true) return const SizedBox.shrink();
              return ref.watch(upcomingSamagamsProvider).when(
                    data: (events) {
                      if (events.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.event, color: AppTheme.primaryGold, size: 24),
                                      const SizedBox(width: 8),
                                      Text(
                                        AppLocalizations.of(context)!.upcomingEvents,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: AppTheme.titleGold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () => context.push('/samagam'),
                                    child: Text(
                                      AppLocalizations.of(context)!.viewAllEvents,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppTheme.primaryGold,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...events.map((e) {
                                final json = e as Map<String, dynamic>;
                                final startDate = json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null;
                                final title = json['title'] as String? ?? '';
                                final location = json['location'] as String? ?? '';
                                final googleMapsUrl = json['googleMapsUrl'] as String?;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () => context.push('/samagam'),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGold.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.2)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.calendar_today, color: Colors.orange, size: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  title,
                                                  style: theme.textTheme.titleSmall?.copyWith(
                                                    color: AppTheme.textDark,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                if (startDate != null) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    DateFormat('MMM d, yyyy • h:mm a').format(startDate),
                                                    style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
                                                  ),
                                                ],
                                                if (location.isNotEmpty) ...[
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.location_on, size: 14, color: AppTheme.primaryGold),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          location,
                                                          style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                if (googleMapsUrl != null && googleMapsUrl.isNotEmpty)
                                                  GestureDetector(
                                                    onTap: () async {
                                                      final uri = Uri.parse(googleMapsUrl);
                                                      if (await canLaunchUrl(uri)) {
                                                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                                                      }
                                                    },
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.map, size: 14, color: AppTheme.primaryGold),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          AppLocalizations.of(context)!.openInMaps,
                                                          style: theme.textTheme.bodySmall?.copyWith(
                                                            color: AppTheme.primaryGold,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
    );
  }
}

class _DailyEkaumRevealCard extends StatefulWidget {
  const _DailyEkaumRevealCard({required this.dailyEkaum, required this.theme});
  final DailyEkaum dailyEkaum;
  final ThemeData theme;

  @override
  State<_DailyEkaumRevealCard> createState() => _DailyEkaumRevealCardState();
}

class _DailyEkaumRevealCardState extends State<_DailyEkaumRevealCard> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: InkWell(
        onTap: () => setState(() => _isRevealed = !_isRevealed),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isRevealed ? Icons.lock_open : Icons.lock_outline,
                  color: AppTheme.primaryGold,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.getDailyEkaumPassword,
                    style: widget.theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.titleGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.touch_app, size: 18, color: AppTheme.textDim),
              ],
            ),
            if (!_isRevealed) ...[
              const SizedBox(height: 8),
              Text(
                l10n.tapToReveal,
                style: widget.theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
              ),
            ],
            if (_isRevealed) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.3)),
                ),
                child: Text(
                  widget.dailyEkaum.password,
                  style: widget.theme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.date}: ${widget.dailyEkaum.date}',
                style: widget.theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FavouriteCard extends StatelessWidget {
  const _FavouriteCard({
    required this.item,
    required this.theme,
    required this.onTap,
    required this.onRemove,
  });

  final FavouriteItem item;
  final ThemeData theme;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (item.type) {
      case 'avdhan':
        icon = Icons.headphones;
        break;
      case 'video_satsang':
        icon = Icons.video_library;
        break;
      case 'patrika':
        icon = Icons.menu_book;
        break;
      case 'samagam':
        icon = Icons.event;
        break;
      case 'tool':
        icon = Icons.star;
        break;
      default:
        icon = Icons.favorite;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryGold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryGold, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppTheme.textDim),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisheshSandeshCard extends StatefulWidget {
  final String title;
  final String description;
  final ThemeData theme;

  const _VisheshSandeshCard({
    required this.title,
    required this.description,
    required this.theme,
  });

  @override
  State<_VisheshSandeshCard> createState() => _VisheshSandeshCardState();
}

class _VisheshSandeshCardState extends State<_VisheshSandeshCard> {
  static const int _truncateLength = 120;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final desc = widget.description;
    final shouldTruncate = desc.length > _truncateLength;
    final displayText = _expanded || !shouldTruncate ? desc : '${desc.substring(0, _truncateLength)}...';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryGold.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: widget.theme.textTheme.titleSmall?.copyWith(
                color: AppTheme.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              displayText,
              style: widget.theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textDim,
                height: 1.5,
              ),
            ),
            if (shouldTruncate)
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? AppLocalizations.of(context)!.readLess : AppLocalizations.of(context)!.readMore,
                  style: widget.theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
