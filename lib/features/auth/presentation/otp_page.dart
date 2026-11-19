import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/common.dart';
import 'auth_cubit.dart';
import 'widgets/auth_scaffold.dart';

/// 6-digit recovery code entry (recovered: _startTimer, _resend).
class OtpPage extends StatefulWidget {
  const OtpPage({super.key, required this.email});

  final String email;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _code = TextEditingController();
  Timer? _timer;
  int _seconds = 60;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 1) t.cancel();
      setState(() => _seconds--);
    });
  }

  Future<void> _resend() async {
    final error = await context.read<AuthCubit>().run((r) => r.sendResetCode(widget.email));
    if (!mounted) return;
    showSnack(context, error ?? 'code_resent', error: error != null);
    if (error == null) _startTimer();
  }

  Future<void> _verify() async {
    if (_code.text.length != 6) return;
    setState(() => _loading = true);
    final error = await context
        .read<AuthCubit>()
        .run((r) => r.verifyRecoveryCode(email: widget.email, code: _code.text));
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      showSnack(context, error, error: true);
      return;
    }
    context.pushReplacement(Routes.resetPassword);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pin = PinTheme(
      width: 50,
      height: 56,
      textStyle: Theme.of(context).textTheme.titleLarge,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
    );
    return AuthScaffold(
      title: context.tr('verify_title'),
      subtitle: '${context.tr('verify_subtitle')} ${widget.email}',
      showBack: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Pinput(
              length: 6,
              controller: _code,
              defaultPinTheme: pin,
              focusedPinTheme: pin.copyWith(
                decoration: pin.decoration!.copyWith(border: Border.all(color: scheme.primary, width: 1.5)),
              ),
              onCompleted: (_) => _verify(),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(label: context.tr('verify'), loading: _loading, onPressed: _verify),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(context.tr('no_code')),
              TextButton(
                onPressed: _seconds > 0 ? null : _resend,
                child: Text(_seconds > 0
                    ? '${context.tr('resend_code')} (${_seconds}s)'
                    : context.tr('resend_code')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
