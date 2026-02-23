import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

// BLoC imports
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/auth/bloc/auth_event.dart';
import 'presentation/auth/bloc/auth_state.dart';

// Page imports
import 'presentation/auth/pages/login_page.dart';
import 'presentation/views/home/speed_dial_view.dart';  // ✅ YOUR REAL HOME
import 'core/routes/app_routes.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc()..add(const AppStarted()),
      child: GetMaterialApp(
        title: 'Hearts & Stars Detector',
        debugShowCheckedModeBanner: false,

        // ==================== DYNAMIC HOME BASED ON AUTH STATE ====================
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Show splash during initial check
            if (state is AuthInitial || state is AuthLoading) {
              return Scaffold(
                body: Stack(
                  children: [
                    // Background image on splash too
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/background.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        color: const Color.fromRGBO(0, 0, 0, 0.35),
                      ),
                    ),
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.deepOrangeAccent,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // User is authenticated - show YOUR beautiful home screen
            if (state is AuthAuthenticated) {
              return const SpeedDialView();  // ✅ YOUR REAL HOME
            }

            // Default: show login screen
            return const LoginPage();
          },
        ),

        // ==================== NAMED ROUTES ====================
        getPages: [
          GetPage(
            name: AppRoutes.login,
            page: () => const LoginPage(),
          ),
          GetPage(
            name: AppRoutes.home,
            page: () => const SpeedDialView(),  // ✅ YOUR REAL HOME
          ),
          // Your other routes stay the same
        ],
      ),
    );
  }
}