import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  Future<void> setTenantId(String tenantId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tenant_id', tenantId);
  }

  Future<String?> getTenantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tenant_id');
  }

  Future<Map<String, String>> _getHeaders() async {
    final tenantId = await getTenantId();
    if (tenantId == null) throw Exception('No tenant ID set');
    return {
      'Content-Type': 'application/json',
      'x-tenant-id': tenantId,
    };
  }

  Future<List<Client>> getClients() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/gym/clients'), headers: headers);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Client.fromJson(json)).toList();
    }
    throw Exception('Failed to load clients');
  }

  Future<List<Product>> getProducts() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/gym/products'), headers: headers);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to load products');
  }

  Future<List<Membership>> getMemberships() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/gym/memberships'), headers: headers);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Membership.fromJson(json)).toList();
    }
    throw Exception('Failed to load memberships');
  }

  Future<void> processSale(int clientId, List<Map<String, dynamic>> items, double total) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/gym/sales'),
      headers: headers,
      body: jsonEncode({
        'clientId': clientId,
        'items': items,
        'total': total,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to process sale');
    }
  }
}
