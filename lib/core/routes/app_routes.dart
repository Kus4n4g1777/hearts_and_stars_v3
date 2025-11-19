import 'package:get/get.dart';
import '../../presentation/views/auth/login_view.dart';
import '../../presentation/views/home/speed_dial_view.dart';
import '../../presentation/views/detection/image_detection_view.dart';
import '../../presentation/views/detection/video_detection_view.dart';
import '../../presentation/views/testing/ping_test_view.dart';

/// Centralized Route Management
///
/// What is routing?
/// - Navigation between screens (pages/views)
/// - Like URLs in a web app: /login, /home, /profile
/// - In mobile: named routes instead of URLs
///
/// Why centralize routes?
/// - Single source of truth for all navigation
/// - Easy to see app's screen hierarchy
/// - No magic strings in Get.toNamed() calls
/// - Type-safe navigation (compile-time errors vs runtime)
/// - Easy to add middleware (auth checks, analytics)
///
/// Design pattern: Route Registry
/// - All routes defined in one place
/// - GetX manages navigation stack
/// - Automatic memory management (controllers disposed)
class AppRoutes {
  /// Private constructor - this is a static utility class
  AppRoutes._();

  // ==================== ROUTE NAMES ====================
  // These are used throughout the app for navigation

  /// Login screen route
  ///
  /// This is the initial route (app starts here)
  ///
  /// Usage:
  /// ```dart
  /// Get.toNamed(AppRoutes.login);
  /// Get.offAllNamed(AppRoutes.login); // Clear navigation stack
  /// ```
  static const String login = '/';

  /// Home screen (speed dial menu)
  ///
  /// Main screen after login
  /// Shows menu to access different features
  static const String home = '/speed-dials';

  /// Image detection screen
  ///
  /// Upload image → detect objects → show results
  /// (Currently stub, will be implemented)
  static const String imageDetection = '/image-detect';

  /// Video detection screen
  ///
  /// Real-time camera → send frames → show bounding boxes
  /// Main feature of the app
  static const String videoDetection = '/video-detect';

  /// API testing screen
  ///
  /// Simple ping test to verify backend connectivity
  /// Useful for debugging
  static const String pingTest = '/ping-test';

  // ==================== ROUTE CONFIGURATION ====================

  /// List of all routes in the app
  ///
  /// GetX requires this format:
  /// - name: route string
  /// - page: function that returns widget
  /// - Optional: transition, middleware, bindings
  ///
  /// Why function that returns widget?
  /// - Lazy loading: widget created only when needed
  /// - Fresh state: new instance on each navigation
  /// - Memory efficient: old instances garbage collected
  ///
  /// Route types:
  ///
  /// 1. Get.toNamed() - Push new screen on stack
  ///    [Login] → [Home] → [Video]
  ///    Back button: Video → Home → Login
  ///
  /// 2. Get.offNamed() - Replace current screen
  ///    [Login] → [Home]
  ///    Back button: exit app (Login not in stack)
  ///
  /// 3. Get.offAllNamed() - Clear stack and go to route
  ///    [Login] → [Home] → [Video] → Get.offAllNamed('/login')
  ///    Result: [Login]
  ///    Back button: exit app
  ///
  /// When to use each?
  /// - toNamed: Normal navigation (can go back)
  /// - offNamed: After login (can't go back to login)
  /// - offAllNamed: Logout (clear everything)
  static final routes = [
    // Login screen - initial route
    GetPage(
      name: login,
      page: () => LoginView(),
      // No transition specified = default fade
    ),

    // Home screen - after successful login
    GetPage(
      name: home,
      page: () => const SpeedDialView(),
      // transition: Transition.rightToLeft, // Could add custom transition
    ),

    // Image detection screen
    GetPage(
      name: imageDetection,
      page: () => const ImageDetectionView(),
    ),

    // Video detection screen (main feature)
    GetPage(
      name: videoDetection,
      page: () => VideoDetectionView(),
      // Could add middleware here:
      // middlewares: [AuthMiddleware()], // Check if logged in
    ),

    // Ping test screen (debugging)
    GetPage(
      name: pingTest,
      page: () => const PingTestView(),
    ),
  ];

  // ==================== NAVIGATION HELPERS ====================
  // Optional: Add helper methods for common navigation patterns

  /// Navigate to home screen after login
  /// Removes login from stack (user can't go back)
  static void goToHome() {
    Get.offNamed(home);
  }

  /// Logout: clear all screens and go to login
  /// User starts fresh
  static void logout() {
    Get.offAllNamed(login);
  }

/// Example: Auth guard
/// Check if user is logged in before accessing protected route
///
/// Usage:
/// ```dart
/// if (AppRoutes.isLoggedIn()) {
///   Get.toNamed(AppRoutes.videoDetection);
/// } else {
///   Get.toNamed(AppRoutes.login);
/// }
/// ```
// static bool isLoggedIn() {
//   final storage = Get.find<StorageService>();
//   return storage.hasToken;
// }
}