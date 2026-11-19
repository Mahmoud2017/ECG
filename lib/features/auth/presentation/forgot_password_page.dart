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

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final email = _email.text.trim();
    final error = await context.read<AuthCubit>().run((r) => r.sendResetCode(email));
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      showSnack(context, error, error: true);
      return;
    }
    context.push(Uri(path: Routes.otp, queryParameters: {'email': email}).toString());
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: context.tr('forgot_password_title'),
      subtitle: context.tr('forgot_password_subtitle'),
      illustration: 'assets/images/forgot_password.png',
      showBack: true,
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
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.mail_outline_rounded,
              validator: Validators.email,
            ),
            const SizedBox(height: 24),
            AppButton(label: context.tr('send_code'), loading: _loading, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
