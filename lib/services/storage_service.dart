import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<bool> saveToken(String token) async {
    return await _preferences!.setString(ApiConstants.jwtTokenKey, token);
  }

  String? getToken() {
    return _preferences!.getString(ApiConstants.jwtTokenKey);
  }

  bool get hasToken => getToken() != null;

  Future<bool> clearToken() async {
    return await _preferences!.remove(ApiConstants.jwtTokenKey);
  }

  Future<bool> saveUsername(String username) async {
    return await _preferences!.setString(ApiConstants.usernameKey, username);
  }

  String? getUsername() {
    return _preferences!.getString(ApiConstants.usernameKey);
  }
}