import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/components/glass_card.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Social activities from BSLND - https://bslnd.in/
class SocialActivitiesPage extends StatelessWidget {
  const SocialActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final activities = [
      _SocialActivity(
        title: l10n.charitableHospitals,
        description: l10n.charitableHospitalsDesc,
        icon: Icons.local_hospital_outlined,
        color: Colors.red,
        url: 'https://charitablehospital.in/',
      ),
      _SocialActivity(
        title: l10n.langarDistribution,
        description: l10n.langarDistributionDesc,
        icon: Icons.restaurant,
        color: Colors.orange,
        url: AppConstants.bslndWebsite,
      ),
      _SocialActivity(
        title: l10n.spiritualSamagams,
        description: l10n.spiritualSamagamsDesc,
        icon: Icons.volunteer_activism,
        color: Colors.purple,
        url: AppConstants.mahabrahmrishiWebsite,
      ),
      _SocialActivity(
        title: l10n.educationalSupport,
        description: l10n.educationalSupportDesc,
        icon: Icons.school_outlined,
        color: Colors.blue,
        url: AppConstants.bslndWebsite,
      ),
      _SocialActivity(
        title: l10n.templeDevelopment,
        description: l10n.templeDevelopmentDesc,
        icon: Icons.temple_hindu_outlined,
        color: Colors.amber.shade700,
        url: AppConstants.bslndWebsite,
      ),
      _SocialActivity(
        title: l10n.globalOutreach,
        description: l10n.globalOutreachDesc,
        icon: Icons.public,
        color: Colors.teal,
        url: 'https://worldhumanityparliament.com/',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.socialActivities),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final a = activities[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassCard(
              onTap: () => _launchUrl(context, a.url),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: a.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(a.icon, color: a.color, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          a.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.titleGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.primaryGold),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    a.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textDim,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _launchUrl(context, a.url),
                    child: Text(
                      l10n.learnMore,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.error)),
        );
      }
    }
  }
}

class _SocialActivity {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String url;

  _SocialActivity({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.url,
  });
}
