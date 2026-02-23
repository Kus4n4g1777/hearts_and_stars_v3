import 'package:equatable/equatable.dart';

/// Authentication Events - Abstract Base Class
///
/// Represents all possible user actions and system triggers
/// in the authentication flow.
///
/// Why abstract?
/// - Ensures all events follow same pattern
/// - Enables type-safe event handling
/// - Supports equality comparison via Equatable
///
/// Pattern: Event = Past-tense action that happened
/// Examples: LoginRequested, LogoutRequested, TokenRefreshRequested
///
/// BLoC Algorithm Step 1/8: Define abstract Event class
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// ==================== CONCRETE EVENTS ====================
// BLoC Algorithm Step 2/8: Define concrete Events
// Each event represents ONE specific action in the auth flow

/// User requested login with credentials
///
/// Dispatched when:
/// - User taps "Login" button
/// - User submits login form
///
/// Carries data:
/// - username: User's login identifier
/// - password: User's password (not stored, only passed to API)
///
/// Flow:
/// User taps login → LoginRequested dispatched → BLoC processes →
/// Emits AuthLoading → API call → Emits AuthAuthenticated or AuthError
class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({
    required this.username,
    required this.password,
  });

  /// Include username and password in equality check
  /// Two LoginRequested events with same credentials are equal
  /// Why? Prevents duplicate processing of same login attempt
  @override
  List<Object?> get props => [username, password];

  /// String representation for debugging
  /// Hides password for security (shows length instead)
  @override
  String toString() => 'LoginRequested(username: $username, password: [${password.length} chars])';
}

/// User requested logout
///
/// Dispatched when:
/// - User taps "Logout" button
/// - Session expires and auto-logout triggered
/// - User switches accounts
///
/// Carries data: None (logout doesn't need parameters)
///
/// Flow:
/// User taps logout → LogoutRequested dispatched → BLoC processes →
/// Clears tokens → Emits AuthUnauthenticated
class LogoutRequested extends AuthEvent {
  const LogoutRequested();

  @override
  String toString() => 'LogoutRequested()';
}

/// App started - check authentication status
///
/// Dispatched when:
/// - App launches
/// - App resumes from background
///
/// Purpose:
/// Determines initial route (login vs home screen)
///
/// Carries data: None
///
/// Flow:
/// App starts → AppStarted dispatched → BLoC checks token →
/// Emits AuthAuthenticated (if valid token) or AuthUnauthenticated
class AppStarted extends AuthEvent {
  const AppStarted();

  @override
  String toString() => 'AppStarted()';
}

/// Token refresh requested
///
/// Dispatched when:
/// - Access token is about to expire
/// - API returns 401 Unauthorized
/// - User returns after long absence
///
/// Purpose:
/// Get new access token using refresh token
/// Prevents forcing user to re-login
///
/// Carries data: None (uses stored refresh token)
///
/// Flow:
/// Token expiring → TokenRefreshRequested → BLoC gets refresh token →
/// Calls API → Emits AuthAuthenticated (new token) or AuthUnauthenticated (failed)
class TokenRefreshRequested extends AuthEvent {
  const TokenRefreshRequested();

  @override
  String toString() => 'TokenRefreshRequested()';
}