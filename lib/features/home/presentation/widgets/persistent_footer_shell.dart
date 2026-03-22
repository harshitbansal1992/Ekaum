import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class PersistentFooterShell extends StatelessWidget {
  final Widget child;
  final String location;

  const PersistentFooterShell({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final currentTab = _tabForLocation(location);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  isActive: currentTab == _FooterTab.home,
                  onTap: () => context.go('/home'),
                ),
                _NavItem(
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view,
                  label: 'Tools',
                  isActive: currentTab == _FooterTab.tools,
                  onTap: () => context.go('/tools'),
                ),
                _NavItem(
                  icon: Icons.apps_outlined,
                  activeIcon: Icons.apps,
                  label: 'Services',
                  isActive: currentTab == _FooterTab.services,
                  onTap: () => context.go('/services-tab'),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  isActive: currentTab == _FooterTab.more,
                  onTap: () => context.go('/more'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _FooterTab _tabForLocation(String path) {
    if (path == '/home') return _FooterTab.home;

    if (path == '/tools' ||
        path.startsWith('/kundli-lite') ||
        path.startsWith('/nadi-dosh') ||
        path.startsWith('/rahu-kaal') ||
        path.startsWith('/avdhan') ||
        path.startsWith('/video-satsang')) {
      return _FooterTab.tools;
    }

    if (path == '/more' ||
        path.startsWith('/edit-profile') ||
        path.startsWith('/search')) {
      return _FooterTab.more;
    }

    return _FooterTab.services;
  }
}

enum _FooterTab { home, tools, services, more }

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppTheme.primaryGold : AppTheme.textDim,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppTheme.primaryGold : AppTheme.textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
