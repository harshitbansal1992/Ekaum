import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kLocaleKey = 'app_locale';

/// Supported app locales: English, Hindi, Punjabi, Telugu, Gujarati
const List<Locale> supportedLocales = [
  Locale('en'),
  Locale('hi'),
  Locale('pa'),
  Locale('te'),
  Locale('gu'),
];

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocaleKey);
    if (code != null) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale != null) {
      await prefs.setString(_kLocaleKey, locale.languageCode);
    } else {
      await prefs.remove(_kLocaleKey);
    }
  }
}

extension LocaleDisplayExtension on Locale {
  /// Native names for display in the language picker
  String get displayName {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      case 'pa':
        return 'ਪੰਜਾਬੀ';
      case 'te':
        return 'తెలుగు';
      case 'gu':
        return 'ગુજરાતી';
      default:
        return languageCode;
    }
  }
}
