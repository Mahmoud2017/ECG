import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/app_logo.dart';

/// Shared layout for login / sign-up / forgot / otp / reset pages:
/// white page, centered logo (or illustration), centered title and subtitle.
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
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: showBack ? AppBar(backgroundColor: surface) : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, showBack ? 8 : 40, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (illustration != null)
                Image.asset(illustration!, height: 180)
              else
                const Center(child: AppLogo(height: 48)),
              const SizedBox(height: 32),
              Text(
                title,
                textAlign: TextAlign.center,
                style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
              ),
              const SizedBox(height: 32),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
