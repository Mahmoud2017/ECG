import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/common.dart';
import 'auth_cubit.dart';
import 'widgets/auth_scaffold.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final cubit = context.read<AuthCubit>();
    final error = await cubit.run((r) => r.signUp(
          fullName: _name.text,
          email: _email.text,
          phone: _phone.text,
          password: _password.text,
        ));
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      showSnack(context, error, error: true);
      return;
    }
    await _showConfirmEmailDialog();
  }

  Future<void> _showConfirmEmailDialog() async {
    // If email confirmation is disabled in Supabase, the user is already signed in.
    if (context.read<AuthCubit>().isLoggedIn) return;
    await showAppDialog(
      context,
      title: context.tr('confirm_email_title'),
      message: context.tr('confirm_email_body'),
      icon: Icons.mark_email_read_outlined,
    );
    if (mounted) context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: context.tr('create_account'),
      subtitle: context.tr('sign_up_subtitle'),
      showBack: true,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _name,
              label: context.tr('full_name'),
              hint: context.tr('full_name_hint'),
              prefixIcon: Icons.person_outline_rounded,
              validator: Validators.name,
            ),
            const SizedBox(height: 16),
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
              controller: _phone,
              label: context.tr('phone_number'),
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: Validators.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _password,
              label: context.tr('password'),
              password: true,
              prefixIcon: Icons.lock_outline_rounded,
              validator: Validators.password,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _confirm,
              label: context.tr('confirm_password'),
              password: true,
              prefixIcon: Icons.lock_outline_rounded,
              textInputAction: TextInputAction.done,
              validator: Validators.confirm(() => _password.text),
            ),
            const SizedBox(height: 24),
            AppButton(label: context.tr('sign_up'), loading: _loading, onPressed: _submit),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(context.tr('have_account')),
                TextButton(onPressed: () => context.go(Routes.login), child: Text(context.tr('login'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
