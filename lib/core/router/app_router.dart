import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../features/analysis/data/ecg_analysis.dart';
import '../../features/analysis/data/patient.dart';
import '../../features/analysis/presentation/analysis_page.dart';
import '../../features/analysis/presentation/analysis_result_page.dart';
import '../../features/auth/presentation/auth_cubit.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/otp_page.dart';
import '../../features/auth/presentation/reset_password_page.dart';
import '../../features/auth/presentation/sign_up_page.dart';
import '../../features/contact/presentation/contact_us_page.dart';
import '../../features/history/presentation/history_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/settings/presentation/content_page.dart';
import '../../features/settings/presentation/help_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../widgets/main_shell.dart';

/// Route paths recovered from the binary.
class Routes {
  Routes._();
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signUp = '/sign-up';
  static const forgotPassword = '/forgot-password';
  static const otp = '/otp';
  static const resetPassword = '/reset-password';
  static const home = '/home';
  static const analysis = '/analysis';
  static const analysisResult = '/analysis-result';
  static const history = '/history';
  static const settings = '/settings';
  static const help = '/help';
  static const faq = '/help/faq';
  static const privacy = '/help/privacy';
  static const terms = '/help/terms';
  static const contact = '/help/contact';
}

const _publicPaths = {
  Routes.splash,
  Routes.onboarding,
  Routes.login,
  Routes.signUp,
  Routes.forgotPassword,
  Routes.otp,
  Routes.resetPassword,
  Routes.privacy,
  Routes.terms,
};

GoRouter buildRouter(AuthCubit auth) {
  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: _StreamListenable(auth.stream),
    redirect: (context, state) {
      final path = state.matchedLocation;
      final status = auth.state.status;
      if (status == AuthStatus.unknown) return null; // splash decides
      final loggedIn = status == AuthStatus.authenticated;
      if (!loggedIn && !_publicPaths.contains(path)) return Routes.login;
      if (loggedIn && (path == Routes.login || path == Routes.signUp)) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingPage()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: Routes.signUp, builder: (_, _) => const SignUpPage()),
      GoRoute(path: Routes.forgotPassword, builder: (_, _) => const ForgotPasswordPage()),
      GoRoute(
        path: Routes.otp,
        builder: (_, state) => OtpPage(email: state.uri.queryParameters['email'] ?? ''),
      ),
      GoRoute(path: Routes.resetPassword, builder: (_, _) => const ResetPasswordPage()),
      GoRoute(
        path: Routes.analysisResult,
        builder: (_, state) {
          final extra = state.extra;
          return AnalysisResultPage(
            patient: extra is Patient ? extra : null,
            analysis: extra is EcgAnalysis ? extra : null,
          );
        },
      ),
      GoRoute(path: Routes.faq, builder: (_, _) => const HelpPage(faqOnly: true)),
      GoRoute(path: Routes.privacy, builder: (_, _) => const ContentPage(kind: 'privacy')),
      GoRoute(path: Routes.terms, builder: (_, _) => const ContentPage(kind: 'terms')),
      GoRoute(path: Routes.contact, builder: (_, _) => const ContactUsPage()),
      GoRoute(path: Routes.help, builder: (_, _) => const HelpPage()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomePage())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.analysis, builder: (_, _) => const AnalysisPage())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.history, builder: (_, _) => const HistoryPage())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.settings, builder: (_, _) => const SettingsPage())]),
        ],
      ),
    ],
  );
}

class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
