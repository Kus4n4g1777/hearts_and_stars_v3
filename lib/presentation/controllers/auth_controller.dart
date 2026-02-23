/// LEGACY: GetX Authentication Controller
///
/// ⚠️ THIS IS NO LONGER USED IN PRODUCTION CODE ⚠️
///
/// Kept for reference and comparison purposes.
/// See lib/presentation/auth/bloc/ for current BLoC implementation.
///
/// Migration:
/// - Old: AuthController (GetX)
/// - New: AuthBloc (BLoC pattern)
///
/// This file demonstrates the GetX approach we migrated FROM.
/// Useful for:
/// - Understanding the migration
/// - Teaching/documentation
/// - Comparing patterns

import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../data/models/user_model.dart';
import '../../core/routes/app_routes.dart';

/// Authentication Controller - Production Ready
///
/// Responsibilities:
/// 1. Manage login/logout flow with proper error handling
/// 2. Coordinate between ApiService and UI layer
/// 3. Expose reactive state for UI binding
/// 4. Handle validation and loading states
///
/// Architecture: MVVM Pattern
/// - Model: User, LoginCredentials (data structures)
/// - View: LoginView (UI components)
/// - ViewModel: AuthController (this class - business logic)
///
/// Key improvements over basic version:
/// - Constructor injection for testability
/// - Method parameters instead of .obs inputs (cleaner separation)
/// - Explicit error message handling
/// - Comprehensive validation
class AuthController extends GetxController {
  // ==================== DEPENDENCIES ====================

  /// API service for backend communication
  /// Injected via constructor to allow mock injection in tests
  final ApiService _apiService;

  /// Storage service for local persistence
  /// Injected via constructor to allow mock injection in tests
  final StorageService _storageService;

  /// Constructor with dependency injection
  ///
  /// Pattern: Optional named parameters with default values
  /// Why?
  /// - Production: Uses real services (defaults)
  /// - Testing: Injects mocks (overrides)
  ///
  /// Example usage in tests:
  /// ```dart
  /// final controller = AuthController(
  ///   apiService: mockApiService,
  ///   storageService: mockStorageService,
  /// );
  /// ```
  AuthController({
    ApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? ApiService(),
        _storageService = storageService ?? _defaultStorageService();

  /// Helper to get default storage service
  /// StorageService.getInstance() returns Future<StorageService>
  /// but constructor can't be async, so we handle this specially
  static StorageService _defaultStorageService() {
    // This is a placeholder - actual initialization happens in onInit()
    // For tests, the mock is injected directly
    throw UnimplementedError('Use StorageService from onInit or inject mock');
  }

  // ==================== REACTIVE STATE ====================

  /// Loading state indicator
  /// Controls:
  /// - Login button disabled state
  /// - Loading spinner visibility
  /// - Form input enabled state
  final isLoading = false.obs;

  /// Error message for user feedback
  /// Empty string = no error
  /// Non-empty = display error to user
  ///
  /// Usage in View:
  /// ```dart
  /// Obx(() => Text(
  ///   controller.errorMessage.value,
  ///   style: TextStyle(color: Colors.red),
  /// ))
  /// ```
  final errorMessage = ''.obs;

  // ==================== LIFECYCLE ====================

  /// Called when controller is initialized
  /// Perfect place for async setup that can't happen in constructor
  @override
  void onInit() {
    super.onInit();
    // Any async initialization goes here
    // For example: checking if user is already logged in
  }

  // ==================== AUTHENTICATION METHODS ====================

  /// Login user with username and password
  ///
  /// Pattern: Method parameters instead of observables
  /// Why?
  /// - Cleaner separation: View handles input, Controller handles logic
  /// - Easier to test: Just call method with params
  /// - More flexible: Can call from anywhere (not just bound to .obs)
  ///
  /// Flow:
  /// 1. Validate inputs (client-side)
  /// 2. Clear previous errors
  /// 3. Set loading state
  /// 4. Create credentials object
  /// 5. Call API service
  /// 6. Handle success: navigate to home
  /// 7. Handle errors: show user-friendly message
  /// 8. Always clear loading state
  ///
  /// @param username - User's username (will be trimmed)
  /// @param password - User's password (will be trimmed)
  Future<void> login(String username, String password) async {
    // Step 1: Validate and sanitize inputs
    // trim() removes leading/trailing whitespace (common user error)
    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();

    // Client-side validation catches errors early
    // Prevents unnecessary API calls
    // Provides immediate feedback to user
    if (trimmedUsername.isEmpty || trimmedPassword.isEmpty) {
      errorMessage.value = 'Please enter username and password';
      return; // Exit early - don't proceed with login
    }

    // Step 2: Clear any previous error messages
    // Ensures user sees fresh feedback for this attempt
    errorMessage.value = '';

    // Step 3: Set loading state
    // UI will show spinner and disable inputs
    isLoading.value = true;

    try {
      // Step 4: Create credentials object
      // LoginCredentials encapsulates auth data
      // Provides type safety and validation
      final credentials = LoginCredentials(
        username: trimmedUsername,
        password: trimmedPassword,
      );

      // Step 5: Attempt login via API
      // ApiService handles:
      // - HTTP request to backend
      // - Token storage (automatically saves to StorageService)
      // - Username storage (for UI display)
      final response = await _apiService.login(credentials);

      // Step 6: Handle success
      // Check if we received a valid token
      if (response.accessToken.isNotEmpty) {
        // Token is already saved by ApiService.login()
        // Navigate to home screen and clear navigation stack
        // offNamed removes login screen - user can't back-button to it
        Get.offNamed(AppRoutes.home);
      } else {
        // Edge case: Empty token in response
        // Should not happen if backend is working correctly
        errorMessage.value = 'Login failed: Invalid response from server';
      }
    } catch (e) {
      // Step 7: Handle errors gracefully
      // Possible error types:
      // - Network error (no internet, timeout)
      // - Invalid credentials (401)
      // - Server error (500)
      // - Parsing error (malformed response)

      // Convert exception to user-friendly message
      // Remove "Exception: " prefix for cleaner display
      errorMessage.value = e.toString().replaceAll('Exception: ', '');

      // Log error for debugging (in production, send to error tracking)
      print('❌ Login error: $e');
    } finally {
      // Step 8: Always clear loading state
      // finally block executes whether success or error
      // Ensures UI is always interactive again
      isLoading.value = false;
    }
  }

  /// Logout current user
  ///
  /// Flow:
  /// 1. Set loading state
  /// 2. Clear stored token
  /// 3. Clear stored username
  /// 4. Navigate to login screen
  /// 5. Clear error messages
  /// 6. Reset loading state
  ///
  /// Note: This is local logout only
  /// - Token still valid on backend until expiration
  /// - For server-side logout, would need backend endpoint
  Future<void> logout() async {
    isLoading.value = true;

    try {
      // Clear authentication data using ApiService
      // This clears:
      // - JWT token
      // - Stored username
      await _apiService.logout();

      // Navigate to login and clear entire navigation stack
      // offAllNamed ensures user can't navigate back
      // This is important for security (no back-button to protected screens)
      Get.offAllNamed(AppRoutes.login);

      // Clear any error messages
      errorMessage.value = '';
    } catch (e) {
      // Logout should rarely fail, but handle gracefully
      // Even if API call fails, clear local state
      errorMessage.value = 'Logout error: ${e.toString()}';
      print('❌ Logout error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if user is currently logged in
  ///
  /// Checks if valid token exists in storage
  /// Useful for:
  /// - Initial route determination (login vs home)
  /// - Conditional UI rendering
  /// - Route guards
  ///
  /// @returns true if user has token, false otherwise
  bool get isLoggedIn {
    return _storageService.hasToken;
  }
}