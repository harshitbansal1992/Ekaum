import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // TODO: Update this to your backend URL
  // For local development: 'http://localhost:3000/api'
  // For production: 'https://your-backend-domain.com/api'
  // static const String baseUrl = 'http://localhost:3000/api';
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  //static const String baseUrl = 'http://192.168.0.106:3000/api';
  
  static String? _token;
  
  static Future<void> setToken(String? token) async {
    _token = token;
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    }
  }
  
  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }
  
  static Future<Map<String, String>> get _headers async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Auth
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: await _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['token'] != null) {
          await setToken(data['token'] as String);
        }
        return data;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['error'] ?? 'Registration failed');
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['token'] != null) {
          await setToken(data['token'] as String);
        }
        return data;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }
  
  static Future<void> logout() async {
    await setToken(null);
  }
  
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: await _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get user');
      }
    } catch (e) {
      debugPrint('Get user error: $e');
      rethrow;
    }
  }
  
  // Subscriptions
  static Future<Map<String, dynamic>> getSubscription(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/$userId'),
        headers: await _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get subscription');
      }
    } catch (e) {
      debugPrint('Get subscription error: $e');
      rethrow;
    }
  }
  
  // Avdhan
  static Future<List<dynamic>> getAvdhanList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/avdhan'),
        headers: await _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to get avdhan list');
      }
    } catch (e) {
      debugPrint('Get avdhan list error: $e');
      rethrow;
    }
  }
  
  // Samagam
  static Future<List<dynamic>> getSamagamList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/samagam'),
        headers: await _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to get samagam list');
      }
    } catch (e) {
      debugPrint('Get samagam list error: $e');
      rethrow;
    }
  }
  
  // Patrika
  static Future<List<dynamic>> getPatrikaList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patrika'),
        headers: await _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to get patrika list');
      }
    } catch (e) {
      debugPrint('Get patrika list error: $e');
      rethrow;
    }
  }
  
  static Future<List<String>> getPatrikaPurchases(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patrika/purchases/$userId'),
        headers: await _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data.map((e) => e.toString()).toList();
      } else {
        throw Exception('Failed to get purchases');
      }
    } catch (e) {
      debugPrint('Get patrika purchases error: $e');
      rethrow;
    }
  }
  
  static Future<void> recordPatrikaPurchase({
    required String patrikaId,
    required double amount,
    required String paymentId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/patrika/purchases'),
        headers: await _headers,
        body: jsonEncode({
          'patrikaId': patrikaId,
          'amount': amount,
          'paymentId': paymentId,
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to record purchase');
      }
    } catch (e) {
      debugPrint('Record patrika purchase error: $e');
      rethrow;
    }
  }
  
  // Paath Forms
  static Future<String> createPaathForm(Map<String, dynamic> formData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/paath-forms'),
        headers: await _headers,
        body: jsonEncode(formData),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['formId'] as String;
      } else {
        throw Exception('Failed to create form');
      }
    } catch (e) {
      debugPrint('Create paath form error: $e');
      rethrow;
    }
  }
  
  static Future<List<dynamic>> getPaathForms(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/paath-forms/$userId'),
        headers: await _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to get forms');
      }
    } catch (e) {
      debugPrint('Get paath forms error: $e');
      rethrow;
    }
  }
  
  // Donations
  static Future<String> createDonation(double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/donations'),
        headers: await _headers,
        body: jsonEncode({'amount': amount}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['donationId'] as String;
      } else {
        throw Exception('Failed to create donation');
      }
    } catch (e) {
      debugPrint('Create donation error: $e');
      rethrow;
    }
  }
  
  static Future<List<dynamic>> getDonations(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donations/$userId'),
        headers: await _headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to get donations');
      }
    } catch (e) {
      debugPrint('Get donations error: $e');
      rethrow;
    }
  }
}


