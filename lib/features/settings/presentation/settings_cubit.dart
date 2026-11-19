import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState extends Equatable {
  const SettingsState({required this.locale, required this.darkMode});

  final Locale locale;
  final bool darkMode;

  SettingsState copyWith({Locale? locale, bool? darkMode}) =>
      SettingsState(locale: locale ?? this.locale, darkMode: darkMode ?? this.darkMode);

  @override
  List<Object?> get props => [locale, darkMode];
}

/// Persists language + dark mode in SharedPreferences (keys: locale, dark_mode).
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._prefs)
      : super(SettingsState(
          locale: Locale(_prefs.getString('locale') ?? _deviceLang()),
          darkMode: _prefs.getBool('dark_mode') ?? false,
        ));

  final SharedPreferences _prefs;

  static String _deviceLang() =>
      PlatformDispatcher.instance.locale.languageCode == 'ar' ? 'ar' : 'en';

  Future<void> setLocale(String code) async {
    await _prefs.setString('locale', code);
    emit(state.copyWith(locale: Locale(code)));
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('dark_mode', value);
    emit(state.copyWith(darkMode: value));
  }
}
