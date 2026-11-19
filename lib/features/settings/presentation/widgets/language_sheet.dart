import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/app_localizations.dart';

/// Language picker with hand-painted flags (recovered: _EgyptFlagPainter, _UsFlagPainter).
Future<String?> showLanguageSheet(BuildContext context, String current) =>
    showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => _LanguageSheet(current: current),
    );

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.tr('language'), style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            _LanguageOption(code: 'en', label: 'English', flag: const _UsFlag(), selected: current == 'en'),
            const SizedBox(height: 8),
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
    final primary = Theme.of(context).colorScheme.primary;
    return ListTile(
      onTap: () => Navigator.pop(context, code),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: selected ? primary : Theme.of(context).colorScheme.outlineVariant),
      ),
      leading: ClipRRect(borderRadius: BorderRadius.circular(4), child: SizedBox(width: 36, height: 24, child: flag)),
      title: Text(label),
      trailing: selected ? Icon(Icons.check_circle_rounded, color: primary) : null,
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
