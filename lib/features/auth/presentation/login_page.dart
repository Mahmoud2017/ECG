import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/common.dart';
import 'auth_cubit.dart';
import 'widgets/auth_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final error = await context.read<AuthCubit>().run(
          (r) => r.signIn(email: _email.text, password: _password.text),
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) showSnack(context, error, error: true);
    // Success: AuthCubit emits authenticated and the router redirects to /home.
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final muted = text.bodySmall?.copyWith(color: Theme.of(context).hintColor, fontSize: 13);
    final strong = TextStyle(color: dark ? Colors.white : AppColors.navy, fontWeight: FontWeight.w600);

    return AuthScaffold(
      title: context.tr('welcome_back'),
      subtitle: context.tr('login_subtitle'),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _email,
              hint: context.tr('email'),
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.mail_outline_rounded,
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _password,
              hint: context.tr('password'),
              password: true,
              prefixIcon: Icons.lock_outline_rounded,
              textInputAction: TextInputAction.done,
              validator: Validators.required,
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.brand),
                onPressed: () => context.push(Routes.forgotPassword),
                child: Text(context.tr('forgot_password_q')),
              ),
            ),
            const SizedBox(height: 12),
            AppButton(label: context.tr('login'), loading: _loading, onPressed: _submit),
            const SizedBox(height: 28),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(context.tr('or_continue_with'), style: muted),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialButton(
                  label: 'Google',
                  icon: FontAwesomeIcons.google,
                  color: const Color(0xFF4285F4),
                  onTap: () => showComingSoon(context, feature: 'Google'),
                ),
                const SizedBox(width: 28),
                _SocialButton(
                  label: 'Apple',
                  icon: FontAwesomeIcons.apple,
                  color: dark ? Colors.white : Colors.black,
                  onTap: () => showComingSoon(context, feature: 'Apple'),
                ),
                const SizedBox(width: 28),
                _SocialButton(
                  label: 'Facebook',
                  icon: FontAwesomeIcons.facebook,
                  color: const Color(0xFF1877F2),
                  onTap: () => showComingSoon(context, feature: 'Facebook'),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                style: muted?.copyWith(height: 1.6),
                children: [
                  TextSpan(text: '${context.tr('terms_notice')} '),
                  TextSpan(
                    text: context.tr('terms_conditions'),
                    style: strong,
                    recognizer: TapGestureRecognizer()..onTap = () => context.push(Routes.terms),
                  ),
                  TextSpan(text: ' ${context.tr('and')} '),
                  TextSpan(
                    text: context.tr('privacy_policy'),
                    style: strong,
                    recognizer: TapGestureRecognizer()..onTap = () => context.push(Routes.privacy),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(context.tr('no_account'), style: text.bodyMedium),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: AppColors.brand),
                  onPressed: () => context.push(Routes.signUp),
                  child: Text(context.tr('sign_up'), style: const TextStyle(fontSize: 15)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon, required this.color, required this.onTap});

  final String label;
  final FaIconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        shape: CircleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6))),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: 52, height: 52, child: Center(child: FaIcon(icon, color: color, size: 22))),
        ),
      ),
    );
  }
}
