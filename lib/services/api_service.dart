import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class ApiService {
  static String get baseUrl {
    if (Platform.isAndroid) return "http://10.0.2.2:8000";
    return "http://127.0.0.1:8000";
  }

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/token"), // 👈 FastAPI usa /token
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "username": username,
        "password": password,
      },
    );

    var logger = Logger();

    logger.i("📡 Login POST -> $baseUrl/token");
    logger.i("📦 Status code: ${response.statusCode}");
    logger.i("📦 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data["access_token"];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("jwt_token", token);
      return token;
    } else {
      throw Exception("Login failed: ${response.statusCode}");
    }
  }

  Future<bool> validateToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt_token");
    if (token == null) return false;

    final response = await http.get(
      Uri.parse("$baseUrl/users/me/"), // 👈 FastAPI usa /users/me/
      headers: {"Authorization": "Bearer $token"},
    );

    print("🔑 Validate GET -> $baseUrl/users/me/");
    print("📦 Status code: ${response.statusCode}");
    print("📦 Response body: ${response.body}");

    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> getProtectedData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt_token");
    if (token == null) throw Exception("No token found, login first");

    final response = await http.get(
      Uri.parse("$baseUrl/protected-route"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed: ${response.statusCode}");
    }
  }
  // leave this by the moment, in case you want to make more ping tests
  Future<String> ping() async {
    final response = await http.get(Uri.parse("$baseUrl/ping"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["ping"] ?? "No ping message";
    } else {
      throw Exception("Failed to connect to FastAPI: ${response.statusCode}");
    }
  }

}