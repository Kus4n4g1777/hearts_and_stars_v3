/// Application Entry Point
///
/// Bootstraps the app with:
/// - StorageService initialization (local persistence for auth tokens)
/// - AuthBloc provisioned at the root so auth state is globally accessible
/// - Dynamic home routing based on authentication state
///
/// Architecture: BLoC Pattern — Pure Flutter, zero GetX
///
/// Navigation strategy:
/// - Named routes via MaterialApp.routes for static destinations
/// - BlocBuilder at the root handles the auth gate (splash → login → home)
///   so the correct screen is always shown on cold start without redirects
///
/// Why BlocBuilder at the root instead of a route guard?
/// Route guards intercept navigation after the fact.
/// BlocBuilder at home: resolves the correct initial screen declaratively —
/// no flash-of-wrong-screen, no extra navigation events on startup.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// BLoC imports
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/auth/bloc/auth_event.dart';
import 'presentation/auth/bloc/auth_state.dart';

// Page imports
import 'presentation/auth/pages/login_page.dart';
import 'presentation/views/home/speed_dial_view.dart';
import 'presentation/views/detection/image_detection_view.dart';
import 'presentation/views/detection/video_detection_view.dart';
import 'presentation/views/testing/ping_test_view.dart';
import 'core/routes/app_routes.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // StorageService must be initialized before runApp so the AuthBloc
  // can read the stored token synchronously on first state check
  await StorageService.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // AuthBloc is created at the root so auth state is accessible
      // anywhere in the tree without re-providing it per-screen.
      // AppStarted dispatched immediately triggers the initial token check.
      create: (context) => AuthBloc()..add(const AppStarted()),

      child: MaterialApp(
        title: 'Hearts & Stars Detector',
        debugShowCheckedModeBanner: false,

        // ── Named routes for imperative navigation (Navigator.pushNamed) ──
        // Used by AuthBloc after login/logout to transition between screens.
        // Kept minimal — the auth gate below handles cold-start routing.
        routes: {
          AppRoutes.login: (_) => const LoginPage(),
          AppRoutes.home: (_) => const SpeedDialView(),
          AppRoutes.imageDetection: (_) => ImageDetectionView(),
          AppRoutes.videoDetection: (_) => VideoDetectionView(),
          AppRoutes.pingTest: (_) => PingTestView(),
        },

        // ── Auth gate: resolves the correct screen on cold start ──
        //
        // Three possible states on launch:
        // - AuthInitial / AuthLoading: app is checking stored token → splash
        // - AuthAuthenticated: valid token found → go straight to home
        // - Anything else (AuthUnauthenticated): no token → login screen
        //
        // This declarative approach means the correct screen is rendered
        // on the first frame — no redirect flicker, no intermediate route.
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {

            // Splash screen while the stored token check is in progress
            if (state is AuthInitial || state is AuthLoading) {
              return Scaffold(
                body: Stack(
                  children: [
                    // Full-screen background image on splash
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/background.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Darkening overlay for readability
                    Positioned.fill(
                      child: Container(
                        color: const Color.fromRGBO(0, 0, 0, 0.35),
                      ),
                    ),
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.deepOrangeAccent,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Valid session found — skip login entirely
            if (state is AuthAuthenticated) {
              return const SpeedDialView();
            }

            // No session or explicit logout — show login screen
            return const LoginPage();
          },
        ),
      ),
    );
  }
}