import 'package:get/get.dart';
// Update import path
import '../../presentation/auth/pages/login_page.dart';  // ✅ NEW PATH
import '../../presentation/views/detection/image_detection_view.dart';
import '../../presentation/views/detection/video_detection_view.dart';
import '../../presentation/views/home/speed_dial_view.dart';
import '../../presentation/views/testing/ping_test_view.dart';

/// Application Routes Configuration
///
/// Centralized route management using GetX navigation.
///
/// Pattern: Named routes with constants
/// Benefits:
/// - Type safety (compile-time errors)
/// - Easy refactoring (change route in one place)
/// - Clear app structure
/// - Supports deep linking
///
/// Why still using GetX for routing?
/// - Simple, contextless navigation
/// - BLoC handles state, GetX handles navigation
/// - Best of both worlds
class AppRoutes {
  // ==================== ROUTE NAMES ====================

  static const String login = '/login';
  static const String home = '/home';
  static const String imageDetection = '/image-detection';
  static const String videoDetection = '/video-detection';
  static const String pingTest = '/ping-test';

  // ==================== ROUTE DEFINITIONS ====================

  static final routes = [
    GetPage(
      name: login,
      page: () => const LoginPage(),  // ✅ UPDATED
    ),
    GetPage(
      name: home,
      page: () => const SpeedDialView(),
    ),
    GetPage(
      name: imageDetection,
      page: () => const ImageDetectionView(),
    ),
    GetPage(
      name: videoDetection,
      page: () => const VideoDetectionView(),
    ),
    GetPage(
      name: pingTest,
      page: () => const PingTestView(),
    ),
  ];
}