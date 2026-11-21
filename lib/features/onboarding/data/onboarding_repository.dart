import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingSlide {
  const OnboardingSlide({required this.title, required this.body, this.imageUrl, this.titleKey, this.bodyKey});

  /// Text from the server (English only).
  final String title;
  final String body;
  final String? imageUrl;

  /// Built-in l10n keys for the same slide, used for Arabic and when offline.
  final String? titleKey;
  final String? bodyKey;
}

class OnboardingRepository {
  OnboardingRepository(this._prefs, this._client);

  static const _key = 'onboarding_seen';
  final SharedPreferences _prefs;
  final SupabaseClient _client;

  bool get seen => _prefs.getBool(_key) ?? false;
  Future<void> markSeen() => _prefs.setBool(_key, true);

  /// Built-in copy recovered from the APK, used as the fallback.
  static const fallback = [
    OnboardingSlide(
      title: 'Advanced ECG Analysis at Your Fingertips',
      body: 'Detect abnormalities early and get accurate results with advanced AI analysis.',
      titleKey: 'onboarding_1_title',
      bodyKey: 'onboarding_1_body',
    ),
    OnboardingSlide(
      title: 'AI-Powered ECG Interpretation',
      body: 'AI-Powered insights for faster, smarter, and more confident cardiac care.',
      titleKey: 'onboarding_2_title',
      bodyKey: 'onboarding_2_body',
    ),
    OnboardingSlide(
      title: 'Better Decisions Healthier Tomorrows',
      body: 'Empower healthcare professionals with reliable data, actionable insights, and improved patient outcomes.',
      titleKey: 'onboarding_3_title',
      bodyKey: 'onboarding_3_body',
    ),
  ];

  /// onBoarding(id, created_at, title, content, image, orders, is_active) — is_active is nullable; NULL counts as active.
  Future<List<OnboardingSlide>> fetchSlides() async {
    final rows = await _client.from('onBoarding').select('title, content, image').or('is_active.is.null,is_active.eq.true').order('orders', ascending: true);
    if (rows.isEmpty) return fallback;
    return [
      for (final (i, r) in rows.indexed)
        OnboardingSlide(
          title: r['title'] as String? ?? '',
          body: r['content'] as String? ?? '',
          imageUrl: r['image'] as String?,
          titleKey: i < fallback.length ? fallback[i].titleKey : null,
          bodyKey: i < fallback.length ? fallback[i].bodyKey : null,
        ),
    ];
  }
}
