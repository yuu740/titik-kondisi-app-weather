import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/auth_models.dart';

class AuthService {
  
  // Login
  Future<AuthResponse> login(String email, String password) async {
    final url = AppConfig.loginEndpoint;
    
    try {
      print('--- API REQUEST: POST $url ---');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('--- API RESPONSE: ${response.statusCode} ---');
      print('--- BODY: ${response.body} ---');

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(jsonDecode(response.body));
      } else {
        try {
            final errorBody = jsonDecode(response.body);
            throw Exception(errorBody['message'] ?? 'Login Failed');
        } catch (_) {
            throw Exception('Login Failed: Status ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }

  // Register
  Future<AuthResponse> register(String email, String password, String confirmPassword) async {
    final url = AppConfig.registerEndpoint;

    try {
      print('--- API REQUEST: POST $url ---');
      print('Data: $email, confirmPassword: $confirmPassword'); 

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword, 
        }),
      );

      print('--- API RESPONSE: ${response.statusCode} ---');
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(jsonDecode(response.body));
      } else {
        try {
            final errorBody = jsonDecode(response.body);
            throw Exception(errorBody['message'] ?? 'Registration Failed');
        } catch (_) {
            throw Exception('Registration Failed: Status ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }
}