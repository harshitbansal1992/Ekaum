import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'core/components/gradient_background.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

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
    
    final router = AppRouter.createRouter(ref);
    
    return MaterialApp.router(
      title: 'BSLND',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        return GradientBackground(
          child: child!,
        );
      },
    );
  }
}
