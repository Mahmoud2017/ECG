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

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final error = await context.read<AuthCubit>().run((r) => r.updatePassword(_password.text));
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      showSnack(context, error, error: true);
      return;
    }
    showSnack(context, 'password_updated');
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: context.tr('reset_password_title'),
      subtitle: context.tr('reset_password_subtitle'),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _password,
              label: context.tr('new_password'),
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
            AppButton(label: context.tr('save_password'), loading: _loading, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
