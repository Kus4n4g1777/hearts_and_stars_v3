import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../data/models/user_model.dart';
import '../../core/routes/app_routes.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();

  final username = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;

  Future<void> login() async {
    final user = username.value.trim();
    final pass = password.value.trim();

    if (user.isEmpty || pass.isEmpty) {
      Get.snackbar('Missing fields', 'Please enter username and password',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;

    try {
      final credentials = LoginCredentials(username: user, password: pass);
      final response = await _apiService.login(credentials);

      if (response.accessToken.isNotEmpty) {
        Get.offNamed(AppRoutes.home);
      }
    } catch (e) {
      Get.snackbar('Login failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}