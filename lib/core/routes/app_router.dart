import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/nadi_dosh/presentation/pages/nadi_dosh_page.dart';
import '../../features/rahu_kaal/presentation/pages/rahu_kaal_page.dart';
import '../../features/avdhan/presentation/pages/avdhan_list_page.dart';
import '../../features/avdhan/presentation/pages/avdhan_player_page.dart';
import '../../features/avdhan/data/models/avdhan_audio.dart';
import '../../features/samagam/presentation/pages/samagam_list_page.dart';
import '../../features/patrika/presentation/pages/patrika_list_page.dart';
import '../../features/patrika/presentation/pages/patrika_viewer_page.dart';
import '../../features/patrika/data/models/patrika_issue.dart';
import '../../features/pooja_items/presentation/pages/pooja_items_page.dart';
import '../../features/paath_services/presentation/pages/paath_services_page.dart';
import '../../features/paath_services/presentation/pages/paath_form_page.dart';
import '../../features/paath_services/data/models/paath_service.dart';
import '../../features/donation/presentation/pages/donation_page.dart';
import '../../features/payment/presentation/pages/payment_status_page.dart';

class AppRouter {
  static GoRouter createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final authState = ref.read(authProvider);
        
        // Wait for auth initialization to complete
        if (authState.isLoading) {
          return null; // Don't redirect while loading
        }
        
        final isLoggedIn = authState.user != null;
        final isGoingToLogin = state.matchedLocation == '/login' || 
                               state.matchedLocation == '/register';
        
        // If user is logged in and trying to go to login/register, redirect to home
        if (isLoggedIn && isGoingToLogin) {
          return '/home';
        }
        
        // If user is not logged in and trying to access protected routes, redirect to login
        if (!isLoggedIn && !isGoingToLogin) {
          return '/login';
        }
        
        // Allow navigation
        return null;
      },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/nadi-dosh',
        builder: (context, state) => const NadiDoshPage(),
      ),
      GoRoute(
        path: '/rahu-kaal',
        builder: (context, state) => const RahuKaalPage(),
      ),
      GoRoute(
        path: '/avdhan',
        builder: (context, state) => const AvdhanListPage(),
      ),
      GoRoute(
        path: '/avdhan/:id',
        builder: (context, state) {
          final audio = state.extra as AvdhanAudio;
          return AvdhanPlayerPage(audio: audio);
        },
      ),
      GoRoute(
        path: '/samagam',
        builder: (context, state) => const SamagamListPage(),
      ),
      GoRoute(
        path: '/patrika',
        builder: (context, state) => const PatrikaListPage(),
      ),
      GoRoute(
        path: '/patrika/:id',
        builder: (context, state) {
          final issue = state.extra as PatrikaIssue;
          return PatrikaViewerPage(issue: issue);
        },
      ),
      GoRoute(
        path: '/pooja-items',
        builder: (context, state) => const PoojaItemsPage(),
      ),
      GoRoute(
        path: '/paath-services',
        builder: (context, state) => const PaathServicesPage(),
      ),
      GoRoute(
        path: '/paath-form',
        builder: (context, state) {
          final service = state.extra as PaathService;
          return PaathFormPage(service: service);
        },
      ),
      GoRoute(
        path: '/donation',
        builder: (context, state) => const DonationPage(),
      ),
      GoRoute(
        path: '/payment/:type',
        builder: (context, state) {
          final type = state.pathParameters['type'] ?? 'unknown';
          final paymentId = state.uri.queryParameters['payment_id'];
          final status = state.uri.queryParameters['payment_status'];
          return PaymentStatusPage(
            paymentType: type,
            paymentId: paymentId,
            status: status,
          );
        },
      ),
    ],
    );
  }
}
