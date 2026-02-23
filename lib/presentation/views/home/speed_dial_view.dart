import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../services/storage_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

/// Speed Dial Home View - BLoC Version
///
/// Main menu screen with floating action button (FAB)
/// for quick access to different detection modes.
///
/// Updated features:
/// - Welcome message with username from storage
/// - Animated speed dial menu
/// - Logout button (BLoC powered)
/// - Routes to different detection screens
///
/// Architecture:
/// - Uses BLoC for logout
/// - Uses GetX for navigation (routes)
/// - Uses FutureBuilder for username (from storage)
class SpeedDialView extends StatelessWidget {
  const SpeedDialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ==================== BACKGROUND IMAGE ====================
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ==================== DARK OVERLAY ====================
          Positioned.fill(
            child: Container(
              color: const Color.fromRGBO(0, 0, 0, 0.35),
            ),
          ),

          // ==================== CONTENT ====================
          SafeArea(
            child: Column(
              children: [
                // ==================== LOGOUT BUTTON ====================
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: IconButton(
                      onPressed: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  // Dispatch LogoutRequested event to BLoC
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

                // ==================== WELCOME MESSAGE ====================
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // FutureBuilder gets username from storage asynchronously
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
                            // Show loading while fetching storage
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

      // ==================== SPEED DIAL MENU ====================
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
            onTap: () => Get.toNamed(AppRoutes.imageDetection),
          ),
          SpeedDialChild(
            child: const Icon(Icons.videocam),
            label: 'YOLOv8 Real-time Detection',
            onTap: () => Get.toNamed(AppRoutes.videoDetection),
          ),
          SpeedDialChild(
            child: const Icon(Icons.favorite),
            label: 'Ping FastAPI',
            onTap: () => Get.toNamed(AppRoutes.pingTest),
          ),
        ],
      ),
    );
  }
}