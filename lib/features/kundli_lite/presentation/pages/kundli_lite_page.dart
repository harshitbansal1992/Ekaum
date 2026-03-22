import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../nadi_dosh/data/services/nadi_dosh_service.dart';

class KundliLitePage extends ConsumerWidget {
  const KundliLitePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final hasBirthDetails = user?.dateOfBirth != null &&
        (user?.timeOfBirth != null && user!.timeOfBirth!.isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.kundliLite),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 48,
                      color: AppTheme.primaryGold,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.kundliLite,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.primaryGold,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.kundliLiteDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textDim,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            if (!hasBirthDetails) ...[
              const SizedBox(height: 24),
              Card(
                color: AppTheme.primaryGold.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppTheme.primaryGold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.addBirthDetailsForKundli,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.addBirthDetailsHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textDim,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/edit-profile'),
                        icon: const Icon(Icons.edit),
                        label: Text(l10n.editProfile),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 24),
              _BirthDetailsCard(user: user, theme: theme),
              const SizedBox(height: 20),
              _NadiCard(
                dateOfBirth: user.dateOfBirth!,
                timeOfBirth: user.timeOfBirth!,
                theme: theme,
                l10n: l10n,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BirthDetailsCard extends StatelessWidget {
  final dynamic user;
  final ThemeData theme;

  const _BirthDetailsCard({
    required this.user,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: AppTheme.primaryGold, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.birthDetails,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: AppLocalizations.of(context)!.dateOfBirth,
              value: user.dateOfBirth != null
                  ? DateFormat('dd MMM yyyy').format(user.dateOfBirth as DateTime)
                  : '—',
            ),
            _DetailRow(
              label: AppLocalizations.of(context)!.timeOfBirth,
              value: (user.timeOfBirth as String?)?.isNotEmpty == true
                  ? (user.timeOfBirth as String)
                  : '—',
            ),
            _DetailRow(
              label: AppLocalizations.of(context)!.placeOfBirth,
              value: (user.placeOfBirth as String?)?.isNotEmpty == true
                  ? (user.placeOfBirth as String)
                  : '—',
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label.replaceAll(' *', ''),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textDim,
                  ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _NadiCard extends StatelessWidget {
  final DateTime dateOfBirth;
  final String timeOfBirth;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _NadiCard({
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final nadiResult = NadiDoshService.calculateNadiDosh(
      birthDate: dateOfBirth,
      birthTime: timeOfBirth,
      birthPlace: '',
    );
    final nadiType = nadiResult['nadiType'] as String? ?? '—';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: AppTheme.primaryGold, size: 24),
                const SizedBox(width: 8),
                Text(
                  l10n.nadi,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                nadiType,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.nadiKundliHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
