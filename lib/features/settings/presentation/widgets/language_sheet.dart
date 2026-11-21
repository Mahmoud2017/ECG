import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

/// Language picker with hand-painted flags (recovered: _EgyptFlagPainter, _UsFlagPainter).
/// Uses the root navigator so the sheet covers the bottom nav bar.
Future<String?> showLanguageSheet(BuildContext context, String current) =>
    showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _LanguageSheet(current: current),
    );

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.tr('language'), style: text.titleLarge?.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            _LanguageOption(code: 'en', label: 'English', flag: const _UsFlag(), selected: current == 'en'),
            const SizedBox(height: 12),
            _LanguageOption(code: 'ar', label: 'العربية', flag: const _EgyptFlag(), selected: current == 'ar'),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({required this.code, required this.label, required this.flag, required this.selected});

  final String code;
  final String label;
  final Widget flag;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: selected ? AppColors.brand : (dark ? Colors.white12 : AppColors.fieldBorder), width: selected ? 1.5 : 1),
    );
    return Material(
      color: selected ? AppColors.brand.withValues(alpha: 0.06) : (dark ? AppColors.darkBg : AppColors.fieldFill),
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: () => Navigator.pop(context, code),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(4), child: SizedBox(width: 36, height: 24, child: flag)),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500))),
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: selected ? AppColors.brand : Theme.of(context).hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EgyptFlag extends StatelessWidget {
  const _EgyptFlag();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _EgyptFlagPainter());
}

class _EgyptFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height / 3;
    canvas
      ..drawRect(Rect.fromLTWH(0, 0, size.width, h), Paint()..color = const Color(0xFFCE1126))
      ..drawRect(Rect.fromLTWH(0, h, size.width, h), Paint()..color = Colors.white)
      ..drawRect(Rect.fromLTWH(0, 2 * h, size.width, h), Paint()..color = Colors.black)
      ..drawCircle(Offset(size.width / 2, size.height / 2), h * 0.32, Paint()..color = const Color(0xFFC09300));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _UsFlag extends StatelessWidget {
  const _UsFlag();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _UsFlagPainter());
}

class _UsFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stripe = size.height / 13;
    final red = Paint()..color = const Color(0xFFB22234);
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    for (var i = 0; i < 13; i += 2) {
      canvas.drawRect(Rect.fromLTWH(0, i * stripe, size.width, stripe), red);
    }
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 0.4, stripe * 7), Paint()..color = const Color(0xFF3C3B6E));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
