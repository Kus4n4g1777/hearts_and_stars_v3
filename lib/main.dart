import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hearts & Stars Detector',
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.routes,
    );
  }
}