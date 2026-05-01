import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../core/routes/app_routes.dart';

/// Login Page - Beautiful BLoC Version
///
/// Combines:
/// - Your gorgeous space background design
/// - BLoC state management
/// - Production-ready patterns
///
/// Visual features:
/// - Background image with overlay
/// - Transparent form on space backdrop
/// - Smooth animations
/// - Professional styling
///
/// BLoC Algorithm Step 8/8: Update UI to use BLoC
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login button press
  ///
  /// Dispatches LoginRequested event to BLoC
  void _handleLogin(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          username: _usernameController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocConsumer<AuthBloc, AuthState>(
        // ==================== LISTENER ====================
        // Handles side effects: navigation, snackbars
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navigate to home
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },

        // ==================== BUILDER ====================
        // Rebuilds UI when state changes
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              // ==================== BACKGROUND IMAGE ====================
              Positioned.fill(
                child: Image.asset(
                  'assets/images/background.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              // ==================== DARK OVERLAY ====================
              Positioned.fill(
                child: Container(
                  color: const Color.fromRGBO(0, 0, 0, 0.35),
                ),
              ),

              // ==================== LOGIN FORM ====================
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 40,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ==================== TITLE ====================
                            const Text(
                              'Hearts & Stars Detector',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // ==================== USERNAME FIELD ====================
                            TextFormField(
                              controller: _usernameController,
                              enabled: !isLoading,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Username',
                                labelStyle: const TextStyle(color: Colors.white70),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.08),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: Colors.white70,
                                ),
                                // Error styling
                                errorStyle: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Username is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // ==================== PASSWORD FIELD ====================
                            TextFormField(
                              controller: _passwordController,
                              enabled: !isLoading,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: const TextStyle(color: Colors.white70),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.08),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Colors.white70,
                                ),
                                // Error styling
                                errorStyle: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleLogin(context),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // ==================== LOGIN BUTTON ====================
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _handleLogin(context),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: Colors.deepOrangeAccent,
                                  disabledBackgroundColor:
                                  Colors.deepOrangeAccent.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                    : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            // ==================== ERROR DISPLAY ====================
                            if (state is AuthError) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.redAccent,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.redAccent,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        state.message,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}