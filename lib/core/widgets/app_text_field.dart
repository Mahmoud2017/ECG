import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

/// Text field with label above, l10n-aware validator and password visibility toggle.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.validator,
    this.password = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;

  /// Returns an l10n key (or raw text); it is translated before display.
  final String? Function(String?)? validator;
  final bool password;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: widget.password && _hidden,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.password ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.validator == null
              ? null
              : (v) {
                  final key = widget.validator!(v);
                  return key == null ? null : context.tr(key);
                },
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon, size: 20),
            suffixIcon: widget.password
                ? IconButton(
                    icon: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : widget.suffix,
          ),
        ),
      ],
    );
  }
}
