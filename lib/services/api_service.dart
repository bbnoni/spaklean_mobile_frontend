import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class ApiService {
  // --- LOGIN FUNCTION ---
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/login');
    print('🔹 Sending login request to: $url');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('🔹 Login response code: ${response.statusCode}');
    print('🔹 Login response body: ${response.body}');

    try {
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('✅ Login success. Decoded JSON: $decoded');
        return decoded;
      } else {
        final errMsg = decoded['error'] ?? 'Login failed';
        throw Exception('❌ Login failed: $errMsg');
      }
    } catch (e) {
      print('⚠️ JSON decode failed. Response was likely HTML.');
      throw Exception(
        'Invalid response from server. '
        'Ensure your baseUrl ($baseUrl) is correct and backend is running.',
      );
    }
  }

  // --- MANAGER LOCATIONS FUNCTION ---
  static Future<List<dynamic>> getAssignedLocations(
    String token,
    int userId,
  ) async {
    final url = Uri.parse('$baseUrl/manager/locations/$userId');
    print('📍 Fetching assigned locations from: $url');
    print('📤 Token being sent: $token');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('🔹 Response code: ${response.statusCode}');
    print('🔹 Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to fetch assigned locations: '
        '${response.statusCode} -> ${response.body}',
      );
    }
  }

  // --- GET GROUPED ROOMS BY ZONE FUNCTION ---
  static Future<Map<String, dynamic>> getRoomsByZoneGrouped(
    String token,
    int userId,
    String zone,
  ) async {
    final encodedZone = Uri.encodeComponent(zone);
    final url = Uri.parse(
      '$baseUrl/manager/locations/$userId/zone/$encodedZone',
    );
    print('📍 Fetching grouped rooms for zone: $zone from: $url');
    print('📤 Token being sent: $token');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('🔹 Zone grouped response code: ${response.statusCode}');
    print('🔹 Zone grouped response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to fetch grouped rooms: '
        '${response.statusCode} -> ${response.body}',
      );
    }
  }
}
