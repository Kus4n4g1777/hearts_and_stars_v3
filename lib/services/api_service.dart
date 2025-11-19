import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../core/constants/api_constants.dart';
import '../data/models/user_model.dart';
import 'storage_service.dart';

/// API Service - Handles all HTTP requests to the backend
///
/// This service is responsible for:
/// - Making HTTP requests (GET, POST, PUT, DELETE)
/// - Handling authentication tokens
/// - Logging requests and responses
/// - Error handling
///
/// Why separate this?
/// - Single Responsibility Principle: only handles HTTP communication
/// - Easy to test: can mock HTTP responses
/// - Easy to switch backends: just change the base URL
class ApiService {
  // Logger for debugging and monitoring
  final Logger _logger = Logger();

  // Storage service to persist JWT tokens
  late final StorageService _storage;

  /// Constructor
  /// Initializes the storage service asynchronously
  ApiService() {
    _initStorage();
  }

  /// Initialize storage service
  /// This is async but called in constructor to avoid making constructor async
  Future<void> _initStorage() async {
    _storage = await StorageService.getInstance();
  }

  // ==================== AUTHENTICATION ====================

  /// Login user with username and password
  ///
  /// Flow:
  /// 1. Send credentials to backend
  /// 2. Receive JWT token
  /// 3. Save token in local storage
  /// 4. Save username for UI display
  ///
  /// @param credentials - User credentials (username, password)
  /// @returns LoginResponse with access token
  /// @throws Exception if login fails
  Future<LoginResponse> login(LoginCredentials credentials) async {
    try {
      // Build the full URL: base + endpoint
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}');

      // Log the request for debugging
      _logger.i('📡 POST $url');

      // Make HTTP POST request
      // Note: Using form-urlencoded because FastAPI expects this format
      final response = await http.post(
        url,
        headers: ApiConstants.formHeaders,
        body: credentials.toFormData(),
      ).timeout(ApiConstants.connectionTimeout);

      // Log response status
      _logger.i('📦 Status: ${response.statusCode}');

      // Check if request was successful (200 OK)
      if (response.statusCode == 200) {
        // Parse JSON response
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));

        // Save token for future authenticated requests
        await _storage.saveToken(loginResponse.accessToken);

        // Save username for UI display (welcome message, profile, etc.)
        await _storage.saveUsername(credentials.username);

        return loginResponse;
      } else {
        // Login failed - throw exception with status code
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      // Log error and rethrow for controller to handle
      _logger.e('❌ Login error: $e');
      rethrow;
    }
  }

  /// Validate if the current JWT token is still valid
  ///
  /// Why validate tokens?
  /// - JWT tokens can expire
  /// - User might have been deleted/disabled
  /// - Ensures user is still authenticated before making requests
  ///
  /// @returns true if token is valid, false otherwise
  Future<bool> validateToken() async {
    // Get token from storage
    final token = _storage.getToken();

    // No token = not logged in
    if (token == null) return false;

    // Make request to protected endpoint
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.validateTokenEndpoint}'),
      headers: ApiConstants.authHeaders(token),
    );

    // 200 = valid token, anything else = invalid
    return response.statusCode == 200;
  }

  // ==================== PROTECTED ENDPOINTS ====================

  /// Get protected data from backend
  ///
  /// Example of an authenticated request:
  /// 1. Get token from storage
  /// 2. Add token to Authorization header
  /// 3. Make request
  ///
  /// @returns Map with protected data
  /// @throws Exception if no token or request fails
  Future<Map<String, dynamic>> getProtectedData() async {
    // Ensure user is logged in
    final token = _storage.getToken();
    if (token == null) {
      throw Exception("No token found");
    }

    // Make authenticated request
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}${ApiConstants.protectedRouteEndpoint}"),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed: ${response.statusCode}");
    }
  }

  // ==================== LOGOUT ====================

  /// Logout user (clear local token)
  ///
  /// What it does:
  /// - Removes JWT token from storage
  /// - Removes username from storage
  /// - Clears any cached user data
  ///
  /// Note: This is LOCAL logout only
  /// - Token still valid on backend until expiration
  /// - For server-side logout, would need /logout endpoint
  ///
  /// Why local only?
  /// - JWT tokens are stateless (backend doesn't track them)
  /// - Token expires automatically
  /// - Revoking tokens requires backend blacklist
  Future<void> logout() async {
    await _storage.clearToken();
    await _storage.remove(ApiConstants.usernameKey);
    _logger.i('👋 User logged out');
  }

  // ==================== HEALTH CHECK ====================

  /// Ping server to check if backend is alive
  ///
  /// Use cases:
  /// - Check connection before important operations
  /// - Display "server offline" warning to user
  /// - Testing/debugging
  ///
  /// @returns Ping message from server
  /// @throws Exception if server is unreachable
  Future<String> ping() async {
    final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.pingEndpoint}")
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["ping"] ?? "No ping message";
    } else {
      throw Exception("Failed: ${response.statusCode}");
    }
  }
}