import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Bottom-navigation shell for home / analysis / history / settings.
/// Selected tab: light-blue pill with icon + label; others: blue icon only.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _items = [
    (Icons.home_outlined, 'nav_home'),
    (Icons.monitor_heart_outlined, 'nav_analysis'),
    (Icons.history_rounded, 'nav_history'),
    (Icons.manage_accounts_outlined, 'nav_settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: dark ? Colors.white12 : AppColors.fieldBorder)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                for (var i = 0; i < _items.length; i++)
                  Expanded(
                    flex: shell.currentIndex == i ? 4 : 2,
                    child: _NavItem(
                      icon: _items[i].$1,
                      label: context.tr(_items[i].$2),
                      selected: shell.currentIndex == i,
                      onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
                    ),
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
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark ? const Color(0xFF7DB2FF) : AppColors.brand;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: Align(
        heightFactor: 1,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            height: 52,
            padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 10),
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: selected ? color.withValues(alpha: 0.1) : Colors.transparent,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 26),
                if (selected) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
