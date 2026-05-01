import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/storage_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

/// Speed Dial Home View
///
/// Main menu screen with a floating action button for quick access
/// to the different detection modes the app offers.
///
/// Architecture: BLoC Pattern — Pure Flutter navigation
/// - Logout dispatches LogoutRequested to AuthBloc
///   → AuthBloc emits AuthUnauthenticated
///   → BlocBuilder in main.dart renders LoginPage declaratively
/// - Screen navigation uses Navigator.pushNamed() with named routes
///   defined in MaterialApp — no GetX dependency
///
/// Why FutureBuilder for the username?
/// StorageService is async-initialized once in main() and then
/// behaves as a singleton. FutureBuilder lets us read the stored
/// username without blocking the widget build or adding it to BLoC state —
/// it's display-only data that doesn't affect auth logic.
class SpeedDialView extends StatelessWidget {
  const SpeedDialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Full-screen background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Darkening overlay for text readability
          Positioned.fill(
            child: Container(
              color: const Color.fromRGBO(0, 0, 0, 0.35),
            ),
          ),

          SafeArea(
            child: Column(
              children: [

                // ── Logout button (top-right) ──
                //
                // Dispatches LogoutRequested to AuthBloc.
                // The BLoC emits AuthUnauthenticated, which BlocBuilder
                // in main.dart picks up and renders LoginPage —
                // no explicit navigation call needed here.
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  context.read<AuthBloc>().add(
                                    const LogoutRequested(),
                                  );
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 28,
                      ),
                      tooltip: 'Logout',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),

                // ── Welcome message ──
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FutureBuilder<StorageService>(
                          future: StorageService.getInstance(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final username =
                                  snapshot.data!.getUsername() ?? 'Guest';
                              return Text(
                                'Welcome, $username',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                            return const Text(
                              'Welcome',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Choose one of the detection modes using the menu button.',
                          style: TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ── Speed Dial navigation menu ──
      //
      // Each child navigates via Navigator.pushNamed() — the standard
      // Flutter imperative navigation API. Routes are registered in
      // MaterialApp in main.dart, keeping route definitions centralized.
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        backgroundColor: Colors.black87,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.image),
            label: 'YOLOv8 Image Detection',
            onTap: () => Navigator.pushNamed(context, AppRoutes.imageDetection),
          ),
          SpeedDialChild(
            child: const Icon(Icons.videocam),
            label: 'YOLOv8 Real-time Detection',
            onTap: () => Navigator.pushNamed(context, AppRoutes.videoDetection),
          ),
          SpeedDialChild(
            child: const Icon(Icons.favorite),
            label: 'Ping FastAPI',
            onTap: () => Navigator.pushNamed(context, AppRoutes.pingTest),
          ),
        ],
      ),
    );
  }
}