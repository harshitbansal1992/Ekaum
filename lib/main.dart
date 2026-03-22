import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/locale_provider.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/config/app_config.dart';
import 'core/services/rahu_sandhya_notification_service.dart';
import 'core/components/gradient_background.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up error handling to prevent crashes
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('❌ Flutter Error: ${details.exception}');
    debugPrint('📍 Stack trace: ${details.stack}');
  };
  
  // Handle errors from platform channels
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('❌ Platform Error: $error');
    debugPrint('📍 Stack trace: $stack');
    return true; // Mark as handled to prevent crash
  };
  
  // Initialize Payment Service (non-critical, can fail silently)
  try {
    AppConfig.initializePayment();
  } catch (e) {
    debugPrint('Payment service initialization error: $e');
  }

  // Initialize Rahu Kaal / Sandhya Kaal notification service
  try {
    await RahuSandhyaNotificationService.instance.initialize();
    // Reschedule notifications if user has them enabled (keeps 7-day window updated)
    await RahuSandhyaNotificationService.instance.rescheduleAll();
  } catch (e) {
    debugPrint('Notification service initialization error: $e');
  }
  
  runApp(
    const ProviderScope(
      child: BSLNDApp(),
    ),
  );
}

class BSLNDApp extends ConsumerWidget {
  const BSLNDApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth provider so router rebuilds when auth state changes
    ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);

    final router = AppRouter.createRouter(ref);

    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'BSLND',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode == AppThemeMode.system
          ? ThemeMode.system
          : themeMode == AppThemeMode.dark
              ? ThemeMode.dark
              : ThemeMode.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        return GradientBackground(
          child: child!,
        );
      },
    );
  }
}
