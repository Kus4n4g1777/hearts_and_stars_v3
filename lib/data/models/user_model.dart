/// User Model - Represents authenticated user data
///
/// What is a Model?
/// - Represents data structure
/// - Contains business logic related to that data
/// - Converts between different formats (JSON ↔ Dart objects)
///
/// Why separate models?
/// - Type safety: Dart knows what fields exist
/// - Autocomplete: IDE suggests available properties
/// - Validation: Ensures data integrity
/// - Testability: Easy to create mock users
/// - Reusability: Use same model across app
class User {
  /// Username (unique identifier)
  final String username;

  /// Email address (optional)
  /// Why optional?
  /// - Some auth systems don't require email
  /// - Backend might not return it
  final String? email;

  /// Constructor
  ///
  /// Why required vs optional?
  /// - username: required (every user must have one)
  /// - email: optional (marked with ?)
  User({
    required this.username,
    this.email,
  });

  /// Factory constructor - creates User from JSON
  ///
  /// What is a factory constructor?
  /// - Named constructor that can return existing instance
  /// - Can perform logic before creating object
  /// - Can return null or throw exception
  ///
  /// When called?
  /// - When backend returns user data
  /// - Example: GET /users/me/ → {"username": "john", "email": "john@example.com"}
  ///
  /// Why 'as String?' with ??
  /// - as String? = cast to nullable string
  /// - ?? = null coalescing operator (provides default if null)
  /// - Prevents crashes if backend sends null or different type
  ///
  /// Example:
  /// ```dart
  /// final json = {"username": "john", "email": null};
  /// final user = User.fromJson(json);
  /// // user.username = "john"
  /// // user.email = null (safe, because it's optional)
  /// ```
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String? ?? '', // Default to empty string
      email: json['email'] as String?, // Allow null
    );
  }

  /// Convert User to JSON
  ///
  /// When needed?
  /// - Sending user data to backend
  /// - Saving to local storage
  /// - Logging/debugging
  ///
  /// Example:
  /// ```dart
  /// final user = User(username: 'john', email: 'john@example.com');
  /// final json = user.toJson();
  /// // {"username": "john", "email": "john@example.com"}
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
    };
  }

  /// String representation for debugging
  ///
  /// Usage:
  /// ```dart
  /// print(user); // Prints: User(username: john, email: john@example.com)
  /// ```
  @override
  String toString() => 'User(username: $username, email: $email)';
}

// ==============================================================

/// Login Credentials - Data sent to backend for authentication
///
/// Why separate from User?
/// - Credentials are temporary (only during login)
/// - User is persistent (stored after login)
/// - Security: password should never be stored long-term
class LoginCredentials {
  final String username;
  final String password;

  LoginCredentials({
    required this.username,
    required this.password,
  });

  /// Convert to form data format
  ///
  /// Why not JSON?
  /// - FastAPI /token endpoint expects form-urlencoded
  /// - OAuth2 standard uses form data, not JSON
  ///
  /// Format:
  /// - Content-Type: application/x-www-form-urlencoded
  /// - Body: username=john&password=secret123
  ///
  /// This method returns Map for http package:
  /// ```dart
  /// http.post(url, body: credentials.toFormData());
  /// ```
  Map<String, String> toFormData() => {
    'username': username,
    'password': password,
  };
}

// ==============================================================

/// Login Response - Data returned by backend after successful login
///
/// Example backend response:
/// {
///   "access_token": "eyJhbGciOiJIUzI1NiIs...",
///   "token_type": "bearer"
/// }
class LoginResponse {
  /// JWT access token
  ///
  /// What is JWT?
  /// - JSON Web Token
  /// - Encoded string containing user info + expiration
  /// - Used for authenticated API requests
  /// - Format: header.payload.signature
  final String accessToken;

  LoginResponse({required this.accessToken});

  /// Create from backend JSON response
  ///
  /// Handles missing or invalid data gracefully
  /// If access_token is missing, defaults to empty string
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String? ?? '',
    );
  }

  /// Convert to JSON (for storage or logging)
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
    };
  }
}