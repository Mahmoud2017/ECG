import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injector.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_logo.dart';
import '../../auth/presentation/auth_cubit.dart';
import '../../onboarding/data/onboarding_repository.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), _continue);
  }

  void _continue() {
    if (!mounted) return;
    final auth = context.read<AuthCubit>()..markResolved();
    if (!sl<OnboardingRepository>().seen) {
      context.go(Routes.onboarding);
    } else {
      context.go(auth.isLoggedIn ? Routes.home : Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.85, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutBack,
          builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
          child: const AppLogo(height: 64),
        ),
      ),
    );
  }
}
