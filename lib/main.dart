import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/di/injector.dart';

/// Supabase project recovered from the release APK.
/// Override with --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://xomswbnxqrxrjohjyhkm.supabase.co',
);
const supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_O8PGbGE-n2QxeMDuQb6CDQ_m9MVeEz_',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
    // Fail fast: default is 3 retries with backoff, which kept skeletons up for minutes when offline.
    postgrestOptions: const PostgrestClientOptions(retryCount: 1, requestTimeout: Duration(seconds: 10)),
  );
  await setupInjector();
  runApp(const App());
}
