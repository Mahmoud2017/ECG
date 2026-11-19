import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:go_router/go_router.dart';

import 'core/di/injector.dart';
import 'core/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_cubit.dart';
import 'features/profile/presentation/profile_cubit.dart';
import 'features/settings/presentation/settings_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = buildRouter(sl<AuthCubit>());

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthCubit>()),
        BlocProvider.value(value: sl<SettingsCubit>()),
        BlocProvider.value(value: sl<ProfileCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) => MaterialApp.router(
          title: 'CardioPulse MD',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(settings.locale),
          darkTheme: AppTheme.dark(settings.locale),
          themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _router,
        ),
      ),
    );
  }
}
