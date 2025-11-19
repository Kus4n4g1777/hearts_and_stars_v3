import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../data/models/user_model.dart';
import '../../core/routes/app_routes.dart';

/// Authentication Controller
///
/// Responsibilities:
/// 1. Manage login/logout flow
/// 2. Store user credentials temporarily
/// 3. Communicate with API for authentication
/// 4. Navigate user after successful login
/// 5. Show error messages on failure
///
/// Architecture pattern: MVVM (Model-View-ViewModel)
/// - This is the ViewModel layer
/// - View (LoginView) observes this controller
/// - Model (User, LoginCredentials) represents data
/// - ApiService handles data fetching
///
/// GetX Features Used:
/// - Reactive state (.obs) - auto-updates UI
/// - Dependency injection (Get.put/Get.find)
/// - Navigation (Get.toNamed)
/// - Snackbars (Get.snackbar)
class AuthController extends GetxController {
  // ==================== DEPENDENCIES ====================

  /// API service for backend communication
  ///
  /// Why not create in constructor?
  /// - GetX handles dependency injection
  /// - Service might be shared across controllers
  /// - Easier to mock for testing
  final ApiService _apiService = ApiService();

  // ==================== REACTIVE STATE ====================

  /// Username input field value
  ///
  /// .obs makes it observable (reactive)
  /// When value changes, UI rebuilds automatically
  ///
  /// Usage in View:
  /// ```dart
  /// TextField(
  ///   onChanged: (v) => controller.username.value = v,
  /// )
  /// ```
  final username = ''.obs;

  /// Password input field value
  ///
  /// Security note:
  /// - This is stored in memory temporarily
  /// - Cleared after login attempt
  /// - Not persisted to storage (for security)
  final password = ''.obs;

  /// Loading state for login button
  ///
  /// Why needed?
  /// - Prevents multiple login attempts
  /// - Shows loading indicator to user
  /// - Disables button during API call
  ///
  /// Usage:
  /// ```dart
  /// Obx(() => ElevatedButton(
  ///   onPressed: controller.isLoading.value ? null : controller.login,
  ///   child: controller.isLoading.value
  ///     ? CircularProgressIndicator()
  ///     : Text('Login'),
  /// ))
  /// ```
  final isLoading = false.obs;

  // ==================== AUTHENTICATION METHODS ====================

  /// Login user with credentials
  ///
  /// Flow:
  /// 1. Validate input (not empty)
  /// 2. Trim whitespace (common user error)
  /// 3. Show loading state
  /// 4. Call API service
  /// 5. Handle success: navigate to home
  /// 6. Handle error: show snackbar
  /// 7. Hide loading state
  ///
  /// Why async?
  /// - API calls are asynchronous (network I/O)
  /// - Prevents blocking UI thread
  /// - User can still interact with app while waiting
  Future<void> login() async {
    // Step 1: Validate inputs
    // trim() removes leading/trailing spaces
    final user = username.value.trim();
    final pass = password.value.trim();

    // Check for empty fields
    // Why separate check?
    // - Better UX (specific error message)
    // - Prevents unnecessary API call
    if (user.isEmpty || pass.isEmpty) {
      Get.snackbar(
        'Missing fields',
        'Please enter username and password',
        snackPosition: SnackPosition.BOTTOM, // Better for thumb reach
      );
      return; // Exit early, don't proceed with login
    }

    // Step 2: Show loading state
    // This disables button and shows spinner
    isLoading.value = true;

    try {
      // Step 3: Create credentials object
      // Why not pass strings directly?
      // - Type safety (credentials object has validation)
      // - Easier to add fields later (email, 2FA code, etc.)
      // - Consistent API across different login methods
      final credentials = LoginCredentials(
        username: user,
        password: pass,
      );

      // Step 4: Attempt login via API
      // This makes HTTP POST request to backend
      // Backend validates credentials and returns JWT token
      final response = await _apiService.login(credentials);

      // Step 5: Check if login was successful
      if (response.accessToken.isNotEmpty) {
        // Success! Token is already saved by ApiService

        // Navigate to home screen
        // offNamed removes login screen from navigation stack
        // Why? User shouldn't be able to go back to login after logging in
        Get.offNamed(AppRoutes.home);
      }
    } catch (e) {
      // Step 6: Handle errors
      // Possible errors:
      // - Network error (no internet)
      // - Invalid credentials (wrong password)
      // - Server error (backend down)
      // - Timeout (slow connection)

      Get.snackbar(
        'Login failed',
        e.toString(), // Show error message to user
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      // Step 7: Always hide loading state
      // finally block runs whether success or error
      // Ensures button is re-enabled
      isLoading.value = false;
    }
  }
}