import 'dart:io';

/// API Constants - Centralized configuration for backend communication
///
/// Why centralize constants?
/// - Single source of truth
/// - Easy to switch environments (dev/staging/prod)
/// - No magic strings scattered across codebase
/// - Easy to update when backend changes
///
/// Design pattern: Configuration Object
/// - All related config in one place
/// - Static members = no need to instantiate
/// - Private constructor = cannot be instantiated
class ApiConstants {
  /// Private constructor prevents instantiation
  ///
  /// Why?
  /// - This class is just a namespace for constants
  /// - No need to create instances
  /// - Forces usage: ApiConstants.baseUrl (not new ApiConstants().baseUrl)
  ApiConstants._();

  // ==================== BASE URLS ====================

  /// Get base URL based on platform
  ///
  /// Platform-specific networking:
  ///
  /// Android Emulator:
  /// - 10.0.2.2 = special IP that maps to host machine's localhost
  /// - Your computer (host) runs backend on 127.0.0.1:8000
  /// - Emulator can't access 127.0.0.1 (that's the emulator itself)
  /// - So Android emulator uses 10.0.2.2 to reach host
  ///
  /// iOS Simulator:
  /// - Can access host machine via localhost
  /// - No special IP needed
  ///
  /// Physical devices:
  /// - Would need actual IP address (e.g., 192.168.1.100:8000)
  /// - Or use ngrok/tailscale for public URL
  ///
  /// Example usage:
  /// ```dart
  /// final url = '${ApiConstants.baseUrl}/users/me';
  /// // Android: http://10.0.2.2:8000/users/me
  /// // iOS: http://localhost:8000/users/me
  /// ```
  static String get baseUrl {
    if (Platform.isAndroid) return "http://10.0.2.2:8000";
    if (Platform.isIOS) return "http://localhost:8000";
    return "http://127.0.0.1:8000"; // Desktop/Web fallback
  }

  /// WebSocket URL (ws:// instead of http://)
  ///
  /// What is WebSocket?
  /// - Persistent bidirectional connection
  /// - Unlike HTTP (request → response), WS keeps channel open
  /// - Server can push data anytime
  /// - Used for real-time features: chat, live updates, streaming
  ///
  /// Protocol differences:
  /// - HTTP: http:// (or https:// for secure)
  /// - WebSocket: ws:// (or wss:// for secure)
  ///
  /// Same platform logic as baseUrl
  static String get wsUrl {
    if (Platform.isAndroid) return "ws://10.0.2.2:8000";
    if (Platform.isIOS) return "ws://localhost:8000";
    return "ws://127.0.0.1:8000";
  }

  // ==================== ENDPOINTS ====================
  // These are appended to baseUrl/wsUrl

  /// Login endpoint (OAuth2 token)
  ///
  /// FastAPI standard:
  /// - POST /token with form data
  /// - Returns: {"access_token": "...", "token_type": "bearer"}
  static const String loginEndpoint = '/token';

  /// Token validation endpoint
  ///
  /// FastAPI standard:
  /// - GET /users/me/
  /// - Requires: Authorization: Bearer <token>
  /// - Returns: user data if token valid, 401 if invalid
  static const String validateTokenEndpoint = '/users/me/';

  /// Example protected endpoint
  ///
  /// Any endpoint that requires authentication
  /// Must include Authorization header with JWT
  static const String protectedRouteEndpoint = '/protected-route';

  /// Health check endpoint
  ///
  /// Used to test:
  /// - Is backend reachable?
  /// - Is network working?
  /// - Is server alive?
  ///
  /// No authentication required
  static const String pingEndpoint = '/ping';

  /// WebSocket endpoint for real-time detection
  ///
  /// Full URL: ws://10.0.2.2:8000/ws/dashboard
  /// Client connects, sends frames, receives detections
  static const String wsDashboardEndpoint = '/ws/dashboard';

  // ==================== HEADERS ====================

  /// Headers for form-urlencoded requests
  ///
  /// When to use?
  /// - OAuth2 token endpoint (/token)
  /// - Traditional HTML form submissions
  ///
  /// Format in HTTP request:
  /// Content-Type: application/x-www-form-urlencoded
  /// Body: username=john&password=secret
  static const Map<String, String> formHeaders = {
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  /// Generate authorization headers with JWT token
  ///
  /// Usage:
  /// ```dart
  /// final token = storage.getToken();
  /// final headers = ApiConstants.authHeaders(token);
  /// http.get(url, headers: headers);
  /// ```
  ///
  /// Result:
  /// {
  ///   'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIs...'
  /// }
  ///
  /// Why "Bearer"?
  /// - OAuth2 standard
  /// - Indicates token type
  /// - Backend validates format: "Bearer <token>"
  static Map<String, String> authHeaders(String token) => {
    'Authorization': 'Bearer $token',
  };

  // ==================== TIMEOUTS ====================

  /// Connection timeout for HTTP requests
  ///
  /// Why timeout?
  /// - Prevents app hanging forever on slow/dead networks
  /// - Better UX: show error after 10s instead of infinite wait
  /// - Frees resources if request is stuck
  ///
  /// 10 seconds:
  /// - Enough for normal networks
  /// - Not too long for user to wait
  /// - Can be adjusted based on use case
  static const Duration connectionTimeout = Duration(seconds: 10);

  // ==================== STORAGE KEYS ====================
  // Used with SharedPreferences

  /// Key for storing JWT token
  ///
  /// Why constant?
  /// - Typos in strings cause bugs
  /// - Easy to find all usages (search for jwtTokenKey)
  /// - Change once if key format changes
  static const String jwtTokenKey = 'jwt_token';

  /// Key for storing username
  ///
  /// Used for UI display (welcome messages, profile)
  static const String usernameKey = 'username';
}