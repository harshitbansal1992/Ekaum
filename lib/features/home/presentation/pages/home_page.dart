import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/components/glass_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final theme = Theme.of(context);


    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
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
                        'NAMO NARAYAN',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.primaryGold,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.name ?? 'Devotee',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
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
                          'Shree Mykhana ji',
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
                    Text(
                      "लो! ले आया दो हाथों में छल-छल करता पैमाना।\nजितना चाहो मांगो पी लो छोड़ो अब यूं शरमाना।\nप्यास बुझाने को जीवन की इक पैमाना काफी है,\nबच्चे, बूढ़े सबकी खातिर खोल दिया है मयख़ाना।",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick Tools Section
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'Quick Tools',
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
                    children: [
                      _buildQuickAction(context, 'Nadi Dosh', Icons.calculate_outlined, '/nadi-dosh'),
                      _buildQuickAction(context, 'Rahu Kaal', Icons.access_time, '/rahu-kaal'),
                      _buildQuickAction(context, 'Avdhan', Icons.headphones, '/avdhan'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Services Grid
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: [
                _buildServiceCard(context, 'Samagam', 'Events', Icons.event_note, '/samagam', Colors.orange),
                _buildServiceCard(context, 'Patrika', 'Monthly Read', Icons.menu_book, '/patrika', Colors.redAccent),
                _buildServiceCard(context, 'Pooja Items', 'Shop', Icons.shopping_bag_outlined, '/pooja-items', Colors.teal),
                _buildServiceCard(context, 'Paath', 'Services', Icons.volunteer_activism, '/paath-services', Colors.indigoAccent),
                _buildServiceCard(context, 'Donation', 'Support Us', Icons.favorite_border, '/donation', Colors.pinkAccent),
              ],
            ),
          ),
          
          // Bottom padding for scrolling
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Profile',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.errorColor),
                title: const Text('Sign Out', style: TextStyle(color: AppTheme.textDark)),
                onTap: () async {
                  Navigator.pop(context);
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
}
