import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

/// Shows the app's standard dialog. Returns true when the primary action is tapped.
/// [tag] renders as a small pill above the title (e.g. the provider name "Google").
Future<bool> showAppDialog(
  BuildContext context, {
  required String title,
  required String message,
  IconData icon = Icons.info_outline_rounded,
  String? tag,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => _AppDialog(
      title: title,
      message: message,
      icon: icon,
      tag: tag,
      confirmLabel: confirmLabel ?? context.tr('got_it'),
      cancelLabel: cancelLabel,
      destructive: destructive,
    ),
  );
  return result ?? false;
}

/// "Coming soon" for features that are not built yet; [feature] names it in a pill.
Future<void> showComingSoon(BuildContext context, {String? feature}) => showAppDialog(
      context,
      title: context.tr('coming_soon'),
      message: context.tr('coming_soon_body'),
      icon: Icons.rocket_launch_outlined,
      tag: feature,
    );

class _AppDialog extends StatelessWidget {
  const _AppDialog({
    required this.title,
    required this.message,
    required this.icon,
    required this.confirmLabel,
    this.tag,
    this.cancelLabel,
    this.destructive = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? tag;
  final String confirmLabel;
  final String? cancelLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final color = destructive ? scheme.error : AppColors.brand;
    return Dialog(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.1)),
              child: Icon(icon, color: color, size: 30),
            ),
            if (tag != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(tag!, style: text.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w500)),
              ),
            ],
            SizedBox(height: tag != null ? 10 : 16),
            Text(title, style: text.titleLarge?.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: Theme.of(context).hintColor, height: 1.5),
            ),
            const SizedBox(height: 24),
            if (destructive)
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  shape: const StadiumBorder(),
                  minimumSize: const Size.fromHeight(54),
                ),
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
