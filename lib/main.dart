import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/routes/app_routes.dart';
import 'services/storage_service.dart';

/// Application entry point
///
/// This is the first function that runs when app starts
///
/// Flow:
/// 1. main() called by Flutter framework
/// 2. Initialize services (async operations)
/// 3. Run the app (MyApp widget)
///
/// Why async main?
/// - Need to initialize SharedPreferences before app starts
/// - Ensures storage is ready before any code tries to use it
/// - Prevents "SharedPreferences not initialized" errors
void main() async {
  // ==================== FLUTTER INITIALIZATION ====================

  /// Ensure Flutter framework is fully initialized
  ///
  /// Why needed before async operations?
  /// - async main() requires this
  /// - Initializes bindings for platform channels
  /// - Must be called before any async code in main()
  ///
  /// Without this line:
  /// - Runtime error: "ServicesBinding not initialized"
  /// - Platform channels won't work
  /// - Cannot access native features
  WidgetsFlutterBinding.ensureInitialized();

  // ==================== SERVICE INITIALIZATION ====================

  /// Initialize storage service (SharedPreferences)
  ///
  /// Why initialize here instead of lazy?
  /// - Ensures storage is ready before any screen loads
  /// - Prevents race conditions (trying to read token before init)
  /// - Fails fast if storage has issues
  ///
  /// What this does:
  /// - Loads SharedPreferences from disk
  /// - Creates singleton instance
  /// - Makes it available to entire app
  ///
  /// Alternative approach (lazy loading):
  /// - Initialize when first needed
  /// - Faster app startup
  /// - But adds complexity (must handle "not initialized" state)
  await StorageService.getInstance();

  // ==================== RUN APP ====================

  /// Start the Flutter app
  ///
  /// Creates widget tree starting from MyApp
  /// Shows first screen (determined by initialRoute)
  runApp(const MyApp());
}

/// Root widget of the application
///
/// This widget:
/// - Configures the entire app (theme, routes, etc.)
/// - Is stateless (doesn't change after creation)
/// - Lives for entire app lifecycle
///
/// Design pattern: Configuration Object
/// - All app-wide settings in one place
/// - Easy to modify theme, routes, etc.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// GetMaterialApp - GetX's replacement for MaterialApp
    ///
    /// Why GetMaterialApp vs MaterialApp?
    /// - Built-in route management (Get.toNamed, Get.back)
    /// - Dependency injection (Get.put, Get.find)
    /// - No need for BuildContext for navigation
    /// - Snackbars without context (Get.snackbar)
    /// - Dialogs without context (Get.dialog)
    ///
    /// Standard MaterialApp requires:
    /// ```dart
    /// Navigator.of(context).pushNamed('/route');
    /// ```
    ///
    /// GetX simplifies to:
    /// ```dart
    /// Get.toNamed('/route');
    /// ```
    return GetMaterialApp(
      // ==================== APP CONFIGURATION ====================

      /// Hide debug banner (red "DEBUG" in top-right)
      ///
      /// Why false?
      /// - Cleaner screenshots/videos
      /// - More professional look
      /// - Banner is useless after you know it's debug mode
      debugShowCheckedModeBanner: false,

      /// App name (shown in task switcher, notifications, etc.)
      title: 'Hearts & Stars Detector',

      // ==================== ROUTING ====================

      /// Initial route when app starts
      ///
      /// This is the first screen user sees
      /// Format: matches route names in AppRoutes
      ///
      /// Flow:
      /// 1. App starts → shows login screen
      /// 2. User logs in → navigates to home
      /// 3. User can't go back to login (removed from stack)
      initialRoute: AppRoutes.login,

      /// List of all available routes
      ///
      /// Defined in AppRoutes.routes
      /// Each route maps name → widget
      ///
      /// Benefits:
      /// - Centralized route management
      /// - Type-safe navigation (compile-time errors)
      /// - Easy to add middleware (auth guards, analytics)
      /// - Clear app structure at a glance
      getPages: AppRoutes.routes,

      // ==================== OPTIONAL CONFIGURATIONS ====================

      /// Default page transition animation
      /// Options: fadeIn, rightToLeft, leftToRight, zoom, etc.
      ///
      /// Commented out = uses default (platform-specific)
      /// - Android: slide up
      /// - iOS: slide from right
      // defaultTransition: Transition.fadeIn,

      /// Transition duration
      /// Default is fine for most cases
      // transitionDuration: const Duration(milliseconds: 300),

      /// App theme (colors, fonts, etc.)
      ///
      /// Could customize:
      /// ```dart
      /// theme: ThemeData(
      ///   primarySwatch: Colors.deepOrange,
      ///   scaffoldBackgroundColor: Colors.black,
      ///   // ... more theme settings
      /// ),
      /// ```
    );
  }
}