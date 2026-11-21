import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Primary action: solid brand-blue pill (from the design), or an outlined pill.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: outlined ? AppColors.brand : Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    const shape = StadiumBorder();
    const size = Size.fromHeight(54);
    final textStyle = Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 16);

    if (outlined) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: shape,
          minimumSize: size,
          foregroundColor: AppColors.brand,
          side: const BorderSide(color: AppColors.brand),
          textStyle: textStyle,
        ),
        onPressed: loading ? null : onPressed,
        child: child,
      );
    }

    return FilledButton(
      style: FilledButton.styleFrom(
        shape: shape,
        minimumSize: size,
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.brand.withValues(alpha: loading ? 0.85 : 0.4),
        disabledForegroundColor: Colors.white,
        elevation: 0,
        textStyle: textStyle,
      ),
      onPressed: loading ? null : onPressed,
      child: child,
    );
  }
}
