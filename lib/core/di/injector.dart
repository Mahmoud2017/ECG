import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/analysis/data/ecg_analysis_repository.dart';
import '../../features/analysis/data/patients_repository.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/auth_cubit.dart';
import '../../features/contact/data/contact_repository.dart';
import '../../features/history/presentation/patients_cubit.dart';
import '../../features/onboarding/data/onboarding_repository.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/presentation/profile_cubit.dart';
import '../../features/settings/data/content_repository.dart';
import '../../features/settings/presentation/settings_cubit.dart';

final sl = GetIt.instance;

Future<void> setupInjector() async {
  final prefs = await SharedPreferences.getInstance();
  final client = Supabase.instance.client;

  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton<SupabaseClient>(client)
    // Repositories
    ..registerLazySingleton(() => AuthRepository(client))
    ..registerLazySingleton(() => ProfileRepository(client))
    ..registerLazySingleton(() => PatientsRepository(client))
    // The release build shipped MockEcgAnalysisRepository (no real AI backend yet).
    ..registerLazySingleton<EcgAnalysisRepository>(MockEcgAnalysisRepository.new)
    ..registerLazySingleton(() => ContactRepository(client))
    ..registerLazySingleton(() => ContentRepository(client))
    ..registerLazySingleton(() => OnboardingRepository(prefs, client))
    // App-wide cubits
    ..registerSingleton(SettingsCubit(prefs))
    ..registerSingleton(AuthCubit(sl()))
    ..registerSingleton(ProfileCubit(sl()))
    ..registerSingleton(PatientsCubit(sl()));
}
