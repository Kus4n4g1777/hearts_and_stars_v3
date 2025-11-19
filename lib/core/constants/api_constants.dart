import 'dart:io';

/// API configuration constants
class ApiConstants {
  ApiConstants._(); // Private constructor to prevent instantiation

  // Base URLs
  static String get baseUrl {
    if (Platform.isAndroid) return "http://10.0.2.2:8000";
    if (Platform.isIOS) return "http://localhost:8000";
    return "http://127.0.0.1:8000";
  }

  static String get wsUrl {
    if (Platform.isAndroid) return "ws://10.0.2.2:8000";
    if (Platform.isIOS) return "ws://localhost:8000";
    return "ws://127.0.0.1:8000";
  }

  // Endpoints
  static const String loginEndpoint = '/token';
  static const String validateTokenEndpoint = '/users/me/';
  static const String protectedRouteEndpoint = '/protected-route';
  static const String pingEndpoint = '/ping';

  // WebSocket endpoints
  static const String wsDashboardEndpoint = '/ws/dashboard';

  // Headers
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
  };

  static const Map<String, String> formHeaders = {
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  static Map<String, String> authHeaders(String token) => {
    'Authorization': 'Bearer $token',
  };

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Storage keys
  static const String jwtTokenKey = 'jwt_token';
  static const String usernameKey = 'username';
}