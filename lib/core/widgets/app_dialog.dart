import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'app_button.dart';

/// Shows the app's standard dialog. Returns true when the primary action is tapped.
Future<bool> showAppDialog(
  BuildContext context, {
  required String title,
  required String message,
  IconData icon = Icons.info_outline_rounded,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => _AppDialog(
      title: title,
      message: message,
      icon: icon,
      confirmLabel: confirmLabel ?? context.tr('got_it'),
      cancelLabel: cancelLabel,
      destructive: destructive,
    ),
  );
  return result ?? false;
}

class _AppDialog extends StatelessWidget {
  const _AppDialog({
    required this.title,
    required this.message,
    required this.icon,
    required this.confirmLabel,
    this.cancelLabel,
    this.destructive = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final String confirmLabel;
  final String? cancelLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = destructive ? scheme.error : scheme.primary;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            if (destructive)
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: scheme.error),
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmLabel),
              )
            else
              AppButton(label: confirmLabel, onPressed: () => Navigator.pop(context, true)),
            if (cancelLabel != null) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
