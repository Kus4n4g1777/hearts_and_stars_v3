import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart'; // Using YOUR existing model

/// Authentication States - Abstract Base Class
///
/// Represents all possible states of the authentication system.
///
/// States describe WHAT the system looks like at a given moment.
/// Unlike events (which describe actions), states describe conditions.
///
/// Why abstract?
/// - Ensures all states follow same pattern
/// - Enables type-safe state handling in UI
/// - Supports equality comparison to prevent unnecessary rebuilds
///
/// Pattern: State = Current condition/status
/// Examples: AuthLoading, AuthAuthenticated, AuthError
///
/// State Machine Flow:
/// AuthInitial → AppStarted event → AuthLoading → AuthAuthenticated/Unauthenticated
///
/// BLoC Algorithm Step 3/8: Define abstract State class
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// ==================== CONCRETE STATES ====================
// BLoC Algorithm Step 4/8: Define concrete States
// Each state represents ONE specific condition in the auth system

/// Initial state before any authentication check
///
/// When:
/// - App just launched
/// - BLoC just created
/// - Before AppStarted event processed
///
/// UI behavior:
/// - Show splash screen
/// - Show loading indicator
/// - Don't allow user interaction yet
///
/// Next states:
/// - AuthLoading (when AppStarted event dispatched)
class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  String toString() => 'AuthInitial()';
}

/// Processing an authentication operation
///
/// When:
/// - Logging in (after LoginRequested)
/// - Logging out (after LogoutRequested)
/// - Checking auth status (after AppStarted)
/// - Refreshing token (after TokenRefreshRequested)
///
/// UI behavior:
/// - Show loading spinner
/// - Disable login button
/// - Disable form inputs
/// - Show "Please wait..." message
///
/// Next states:
/// - AuthAuthenticated (operation succeeded)
/// - AuthUnauthenticated (operation completed/failed)
/// - AuthError (operation failed with error)
class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  String toString() => 'AuthLoading()';
}

/// User is authenticated (logged in)
///
/// When:
/// - Login successful
/// - App started with valid token
/// - Token refreshed successfully
///
/// Contains:
/// - User data (username, token, etc.)
/// - All info needed to display user profile
///
/// UI behavior:
/// - Navigate to home screen
/// - Show welcome message with username
/// - Show logout button
/// - Enable protected features
///
/// Next states:
/// - AuthUnauthenticated (after logout)
/// - AuthLoading (when refreshing)
class AuthAuthenticated extends AuthState {
  final LoginResponse user;

  const AuthAuthenticated(this.user);

  /// Include user in equality check
  /// State only changes if user data actually changes
  /// Prevents unnecessary UI rebuilds
  @override
  List<Object?> get props => [user];

  @override
  String toString() => 'AuthAuthenticated(username: ${user.accessToken.substring(0, 10)}...)';
}

/// User is not authenticated (not logged in)
///
/// When:
/// - App started with no token
/// - Logout completed
/// - Token expired and refresh failed
/// - Login failed (credentials rejected)
///
/// Contains:
/// - Optional message to display to user
///
/// UI behavior:
/// - Show/stay on login screen
/// - Enable login form
/// - Clear any protected content
/// - Show message if provided
///
/// Next states:
/// - AuthLoading (when login attempted)
/// - AuthAuthenticated (when login succeeds)
class AuthUnauthenticated extends AuthState {
  /// Optional message to show user
  /// Examples:
  /// - "Session expired. Please login again."
  /// - "You have been logged out."
  /// - null (first time, no message)
  final String? message;

  const AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'AuthUnauthenticated(message: $message)';
}

/// Authentication operation failed with error
///
/// When:
/// - Login failed (network error, wrong credentials, server down)
/// - Token refresh failed
/// - Validation failed
///
/// Contains:
/// - Error message for user display
///
/// UI behavior:
/// - Show error message/snackbar
/// - Keep current screen (usually login)
/// - Re-enable form for retry
/// - Provide retry button
///
/// Difference from AuthUnauthenticated:
/// - AuthError: Temporary failure, user can retry same screen
/// - AuthUnauthenticated: Definitive state, must go to login
///
/// Next states:
/// - AuthLoading (when user retries)
/// - AuthUnauthenticated (if user cancels)
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'AuthError(message: $message)';
}