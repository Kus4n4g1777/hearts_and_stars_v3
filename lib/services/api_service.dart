import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../core/constants/api_constants.dart';
import '../data/models/user_model.dart';
import 'storage_service.dart';

class ApiService {
  final Logger _logger = Logger();
  late final StorageService _storage;

  ApiService() {
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storage = await StorageService.getInstance();
  }

  Future<LoginResponse> login(LoginCredentials credentials) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}');
      _logger.i('📡 POST $url');

      final response = await http.post(
        url,
        headers: ApiConstants.formHeaders,
        body: credentials.toFormData(),
      ).timeout(ApiConstants.connectionTimeout);

      _logger.i('📦 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
        await _storage.saveToken(loginResponse.accessToken);
        await _storage.saveUsername(credentials.username);
        return loginResponse;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ Login error: $e');
      rethrow;
    }
  }

  Future<bool> validateToken() async {
    final token = _storage.getToken();
    if (token == null) return false;

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.validateTokenEndpoint}'),
      headers: ApiConstants.authHeaders(token),
    );

    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> getProtectedData() async {
    final token = _storage.getToken();
    if (token == null) throw Exception("No token found");

    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}${ApiConstants.protectedRouteEndpoint}"),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed: ${response.statusCode}");
    }
  }

  Future<String> ping() async {
    final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.pingEndpoint}")
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["ping"] ?? "No ping message";
    } else {
      throw Exception("Failed: ${response.statusCode}");
    }
  }
}