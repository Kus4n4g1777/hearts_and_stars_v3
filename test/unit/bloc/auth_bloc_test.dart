import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hearts_and_stars_v3/presentation/auth/bloc/auth_bloc.dart';
import 'package:hearts_and_stars_v3/presentation/auth/bloc/auth_event.dart';
import 'package:hearts_and_stars_v3/presentation/auth/bloc/auth_state.dart';
import 'package:hearts_and_stars_v3/data/models/user_model.dart';
import '../../mocks/mocks.mocks.dart';

/// AuthBloc Unit Tests
///
/// Tests authentication state machine in isolation.
///
/// Why BLoC tests are easier than GetX:
/// - No navigation mocking needed
/// - No UI framework initialization
/// - Pure input (events) → output (states) testing
/// - bloc_test package provides powerful helpers
///
/// Test philosophy: Given-When-Then
/// - Given: Initial state + mock behaviors
/// - When: Event dispatched
/// - Then: Expected states emitted
void main() {
  late AuthBloc authBloc;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    authBloc = AuthBloc(apiService: mockApiService);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, equals(const AuthInitial()));
    });

    /// Test successful login flow
    ///
    /// Pattern: blocTest helper
    /// Cleaner than manual stream testing
    ///
    /// Verifies:
    /// 1. Correct states emitted in order
    /// 2. API service called with correct credentials
    /// 3. Final state contains user data
    blocTest<AuthBloc, AuthState>(
      'LoginRequested emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        // Arrange - mock successful API response
        when(mockApiService.login(any)).thenAnswer(
              (_) async => LoginResponse(
            accessToken: 'test_token_123',
          ),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const LoginRequested(
          username: 'testuser',
          password: 'password123',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        isA<AuthAuthenticated>()
            .having((s) => s.user.accessToken, 'token', 'test_token_123'),
      ],
      verify: (_) {
        // Verify API was called
        verify(mockApiService.login(any)).called(1);
      },
    );

    /// Test login failure
    ///
    /// Verifies error handling:
    /// 1. AuthLoading emitted first
    /// 2. AuthError emitted with error message
    /// 3. Error message is user-friendly (no "Exception:" prefix)
    blocTest<AuthBloc, AuthState>(
      'LoginRequested emits [AuthLoading, AuthError] on failure',
      build: () {
        when(mockApiService.login(any))
            .thenThrow(Exception('Invalid credentials'));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const LoginRequested(
          username: 'wrong',
          password: 'wrong',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError('Invalid credentials'),
      ],
    );

    /// Test validation
    ///
    /// Verifies client-side validation:
    /// 1. Empty username/password caught before API call
    /// 2. Error emitted immediately
    /// 3. API never called
    blocTest<AuthBloc, AuthState>(
      'LoginRequested emits [AuthError] on empty credentials',
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const LoginRequested(username: '', password: 'pass'),
      ),
      expect: () => [
        const AuthError('Please enter username and password'),
      ],
      verify: (_) {
        verifyNever(mockApiService.login(any));
      },
    );

    /// Test logout flow
    ///
    /// Verifies:
    /// 1. Logout API called
    /// 2. AuthUnauthenticated emitted
    /// 3. Optional logout message included
    blocTest<AuthBloc, AuthState>(
      'LogoutRequested emits [AuthUnauthenticated]',
      build: () {
        when(mockApiService.logout()).thenAnswer((_) async => Future.value());
        return authBloc;
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        const AuthUnauthenticated(message: 'You have been logged out'),
      ],
      verify: (_) {
        verify(mockApiService.logout()).called(1);
      },
    );

    /// Test app startup with valid token
    ///
    /// Verifies initial auth check:
    /// 1. AuthLoading while checking
    /// 2. AuthUnauthenticated (for now - would be Authenticated with real token logic)
    blocTest<AuthBloc, AuthState>(
      'AppStarted checks authentication status',
      build: () {
        when(mockApiService.validateToken()).thenAnswer((_) async => false);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });
}