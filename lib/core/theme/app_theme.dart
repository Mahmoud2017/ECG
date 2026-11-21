import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand colours sampled from assets/images/logo.png (blue gradient heart + navy wordmark).
class AppColors {
  AppColors._();

  static const primary = Color(0xFF1E5BF0);
  static const primaryLight = Color(0xFF14B8F5);
  static const navy = Color(0xFF0B1B3A);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
  static const darkBg = Color(0xFF0B1220);
  static const darkSurface = Color(0xFF141C2E);

  /// Solid blue of the app's buttons and headers (from the design screenshots).
  static const brand = Color(0xFF1F7AF0);
  static const fieldFill = Color(0xFFF4F6FA);
  static const fieldBorder = Color(0xFFE5E9F0);

  static const gradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData light(Locale locale) => _build(Brightness.light, locale);
  static ThemeData dark(Locale locale) => _build(Brightness.dark, locale);

  static ThemeData _build(Brightness brightness, Locale locale) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      brightness: brightness,
      surface: isDark ? AppColors.darkSurface : Colors.white,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );
    final textTheme = base.textTheme.apply(
      bodyColor: isDark ? Colors.white : AppColors.navy,
      displayColor: isDark ? Colors.white : AppColors.navy,
    );
    final radius = BorderRadius.circular(12);

    return base.copyWith(
      scaffoldBackgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF6F8FC),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        foregroundColor: isDark ? Colors.white : AppColors.navy,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF9AA3B2)),
        prefixIconColor: isDark ? Colors.white60 : const Color(0xFF8A93A3),
        suffixIconColor: isDark ? Colors.white60 : const Color(0xFF8A93A3),
        border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: isDark ? scheme.outlineVariant : AppColors.fieldBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: isDark ? scheme.outlineVariant : AppColors.fieldBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: const BorderSide(color: AppColors.brand, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: scheme.error)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
