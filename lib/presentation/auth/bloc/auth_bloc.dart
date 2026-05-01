import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/api_service.dart';
import '../../../data/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC - State Machine
///
/// This is the heart of the authentication system.
/// It orchestrates the entire auth flow by:
/// 1. Receiving Events (user actions)
/// 2. Processing them (business logic)
/// 3. Emitting States (UI updates)
///
/// Architecture comparison:
/// GetX: Controller with methods and .obs variables
/// BLoC: State machine with events and states
///
/// Benefits over GetX:
/// - Predictable state transitions
/// - Testable without mocking navigation
/// - Clear separation: events (input) vs states (output)
/// - No hidden dependencies
/// - Industry standard pattern
///
/// BLoC Algorithm Step 5/8: Define BLoC class extending Bloc<Event, State>
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // ==================== DEPENDENCIES ====================

  final ApiService _apiService;

  /// Constructor
  ///
  /// Pattern: super(initialState) sets the starting state
  /// Then register event handlers with on<Event>()
  ///
  /// BLoC Algorithm Step 6/8: Constructor with initial state + register handlers
  AuthBloc({
    ApiService? apiService,
  })  : _apiService = apiService ?? ApiService(),
        super(const AuthInitial()) {
    // Register event handlers
    // Each on<Event> maps an event type to a handler function
    // When event is added: bloc.add(LoginRequested(...))
    // The corresponding handler executes: _onLoginRequested

    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<TokenRefreshRequested>(_onTokenRefreshRequested);
  }

  // ==================== EVENT HANDLERS ====================
  // BLoC Algorithm Step 7/8: Write handler methods
  // Each handler receives: event (data) + emit (function to emit states)

  /// Handle app startup
  ///
  /// Checks if user has valid stored token.
  /// Determines initial route (login vs home).
  ///
  /// States emitted:
  /// 1. AuthLoading (checking...)
  /// 2. AuthAuthenticated (token found) OR AuthUnauthenticated (no token)
  ///
  /// Compare to GetX:
  /// GetX: Called manually in main.dart or controller.onInit()
  /// BLoC: Dispatched as event: bloc.add(AppStarted())
  Future<void> _onAppStarted(
      AppStarted event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      // Check if token exists and is valid
      final isValid = await _apiService.validateToken();

      if (isValid) {
        // Token is valid, but we need user data
        // In a real app, you'd fetch user info here
        // For now, we'll emit unauthenticated and let user login
        emit(const AuthUnauthenticated());
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      // Error checking token, assume not authenticated
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle login request
  ///
  /// Validates credentials with backend.
  /// Saves tokens on success.
  ///
  /// States emitted:
  /// 1. AuthLoading (logging in...)
  /// 2. AuthAuthenticated (success) OR AuthError (failure)
  ///
  /// Compare to GetX:
  /// GetX: controller.login(email, password)
  /// BLoC: bloc.add(LoginRequested(username: email, password: password))
  Future<void> _onLoginRequested(
      LoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    // Validation
    final trimmedUsername = event.username.trim();
    final trimmedPassword = event.password.trim();

    if (trimmedUsername.isEmpty || trimmedPassword.isEmpty) {
      emit(const AuthError('Please enter username and password'));
      return;
    }

    // Show loading
    emit(const AuthLoading());

    try {
      // Create credentials
      final credentials = LoginCredentials(
        username: trimmedUsername,
        password: trimmedPassword,
      );

      // Call API (this saves token automatically)
      final response = await _apiService.login(credentials);

      // Check if we got a valid token
      if (response.accessToken.isNotEmpty) {
        // Success! Emit authenticated state with user data
        emit(AuthAuthenticated(response));
      } else {
        emit(const AuthError('Login failed: Invalid response from server'));
      }
    } catch (e) {
      // Handle errors
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(errorMessage));
    }
  }

  /// Handle logout request
  ///
  /// Clears tokens and navigates to login.
  ///
  /// States emitted:
  /// 1. AuthLoading (optional - can skip for instant logout)
  /// 2. AuthUnauthenticated (always)
  ///
  /// Compare to GetX:
  /// GetX: controller.logout() - includes navigation
  /// BLoC: bloc.add(LogoutRequested()) - just emits state, UI navigates
  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    // Option 1: Show loading
    // emit(const AuthLoading());

    // Option 2: Instant logout (better UX)
    // Just clear data and emit unauthenticated

    try {
      // Clear tokens via API service
      await _apiService.logout();

      // Emit unauthenticated state
      // UI will listen to this and navigate to login
      emit(const AuthUnauthenticated(
        message: 'You have been logged out',
      ));
    } catch (e) {
      // Even if logout fails, still log out locally
      emit(AuthUnauthenticated(
        message: 'Logout error: ${e.toString()}',
      ));
    }
  }

  /// Handle token refresh
  ///
  /// Gets new access token using refresh token.
  /// Called automatically when token expires.
  ///
  /// States emitted:
  /// 1. Keep current state (don't show loading to user)
  /// 2. AuthAuthenticated with updated user (success)
  /// 3. AuthUnauthenticated (refresh failed, force re-login)
  Future<void> _onTokenRefreshRequested(
      TokenRefreshRequested event,
      Emitter<AuthState> emit,
      ) async {
    // Don't emit loading - this happens in background
    // User shouldn't see anything

    try {
      // Note: You'd need to implement token refresh in ApiService
      // For now, this is a placeholder

      // If refresh succeeds:
      // final newUser = await _apiService.refreshToken();
      // emit(AuthAuthenticated(newUser));

      // If refresh fails:
      emit(const AuthUnauthenticated(
        message: 'Session expired. Please login again.',
      ));
    } catch (e) {
      emit(const AuthUnauthenticated(
        message: 'Session expired. Please login again.',
      ));
    }
  }
}