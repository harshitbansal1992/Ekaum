import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/main_shell_page.dart';
import '../../features/home/presentation/pages/edit_profile_page.dart';
import '../../features/nadi_dosh/presentation/pages/nadi_dosh_page.dart';
import '../../features/kundli_lite/presentation/pages/kundli_lite_page.dart';
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
import '../../features/paath_services/presentation/pages/paath_details_page.dart';
import '../../features/paath_services/presentation/pages/paath_form_detail_page.dart';
import '../../features/paath_services/data/models/paath_service.dart';
import '../../features/donation/presentation/pages/donation_page.dart';
import '../../features/mantra_notes/presentation/pages/mantra_note_form_page.dart';
import '../../features/mantra_notes/presentation/pages/mantra_notes_list_page.dart';
import '../../features/mantra_notes/data/models/mantra_note.dart';
import '../../features/payment/presentation/pages/payment_status_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/video_satsang/presentation/pages/video_satsang_list_page.dart';
import '../../features/video_satsang/presentation/pages/video_satsang_detail_page.dart';
import '../../features/video_satsang/data/models/video_satsang_item.dart';
import '../../features/social_activities/presentation/pages/social_activities_page.dart';
import '../../features/blog/presentation/pages/blog_page.dart';
import '../../features/bslnd_centers/presentation/pages/bslnd_centers_page.dart';

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
        builder: (context, state) => const MainShellPage(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/nadi-dosh',
        builder: (context, state) => const NadiDoshPage(),
      ),
      GoRoute(
        path: '/kundli-lite',
        builder: (context, state) => const KundliLitePage(),
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
        path: '/paath-details',
        builder: (context, state) => const PaathDetailsPage(),
      ),
      GoRoute(
        path: '/paath-details/:id',
        builder: (context, state) {
          final formId = state.pathParameters['id']!;
          return PaathFormDetailPage(formId: formId);
        },
      ),
      GoRoute(
        path: '/donation',
        builder: (context, state) => const DonationPage(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/video-satsang',
        builder: (context, state) => const VideoSatsangListPage(),
      ),
      GoRoute(
        path: '/video-satsang/:id',
        builder: (context, state) {
          final video = state.extra as VideoSatsangItem;
          return VideoSatsangDetailPage(video: video);
        },
      ),
      GoRoute(
        path: '/social-activities',
        builder: (context, state) => const SocialActivitiesPage(),
      ),
      GoRoute(
        path: '/blog',
        builder: (context, state) => const BlogPage(),
      ),
      GoRoute(
        path: '/bslnd-centers',
        builder: (context, state) => const BslndCentersPage(),
      ),
      GoRoute(
        path: '/mantra-notes',
        builder: (context, state) => const MantraNotesListPage(),
      ),
      GoRoute(
        path: '/mantra-notes/new',
        builder: (context, state) => const MantraNoteFormPage(),
      ),
      GoRoute(
        path: '/mantra-notes/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final note = state.extra is MantraNote ? state.extra as MantraNote : null;
          return MantraNoteFormPage(noteId: id == 'new' ? null : id, existingNote: note);
        },
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
