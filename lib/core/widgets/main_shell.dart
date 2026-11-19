import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

/// Bottom-navigation shell for home / analysis / history / settings.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'nav_home'),
    (Icons.monitor_heart_outlined, Icons.monitor_heart_rounded, 'nav_analysis'),
    (Icons.history_rounded, Icons.history_rounded, 'nav_history'),
    (Icons.settings_outlined, Icons.settings_rounded, 'nav_settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 6))],
          ),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: _items[i].$1,
                    activeIcon: _items[i].$2,
                    label: context.tr(_items[i].$3),
                    selected: shell.currentIndex == i,
                    onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
                  ),
                ),
            ],
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
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor;
    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(selected ? activeIcon : icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
        ],
      ),
    );
  }
}
