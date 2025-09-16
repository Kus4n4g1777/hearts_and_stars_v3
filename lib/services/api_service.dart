import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Detect if running on Android emulator
  static String get baseUrl {; // this will be replaced with real Docker IP
    if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to reach host machine
      return "http://10.0.2.2:8000";
    } else {
      // iOS simulator, desktop, or other platforms can use localhost
      return "http://127.0.0.1:8000";
    }
  }


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