import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tenant.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      return null; // Success
    }
    return 'Invalid credentials';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<List<Tenant>> getTenants() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/tenants'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Tenant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tenants');
    }
  }

  Future<void> updateTenantStatus(int id, String status) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/tenants/$id/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update tenant status');
    }
  }

  Future<void> createTenant(String name, String email, String phone) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/tenants'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name, 'email': email, 'phone': phone}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create tenant');
    }
  }
}
