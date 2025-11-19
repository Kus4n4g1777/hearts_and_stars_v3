import '../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

/// Authentication Repository
///
/// What is Repository Pattern?
/// - Abstraction layer between data sources and business logic
/// - Controller doesn't know WHERE data comes from (API, DB, cache)
/// - Controller only knows WHAT data it needs
///
/// Why use Repository?
/// - Single Responsibility: data fetching separated from business logic
/// - Easy to test: mock repository instead of real API
/// - Easy to switch data sources: API → local DB without changing controller
/// - Caching logic in one place
///
/// Real-world analogy:
/// - Controller = Restaurant customer (orders food)
/// - Repository = Waiter (brings food)
/// - ApiService = Kitchen (prepares food)
/// Customer doesn't go to kitchen, waiter handles it
///
/// Example WITHOUT repository:
/// ```dart
/// class AuthController {
///   void login() async {
///     final response = await http.post(...);  // ❌ Controller knows HTTP details
///     final token = jsonDecode(response.body)['token'];
///     await SharedPreferences.getInstance().setString('token', token);
///   }
/// }
/// ```
///
/// Example WITH repository:
/// ```dart
/// class AuthController {
///   void login() async {
///     final user = await authRepo.login(credentials);  // ✅ Simple, clean
///   }
/// }
/// ```
class AuthRepository {
  // ==================== DEPENDENCIES ====================

  /// API service for network calls
  final ApiService _apiService;

  /// Storage service for local persistence
  final StorageService _storageService;

  /// Constructor with dependency injection
  ///
  /// Why inject dependencies?
  /// - Easy to test (pass mock services)
  /// - Flexible (can swap implementations)
  /// - Clear dependencies (visible in constructor)
  AuthRepository({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  // ==================== AUTHENTICATION OPERATIONS ====================

  /// Login user with credentials
  ///
  /// What this does:
  /// 1. Call API to authenticate
  /// 2. Save token to local storage
  /// 3. Return user data
  ///
  /// Why in repository?
  /// - Controller doesn't need to know about storage
  /// - All login logic in one place
  /// - Easy to add caching, retry logic, etc.
  ///
  /// @param credentials - Username and password
  /// @returns LoginResponse with token
  /// @throws Exception if login fails
  Future<LoginResponse> login(LoginCredentials credentials) async {
    // Call API service
    final response = await _apiService.login(credentials);

    // Token is already saved by ApiService
    // Could add additional logic here:
    // - Cache user data
    // - Log analytics event
    // - Update last login timestamp

    return response;
  }

  /// Validate if current session is still valid
  ///
  /// Use cases:
  /// - Check on app startup (is user logged in?)
  /// - Before accessing protected resources
  /// - Periodic validation (every 5 minutes)
  ///
  /// @returns true if token is valid, false otherwise
  Future<bool> validateSession() async {
    try {
      return await _apiService.validateToken();
    } catch (e) {
      return false;
    }
  }

  /// Logout user
  ///
  /// What this does:
  /// 1. Clear token from storage
  /// 2. Clear any cached user data
  /// 3. Reset state
  ///
  /// Why in repository?
  /// - Centralized logout logic
  /// - Ensures all user data is cleared
  /// - Controller just calls one method
  Future<void> logout() async {
    await _apiService.logout();

    // Could add:
    // - Clear cached data
    // - Cancel pending requests
    // - Log analytics event
  }

  /// Get current user from storage
  ///
  /// Use case:
  /// - Show username in UI without API call
  /// - Check if user is logged in
  ///
  /// @returns username or null if not logged in
  Future<String?> getCurrentUsername() async {
    return _storageService.getUsername();
  }

  /// Check if user has valid token
  ///
  /// Quick check without API call
  /// Doesn't validate token, just checks existence
  ///
  /// @returns true if token exists locally
  Future<bool> hasToken() async {
    return _storageService.hasToken;
  }
}