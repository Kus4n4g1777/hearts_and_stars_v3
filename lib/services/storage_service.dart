import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

/// Storage Service - Local data persistence wrapper
///
/// What is SharedPreferences?
/// - Cross-platform key-value storage (like browser localStorage)
/// - Persists data across app restarts
/// - Stored in native platform storage:
///   * Android: XML files in app's private directory
///   * iOS: NSUserDefaults
///   * Web: LocalStorage
///
/// Why wrap it?
/// - Single place to manage all storage operations
/// - Consistent API across the app
/// - Easy to switch storage backend (e.g., to secure_storage)
/// - Centralized key management (no magic strings scattered)
///
/// Use cases in this app:
/// - JWT token (for authentication)
/// - Username (for UI display)
/// - User preferences (theme, language, etc.)
class StorageService {
  // Singleton pattern - only one instance exists
  // Why singleton?
  // - SharedPreferences is already a singleton internally
  // - Ensures consistent state across the app
  // - Saves memory (no duplicate instances)
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  /// Private constructor - prevents external instantiation
  /// Only getInstance() can create the instance
  StorageService._();

  /// Get singleton instance
  ///
  /// Usage:
  /// ```dart
  /// final storage = await StorageService.getInstance();
  /// storage.saveToken('token_here');
  /// ```
  ///
  /// Why async?
  /// - SharedPreferences.getInstance() is async
  /// - It reads from disk on first call
  static Future<StorageService> getInstance() async {
    // Create instance if doesn't exist
    _instance ??= StorageService._();

    // Initialize SharedPreferences if not already done
    // This happens only once per app lifecycle
    _preferences ??= await SharedPreferences.getInstance();

    return _instance!;
  }

  // ==================== TOKEN MANAGEMENT ====================

  /// Save JWT token to local storage
  ///
  /// Why save token?
  /// - User stays logged in after closing app
  /// - No need to re-enter credentials
  /// - Token used for authenticated API requests
  ///
  /// Security note:
  /// - SharedPreferences is NOT encrypted by default
  /// - For production, consider flutter_secure_storage
  /// - Tokens should have expiration (handled by backend)
  ///
  /// @param token - JWT access token from login
  /// @returns true if saved successfully
  Future<bool> saveToken(String token) async {
    return await _preferences!.setString(ApiConstants.jwtTokenKey, token);
  }

  /// Retrieve JWT token from storage
  ///
  /// @returns token string or null if not found
  String? getToken() {
    return _preferences!.getString(ApiConstants.jwtTokenKey);
  }

  /// Check if user has a token (is logged in)
  ///
  /// Usage:
  /// ```dart
  /// if (storage.hasToken) {
  ///   // User is logged in
  /// } else {
  ///   // Redirect to login
  /// }
  /// ```
  bool get hasToken => getToken() != null;

  /// Clear token (logout)
  ///
  /// When to call?
  /// - User clicks logout button
  /// - Token validation fails (expired)
  /// - User account deleted
  Future<bool> clearToken() async {
    return await _preferences!.remove(ApiConstants.jwtTokenKey);
  }

  // ==================== USER DATA ====================

  /// Save username for UI display
  ///
  /// Why store username separately?
  /// - JWT token is encrypted, can't extract username easily
  /// - Faster to read (no decoding needed)
  /// - Used for "Welcome back, John!" messages
  Future<bool> saveUsername(String username) async {
    return await _preferences!.setString(ApiConstants.usernameKey, username);
  }

  /// Get stored username
  String? getUsername() {
    return _preferences!.getString(ApiConstants.usernameKey);
  }

  // ==================== GENERIC METHODS ====================
  // These methods allow storing any type of data
  // Useful for app preferences, settings, cache, etc.

  /// Save string value
  ///
  /// Example:
  /// ```dart
  /// storage.setString('theme', 'dark');
  /// storage.setString('language', 'en');
  /// ```
  Future<bool> setString(String key, String value) async {
    return await _preferences!.setString(key, value);
  }

  /// Get string value
  String? getString(String key) {
    return _preferences!.getString(key);
  }

  /// Save integer value
  ///
  /// Example:
  /// ```dart
  /// storage.setInt('launch_count', 5);
  /// storage.setInt('user_age', 25);
  /// ```
  Future<bool> setInt(String key, int value) async {
    return await _preferences!.setInt(key, value);
  }

  /// Get integer value
  int? getInt(String key) {
    return _preferences!.getInt(key);
  }

  /// Save boolean value
  ///
  /// Example:
  /// ```dart
  /// storage.setBool('notifications_enabled', true);
  /// storage.setBool('first_launch', false);
  /// ```
  Future<bool> setBool(String key, bool value) async {
    return await _preferences!.setBool(key, value);
  }

  /// Get boolean value
  bool? getBool(String key) {
    return _preferences!.getBool(key);
  }

  /// Clear all stored data
  ///
  /// Use with caution!
  /// - Clears EVERYTHING (token, username, preferences)
  /// - User will be logged out
  /// - All settings reset
  ///
  /// When to use?
  /// - Factory reset feature
  /// - Account deletion
  /// - Debugging/testing
  Future<bool> clearAll() async {
    return await _preferences!.clear();
  }

  /// Remove specific key
  ///
  /// More targeted than clearAll()
  /// Example:
  /// ```dart
  /// storage.remove('cached_posts');
  /// ```
  Future<bool> remove(String key) async {
    return await _preferences!.remove(key);
  }
}