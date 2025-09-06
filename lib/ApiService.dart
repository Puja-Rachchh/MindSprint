import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:8080"; // Change if needed

  static Future<http.Response> signup(String email, String password) async {
    final url = Uri.parse("$baseUrl/signup");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
  }

  static Future<http.Response> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
  }
}
