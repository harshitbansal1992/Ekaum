import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';

/// Key for the Shree Mykhana ji hero text in app_settings
const String kHomeHeroTextKey = 'home_hero_text';

/// Keys for daily Ekaum password (updated daily from backoffice)
const String kDailyEkaumPasswordKey = 'daily_ekaum_password';
const String kDailyEkaumDateKey = 'daily_ekaum_date';

/// Default fallback text when API fails or value is empty
const String kDefaultHeroText =
    "लो! ले आया दो हाथों में छल-छल करता पैमाना।\nजितना चाहो मांगो पी लो छोड़ो अब यूं शरमाना।\nप्यास बुझाने को जीवन की इक पैमाना काफी है,\nबच्चे, बूढ़े सबकी खातिर खोल दिया है मयख़ाना।";

/// Provider that fetches the home hero text from the database.
/// Falls back to default text if fetch fails.
final homeHeroTextProvider = FutureProvider<String>((ref) async {
  final value = await ApiService.getSetting(kHomeHeroTextKey);
  return (value != null && value.isNotEmpty) ? value : kDefaultHeroText;
});

/// Model for daily Ekaum password with date
class DailyEkaum {
  final String password;
  final String date;

  const DailyEkaum({required this.password, required this.date});
}

/// Feature flag keys (must match backend app_settings keys)
const Map<String, bool> kDefaultFeatureFlags = {
  'feature_kundli_lite_enabled': true,
  'feature_nadi_dosh_enabled': true,
  'feature_rahu_kaal_enabled': true,
  'feature_avdhan_enabled': true,
  'feature_video_satsang_enabled': true,
  'feature_panchang_enabled': true,
  'feature_mantra_notes_enabled': true,
  'feature_samagam_enabled': true,
  'feature_patrika_enabled': true,
  'feature_pooja_items_enabled': true,
  'feature_paath_services_enabled': true,
  'feature_donation_enabled': true,
  'feature_announcements_enabled': true,
  'feature_daily_ekaum_enabled': true,
  'feature_social_activities_enabled': true,
  'feature_blog_enabled': true,
  'feature_bslnd_centers_enabled': true,
};

/// Provider for announcements (Vishesh Sandesh - home section)
final announcementsProvider = FutureProvider<List<dynamic>>((ref) async {
  final data = await ApiService.getAnnouncements(limit: 5);
  return data;
});

/// Provider for 3 latest upcoming samagam events (home hero section)
final upcomingSamagamsProvider = FutureProvider<List<dynamic>>((ref) async {
  final data = await ApiService.getUpcomingSamagams(limit: 3);
  return data;
});

/// Provider for today's Hindu panchang (Tithi, Nakshatra, Vara, Paksha, etc.)
final panchangProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return ApiService.getPanchangCurrentDay();
});

/// Provider that fetches feature flags from backoffice (enable/disable app sections)
final featureFlagsProvider = FutureProvider<Map<String, bool>>((ref) async {
  final flags = await ApiService.getFeatureFlags();
  return {...kDefaultFeatureFlags, ...flags};
});

/// Provider that fetches the daily Ekaum password and date from the database.
/// Updated daily from backoffice via PUT /api/settings/daily_ekaum_password and daily_ekaum_date
final dailyEkaumProvider = FutureProvider<DailyEkaum?>((ref) async {
  final password = await ApiService.getSetting(kDailyEkaumPasswordKey);
  final date = await ApiService.getSetting(kDailyEkaumDateKey);
  if (password != null && password.isNotEmpty) {
    return DailyEkaum(
      password: password,
      date: date ?? DateTime.now().toIso8601String().split('T').first,
    );
  }
  return null;
});
