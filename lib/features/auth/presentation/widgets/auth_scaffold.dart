import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/app_logo.dart';

/// Shared layout for login / sign-up / forgot / otp / reset pages.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.illustration,
    this.showBack = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String? illustration;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: showBack ? AppBar() : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (illustration != null)
                Image.asset(illustration!, height: 180)
              else
                const Center(child: AppLogo(height: 44)),
              const SizedBox(height: 28),
              Text(title, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(subtitle, style: text.bodyMedium?.copyWith(color: Theme.of(context).hintColor)),
              const SizedBox(height: 28),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
