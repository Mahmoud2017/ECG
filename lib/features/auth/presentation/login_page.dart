import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
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
    final link = TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600);
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
              label: context.tr('email_address'),
              hint: context.tr('email_hint'),
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.mail_outline_rounded,
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _password,
              label: context.tr('password'),
              password: true,
              prefixIcon: Icons.lock_outline_rounded,
              textInputAction: TextInputAction.done,
              validator: Validators.required,
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => context.push(Routes.forgotPassword),
                child: Text(context.tr('forgot_password_q')),
              ),
            ),
            const SizedBox(height: 8),
            AppButton(label: context.tr('login'), loading: _loading, onPressed: _submit),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(context.tr('no_account')),
                TextButton(onPressed: () => context.push(Routes.signUp), child: Text(context.tr('sign_up'))),
              ],
            ),
            const SizedBox(height: 12),
            Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  TextSpan(text: '${context.tr('terms_notice')} '),
                  TextSpan(
                    text: context.tr('terms_conditions'),
                    style: link,
                    recognizer: TapGestureRecognizer()..onTap = () => context.push(Routes.terms),
                  ),
                  TextSpan(text: ' ${context.tr('and')} '),
                  TextSpan(
                    text: context.tr('privacy_policy'),
                    style: link,
                    recognizer: TapGestureRecognizer()..onTap = () => context.push(Routes.privacy),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
