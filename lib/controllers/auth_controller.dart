import 'package:get/get.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final username = ''.obs;
  final password = ''.obs;
  final api = ApiService();

  void login() async {
    final user = username.value.trim();
    final pass = password.value.trim();

    if (user.isEmpty || pass.isEmpty) {
      Get.snackbar('Missing fields', 'Please enter both username and password',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final token = await api.login(user, pass);
      if (token.isNotEmpty) {
        // Token saved locally in ApiService
        Get.toNamed('/speed-dials');
      }
    } catch (e) {
      Get.snackbar('Login failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}