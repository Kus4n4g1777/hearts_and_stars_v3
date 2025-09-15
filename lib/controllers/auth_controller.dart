import 'package:get/get.dart';

class AuthController extends GetxController {
  final username = ''.obs;
  final password = ''.obs;

  void login() {
    final user = username.value.trim();
    final pass = password.value.trim();

    if (user.isEmpty || pass.isEmpty) {
      Get.snackbar(
        'Missing fields',
        'Please enter both username and password',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // TODO: replace with real authentication call to FastAPI
    // For now just navigate to the speed-dial screen
    Get.toNamed('/speed-dials');
  }
}