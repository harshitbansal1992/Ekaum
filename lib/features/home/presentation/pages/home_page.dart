import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/components/glass_card.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_settings_provider.dart';

/// Card that shows Daily Ekaum password + date only when tapped (tap to reveal).
class _DailyEkaumRevealCard extends StatefulWidget {
  const _DailyEkaumRevealCard({
    required this.dailyEkaum,
    required this.theme,
  });

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
                style: widget.theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textDim,
                ),
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
                style: widget.theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textDim,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final theme = Theme.of(context);


    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
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
          // Custom App Bar Area
          SliverToBoxAdapter(
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
                        onTap: () {
                          _showProfileDialog(context, ref);
                        },
                        child: const Icon(Icons.person_outline, color: AppTheme.primaryGold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Shree Mykhana ji Hero Section
          SliverToBoxAdapter(
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
          ),

          // Today's Panchang (Hindu Calendar) - FREE via Kaalchakra, shown prominently
          SliverToBoxAdapter(
            child: ref.watch(featureFlagsProvider).when(
              data: (flags) {
                if (flags['feature_panchang_enabled'] != true) return const SizedBox.shrink();
                return ref.watch(panchangProvider).when(
                  data: (panchang) {
                    if (panchang == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: _buildPanchangCard(context, ref, panchang, theme),
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
          ),

          // Get Daily Ekaum Password Section (tap to reveal mantra + date)
          SliverToBoxAdapter(
            child: ref.watch(featureFlagsProvider).when(
              data: (flags) {
                if (flags['feature_daily_ekaum_enabled'] != true) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ref.watch(dailyEkaumProvider).when(
                    data: (dailyEkaum) {
                      if (dailyEkaum == null) return const SizedBox.shrink();
                      return _DailyEkaumRevealCard(
                        dailyEkaum: dailyEkaum,
                        theme: theme,
                      );
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
          ),

          // Vishesh Sandesh (Announcements) Section
          SliverToBoxAdapter(
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
                              final title = json['title'] as String? ?? '';
                              final description = json['description'] as String? ?? '';
                              return _VisheshSandeshCard(
                                title: title,
                                description: description,
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
          ),

          // Upcoming Samagams Hero Section (3 latest future events)
          SliverToBoxAdapter(
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
                                                  _formatSamagamDate(startDate),
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
                                              if (googleMapsUrl != null && googleMapsUrl.isNotEmpty) ...[
                                                const SizedBox(height: 6),
                                                GestureDetector(
                                                  onTap: () => _openMapsUrl(googleMapsUrl),
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
          ),

          // Quick Tools Section (respects feature flags from backoffice)
          SliverToBoxAdapter(
            child: ref.watch(featureFlagsProvider).when(
              data: (flags) {
                final items = <Widget>[];
                if (flags['feature_kundli_lite_enabled'] ?? true) {
                  items.add(_buildQuickAction(context, AppLocalizations.of(context)!.kundliLite, Icons.auto_awesome, '/kundli-lite'));
                }
                if (flags['feature_nadi_dosh_enabled'] ?? true) {
                  items.add(_buildQuickAction(context, AppLocalizations.of(context)!.nadiDosh, Icons.calculate_outlined, '/nadi-dosh'));
                }
                if (flags['feature_rahu_kaal_enabled'] ?? true) {
                  items.add(_buildQuickAction(context, AppLocalizations.of(context)!.rahuKaal, Icons.access_time, '/rahu-kaal'));
                }
                if (flags['feature_avdhan_enabled'] ?? true) {
                  items.add(_buildQuickAction(context, AppLocalizations.of(context)!.avdhan, Icons.headphones, '/avdhan'));
                }
                if (flags['feature_video_satsang_enabled'] ?? true) {
                  items.add(_buildQuickAction(context, AppLocalizations.of(context)!.videoSatsang, Icons.video_library, '/video-satsang'));
                }
                if (items.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Text(
                        AppLocalizations.of(context)!.quickTools,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textDim,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        children: items,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // Services Grid (respects feature flags from backoffice)
          ref.watch(featureFlagsProvider).when(
            data: (flags) {
              final items = <Widget>[];
              if (flags['feature_mantra_notes_enabled'] ?? true) {
                items.add(_buildServiceCard(context, AppLocalizations.of(context)!.mantraNotes, AppLocalizations.of(context)!.storeMantras, Icons.menu_book, '/mantra-notes', Colors.deepPurple));
              }
              if (flags['feature_samagam_enabled'] ?? true) {
                items.add(_buildServiceCard(context, AppLocalizations.of(context)!.samagam, AppLocalizations.of(context)!.events, Icons.event_note, '/samagam', Colors.orange));
              }
              if (flags['feature_patrika_enabled'] ?? true) {
                items.add(_buildServiceCard(context, AppLocalizations.of(context)!.patrika, AppLocalizations.of(context)!.monthlyRead, Icons.menu_book, '/patrika', Colors.redAccent));
              }
              if (flags['feature_pooja_items_enabled'] ?? true) {
                items.add(_buildServiceCard(context, AppLocalizations.of(context)!.poojaItems, AppLocalizations.of(context)!.shop, Icons.shopping_bag_outlined, '/pooja-items', Colors.teal));
              }
              if (flags['feature_paath_services_enabled'] ?? true) {
                items.add(_buildServiceCard(context, AppLocalizations.of(context)!.paath, AppLocalizations.of(context)!.services, Icons.volunteer_activism, '/paath-services', Colors.indigoAccent));
              }
              if (flags['feature_donation_enabled'] ?? true) {
                items.add(_buildServiceCard(context, AppLocalizations.of(context)!.donation, AppLocalizations.of(context)!.supportUs, Icons.favorite_border, '/donation', Colors.pinkAccent));
              }
              if (flags['feature_social_activities_enabled'] ?? true) {
                items.add(_buildServiceCard(context, AppLocalizations.of(context)!.socialActivities, AppLocalizations.of(context)!.socialActivitiesSubtitle, Icons.volunteer_activism, '/social-activities', Colors.green));
              }
              if (flags['feature_blog_enabled'] ?? true) {
                items.add(_buildServiceCard(context, AppLocalizations.of(context)!.readBlog, AppLocalizations.of(context)!.readBlogDesc, Icons.article_outlined, '/blog', Colors.brown));
              }
              if (flags['feature_bslnd_centers_enabled'] ?? true) {
                items.add(_buildServiceCard(context, AppLocalizations.of(context)!.bslndCenters, AppLocalizations.of(context)!.bslndCentersDesc, Icons.place_outlined, '/bslnd-centers', Colors.deepOrange));
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
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // Email for Queries Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: GlassCard(
                onTap: () => _openEmail(context),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.email_outlined, color: Colors.blue, size: 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.emailForQueries,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'prabhukripa999@gmail.com',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryGold,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryGold),
                  ],
                ),
              ),
            ),
          ),

          // Follow us on social media
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.watchOurYouTube,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.subscribeForContent,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textDim,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _SocialIconButton(
                          icon: Icons.play_circle_filled,
                          color: Colors.red,
                          onTap: () => _openUrl(context, AppConstants.youtubeUrl),
                        ),
                        _SocialIconButton(
                          icon: Icons.camera_alt,
                          color: const Color(0xFFE4405F),
                          onTap: () => _openUrl(context, AppConstants.instagramUrl),
                        ),
                        _SocialIconButton(
                          icon: Icons.facebook_rounded,
                          color: const Color(0xFF1877F2),
                          onTap: () => _openUrl(context, AppConstants.facebookUrl),
                        ),
                        _SocialIconButton(
                          icon: Icons.alternate_email,
                          color: Colors.black87,
                          onTap: () => _openUrl(context, AppConstants.xUrl),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom padding for scrolling
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
        ),
      ),
    );
  }


  Widget _buildPanchangCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> panchang,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final angas = panchang['angas'] as Map<String, dynamic>?;
    final paksha = panchang['paksha'] as Map<String, dynamic>?;
    final saka = panchang['saka_era_calendar_date'] as Map<String, dynamic>?;

    String? tithiName;
    String? nakshatraName;
    String? varaName;
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
      final day = d?['number'];
      final month = m?['name'];
      final year = y?['number'];
      if (day != null && month != null && year != null) {
        sakaStr = '$day $month $year';
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
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textDim,
                        ),
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
                  child: Text(
                    row[0],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textDim,
                    ),
                  ),
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

  Widget _buildQuickAction(BuildContext context, String title, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          GlassCard(
            height: 70,
            width: 70,
            borderRadius: 20,
            onTap: () => context.push(route),
            child: Center(
              child: Icon(icon, color: AppTheme.primaryGold, size: 28),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textDim,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEmail(BuildContext context) async {
    final url = Uri.parse('mailto:prabhukripa999@gmail.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  static String _formatSamagamDate(DateTime d) =>
      DateFormat('MMM d, yyyy • h:mm a').format(d);

  Future<void> _openMapsUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildServiceCard(BuildContext context, String title, String subtitle, IconData icon, String route, Color accentColor) {
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

  void _showProfileDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.profile,
                style: Theme.of(dialogContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit, color: AppTheme.primaryGold),
                title: Text(l10n.editProfile, style: const TextStyle(color: AppTheme.textDark)),
                onTap: () {
                  Navigator.pop(dialogContext);
                  context.push('/edit-profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.volunteer_activism, color: AppTheme.primaryGold),
                title: Text(l10n.viewPaathDetails, style: const TextStyle(color: AppTheme.textDark)),
                onTap: () {
                  Navigator.pop(dialogContext);
                  context.push('/paath-details');
                },
              ),
              ListTile(
                leading: const Icon(Icons.language, color: AppTheme.primaryGold),
                title: Text(l10n.language, style: const TextStyle(color: AppTheme.textDark)),
                trailing: Text(
                  ref.watch(localeProvider)?.displayName ?? l10n.english,
                  style: const TextStyle(color: AppTheme.textDim, fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showLanguageSelector(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.palette_outlined, color: AppTheme.primaryGold),
                title: Text(l10n.appTheme, style: const TextStyle(color: AppTheme.textDark)),
                trailing: Text(
                  ref.watch(themeModeProvider).displayName,
                  style: const TextStyle(color: AppTheme.textDim, fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showThemeSelector(context, ref);
                },
              ),
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.errorColor),
                title: Text(l10n.signOut, style: const TextStyle(color: AppTheme.textDark)),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Consumer(
        builder: (_, ref, __) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectLanguage,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                RadioListTile<Locale?>(
                  title: Text(AppLocalizations.of(context)!.useDeviceLanguage),
                  value: null,
                  groupValue: ref.watch(localeProvider),
                  onChanged: (value) {
                    ref.read(localeProvider.notifier).setLocale(null);
                    Navigator.pop(sheetContext);
                  },
                ),
                ...supportedLocales.map((locale) => RadioListTile<Locale?>(
                      title: Text(locale.displayName),
                      value: locale,
                      groupValue: ref.watch(localeProvider),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(localeProvider.notifier).setLocale(value);
                          Navigator.pop(sheetContext);
                        }
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Consumer(
        builder: (_, ref, __) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Theme',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...AppThemeMode.values.map((mode) => RadioListTile<AppThemeMode>(
                      title: Text(mode.displayName),
                      value: mode,
                      groupValue: ref.watch(themeModeProvider),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(themeModeProvider.notifier).setThemeMode(value);
                          Navigator.pop(sheetContext);
                        }
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Expandable announcement card for Vishesh Sandesh section
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
            if (shouldTruncate) ...[
              const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
      ),
    );
  }
}
