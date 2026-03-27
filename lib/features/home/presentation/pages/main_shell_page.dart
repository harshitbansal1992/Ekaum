import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import 'home_tab_page.dart';
import 'tools_tab_page.dart';
import 'services_tab_page.dart';
import 'more_tab_page.dart';

enum MainTab { home, tools, services, more }

class MainShellPage extends ConsumerStatefulWidget {
  const MainShellPage({super.key});

  @override
  ConsumerState<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends ConsumerState<MainShellPage> {
  MainTab _currentTab = MainTab.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _currentTab.index,
        children: const [
          HomeTabPage(),
          ToolsTabPage(),
          ServicesTabPage(),
          MoreTabPage(),
        ],
      ),
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
                  isActive: _currentTab == MainTab.home,
                  onTap: () => setState(() => _currentTab = MainTab.home),
                ),
                _NavItem(
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view,
                  label: 'Tools',
                  isActive: _currentTab == MainTab.tools,
                  onTap: () => setState(() => _currentTab = MainTab.tools),
                ),
                _NavItem(
                  icon: Icons.apps_outlined,
                  activeIcon: Icons.apps,
                  label: 'Services',
                  isActive: _currentTab == MainTab.services,
                  onTap: () => setState(() => _currentTab = MainTab.services),
                ),
                _NavItem(
                  icon: Icons.more_horiz,
                  activeIcon: Icons.more_horiz,
                  label: 'More',
                  isActive: _currentTab == MainTab.more,
                  onTap: () => setState(() => _currentTab = MainTab.more),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
