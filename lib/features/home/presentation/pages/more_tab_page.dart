import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/components/glass_card.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// More tab: Profile, settings, email, social links
class MoreTabPage extends ConsumerWidget {
  const MoreTabPage({super.key});

  static void showProfileDialog(BuildContext context, WidgetRef ref) {
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
                trailing: Consumer(
                  builder: (_, ref, __) => Text(
                    ref.watch(localeProvider)?.displayName ?? l10n.english,
                    style: const TextStyle(color: AppTheme.textDim, fontSize: 14),
                  ),
                ),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showLanguageSelector(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.palette_outlined, color: AppTheme.primaryGold),
                title: Text(l10n.appTheme, style: const TextStyle(color: AppTheme.textDark)),
                trailing: Consumer(
                  builder: (_, ref, __) => Text(
                    ref.watch(themeModeProvider).displayName,
                    style: const TextStyle(color: AppTheme.textDim, fontSize: 14),
                  ),
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
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showLanguageSelector(BuildContext context, WidgetRef ref) {
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
                ...AppLocalizations.supportedLocales.map((locale) => RadioListTile<Locale?>(
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

  static void _showThemeSelector(BuildContext context, WidgetRef ref) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Row(
              children: [
                Text(
                  'My Account',
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGold.withValues(alpha: 0.16),
                          Colors.white.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryGold.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryGold.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            (user?.name?.trim().isNotEmpty == true
                                    ? user!.name!.trim().substring(0, 1)
                                    : 'D')
                                .toUpperCase(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AppTheme.primaryGold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Devotee profile',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: AppTheme.primaryGold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                user?.name?.trim().isNotEmpty == true
                                    ? user!.name!
                                    : AppLocalizations.of(context)!.devotee,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: AppTheme.textDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email?.trim().isNotEmpty == true
                                    ? user!.email
                                    : 'Update your profile details',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.edit_outlined,
                          title: AppLocalizations.of(context)!.editProfile,
                          subtitle: 'Personal details',
                          accentColor: AppTheme.primaryGold,
                          onTap: () => context.push('/edit-profile'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.volunteer_activism,
                          title: 'My Paath',
                          subtitle: 'Bookings & status',
                          accentColor: Colors.green,
                          onTap: () => context.push('/paath-details'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.language, color: AppTheme.primaryGold),
                    title: Text(
                      AppLocalizations.of(context)!.language,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Consumer(
                      builder: (_, ref, __) => Text(
                        ref.watch(localeProvider)?.displayName ?? AppLocalizations.of(context)!.english,
                        style: const TextStyle(color: AppTheme.textDim, fontSize: 14),
                      ),
                    ),
                    onTap: () => _showLanguageSelector(context, ref),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.palette_outlined, color: AppTheme.primaryGold),
                    title: Text(
                      AppLocalizations.of(context)!.appTheme,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Consumer(
                      builder: (_, ref, __) => Text(
                        ref.watch(themeModeProvider).displayName,
                        style: const TextStyle(color: AppTheme.textDim, fontSize: 14),
                      ),
                    ),
                    onTap: () => _showThemeSelector(context, ref),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Text(
                    'Support',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.email_outlined, color: Colors.blue),
                    title: Text(
                      AppLocalizations.of(context)!.emailForQueries,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'prabhukripa999@gmail.com',
                      style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryGold),
                    onTap: () async {
                      final url = Uri.parse('mailto:prabhukripa999@gmail.com');
                      if (await canLaunchUrl(url)) await launchUrl(url);
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Follow us',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.subscribeForContent,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
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
                  const Divider(height: 32),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout, color: AppTheme.errorColor),
                    title: Text(
                      AppLocalizations.of(context)!.signOut,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      await ref.read(authProvider.notifier).signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accentColor.withValues(alpha: 0.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
