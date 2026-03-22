import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class ApiService {
  /// Backend API base URL. Use --dart-define=BACKEND_URL=... for production.
  static String get baseUrl => AppConfig.backendApiBaseUrl;

  static const int _maxRetries = 2;

  /// Execute HTTP request with retry on connection/5xx failures.
  static Future<http.Response> _requestWithRetry(
    Future<http.Response> Function() request,
  ) async {
    int attempts = 0;
    while (true) {
      try {
        final response = await request();
        if (response.statusCode >= 500 && attempts < _maxRetries) {
          await Future<void>.delayed(Duration(milliseconds: 500 * (attempts + 1)));
          attempts++;
          continue;
        }
        return response;
      } catch (e) {
        if (attempts < _maxRetries) {
          await Future<void>.delayed(Duration(milliseconds: 500 * (attempts + 1)));
          attempts++;
        } else {
          rethrow;
        }
      }
    }
  }
  
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
      final response = await _requestWithRetry(() async => http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: await _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
        }),
      ));
      
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
      final response = await _requestWithRetry(() async => http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ));
      
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
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: await _headers,
      ));
      
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

  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    DateTime? dateOfBirth,
    String? timeOfBirth,
    String? placeOfBirth,
    String? fathersOrHusbandsName,
    String? gotra,
    String? caste,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth.toIso8601String().split('T').first;
      if (timeOfBirth != null) body['timeOfBirth'] = timeOfBirth;
      if (placeOfBirth != null) body['placeOfBirth'] = placeOfBirth;
      if (fathersOrHusbandsName != null) body['fathersOrHusbandsName'] = fathersOrHusbandsName;
      if (gotra != null) body['gotra'] = gotra;
      if (caste != null) body['caste'] = caste;

      final response = await _requestWithRetry(() async => http.patch(
        Uri.parse('$baseUrl/auth/me'),
        headers: await _headers,
        body: jsonEncode(body),
      ));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }
  
  // Subscriptions
  static Future<Map<String, dynamic>> getSubscription(String userId) async {
    try {
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/subscriptions/$userId'),
        headers: await _headers,
      ));
      
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
  /// Video Satsang (free YouTube content)
  static Future<List<dynamic>> getVideoSatsangList() async {
    try {
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/video-satsang'),
        headers: await _headers,
      ));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('Get video satsang error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getAvdhanList() async {
    try {
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/avdhan'),
        headers: await _headers,
      ));
      
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
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/samagam'),
        headers: await _headers,
      ));
      
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

  // Announcements (Vishesh Sandesh)
  static Future<List<dynamic>> getAnnouncements({int limit = 5}) async {
    try {
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/announcements?limit=$limit'),
        headers: await _headers,
      ));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('Get announcements error: $e');
      return [];
    }
  }

  /// Get today's Hindu panchang (Tithi, Nakshatra, etc.) from Kaalchakra API proxy.
  /// Returns null if service not configured or on error.
  static Future<Map<String, dynamic>?> getPanchangCurrentDay() async {
    try {
      final tz = DateTime.now().timeZoneName;
      final tzParam = (tz.isNotEmpty && tz != 'Local') ? tz : 'Asia/Kolkata';
      final uri = Uri.parse('$baseUrl/panchang/current-day').replace(
        queryParameters: {'timezone': tzParam},
      );
      final response = await _requestWithRetry(() => http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      if (response.statusCode == 503) return null;
      return null;
    } catch (e) {
      debugPrint('Get panchang error: $e');
      return null;
    }
  }

  /// Get upcoming samagam events (future only, for home hero section)
  static Future<List<dynamic>> getUpcomingSamagams({int limit = 3}) async {
    try {
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/samagam/upcoming?limit=$limit'),
        headers: await _headers,
      ));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('Get upcoming samagams error: $e');
      return [];
    }
  }

  /// Search across Avdhan, Patrika, Samagam, Mantra Notes, Announcements
  static Future<Map<String, dynamic>> search(String query) async {
    try {
      final uri = Uri.parse('$baseUrl/search').replace(
        queryParameters: {'q': query, 'limit': '20'},
      );
      final response = await _requestWithRetry(() async => http.get(
        uri,
        headers: await _headers,
      ));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        data.putIfAbsent('videoSatsang', () => <dynamic>[]);
        return data;
      }
      return _emptySearchResults();
    } catch (e) {
      debugPrint('Search error: $e');
      return _emptySearchResults();
    }
  }

  static Map<String, dynamic> _emptySearchResults() => {
        'avdhan': <dynamic>[],
        'patrika': <dynamic>[],
        'samagam': <dynamic>[],
        'mantraNotes': <dynamic>[],
        'announcements': <dynamic>[],
        'videoSatsang': <dynamic>[],
      };

  // Patrika
  static Future<List<dynamic>> getPatrikaList() async {
    try {
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/patrika'),
        headers: await _headers,
      ));
      
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
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/patrika/purchases/$userId'),
        headers: await _headers,
      ));
      
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
      final response = await _requestWithRetry(() async => http.post(
        Uri.parse('$baseUrl/patrika/purchases'),
        headers: await _headers,
        body: jsonEncode({
          'patrikaId': patrikaId,
          'amount': amount,
          'paymentId': paymentId,
        }),
      ));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to record purchase');
      }
    } catch (e) {
      debugPrint('Record patrika purchase error: $e');
      rethrow;
    }
  }
  
  // Paath Services (public catalog)
  static Future<List<dynamic>> getPaathServices() async {
    try {
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/paath-services'),
        headers: await _headers,
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data;
      } else {
        throw Exception('Failed to get paath services');
      }
    } catch (e) {
      debugPrint('Get paath services error: $e');
      rethrow;
    }
  }

  // Paath Forms
  static Future<String> createPaathForm(Map<String, dynamic> formData) async {
    try {
      final response = await _requestWithRetry(() async => http.post(
        Uri.parse('$baseUrl/paath-forms'),
        headers: await _headers,
        body: jsonEncode(formData),
      ));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['formId'] as String;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['error'] ?? 'Failed to create form');
      }
    } catch (e) {
      debugPrint('Create paath form error: $e');
      rethrow;
    }
  }
  
  static Future<List<dynamic>> getPaathForms(String userId) async {
    try {
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/paath-forms/$userId'),
        headers: await _headers,
      ));

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

  /// Get single paath form detail with installments and paath status (user must own)
  static Future<Map<String, dynamic>> getPaathFormDetail(String formId) async {
    try {
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/paath-forms/detail/$formId'),
        headers: await _headers,
      ));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('Paath form not found');
      } else {
        throw Exception('Failed to get form details');
      }
    } catch (e) {
      debugPrint('Get paath form detail error: $e');
      rethrow;
    }
  }
  
  // Donations
  static Future<Map<String, dynamic>> createDonation(
    double amount, {
    bool isRecurring = false,
    String frequency = 'monthly',
  }) async {
    try {
      final response = await _requestWithRetry(() async => http.post(
        Uri.parse('$baseUrl/donations'),
        headers: await _headers,
        body: jsonEncode({
          'amount': amount,
          'isRecurring': isRecurring,
          'frequency': frequency,
        }),
      ));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['error'] ?? 'Failed to create donation');
      }
    } catch (e) {
      debugPrint('Create donation error: $e');
      rethrow;
    }
  }

  static Future<List<dynamic>> getDonationSubscriptions() async {
    try {
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/donations/subscriptions'),
        headers: await _headers,
      ));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('Get donation subscriptions error: $e');
      return [];
    }
  }

  static Future<void> cancelDonationSubscription(String subscriptionId) async {
    final response = await _requestWithRetry(() async => http.patch(
      Uri.parse('$baseUrl/donations/subscriptions/$subscriptionId'),
      headers: await _headers,
    ));
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(error['error'] ?? 'Failed to cancel subscription');
    }
  }
  
  // App Settings (key-value for dynamic content)

  /// Get all feature flags from backoffice (used by home page)
  static Future<Map<String, bool>> getFeatureFlags() async {
    try {
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/settings'),
        headers: await _headers,
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final flags = <String, bool>{};
        for (final e in data.entries) {
          final obj = e.value;
          if (obj is Map && obj['value'] != null) {
            flags[e.key] = obj['value'].toString().toLowerCase() == 'true';
          }
        }
        return flags;
      }
      return {};
    } catch (e) {
      debugPrint('Get feature flags error: $e');
      return {};
    }
  }

  static Future<String?> getSetting(String key) async {
    try {
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/settings/$key'),
        headers: await _headers,
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['value'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Get setting error: $e');
      return null;
    }
  }

  // Payments (Razorpay)
  static Future<Map<String, dynamic>> createPaymentOrder({
    required double amount,
    required String type,
    Map<String, String> metadata = const {},
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      final response = await _requestWithRetry(() async => http.post(
        Uri.parse('$baseUrl/payments/create-order'),
        headers: await _headers,
        body: jsonEncode({
          'amount': amount,
          'type': type,
          'metadata': metadata,
        }),
      ));

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['error'] ?? 'Failed to create order');
      }
    } catch (e) {
      debugPrint('Create payment order error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String paymentId,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      final response = await _requestWithRetry(() async => http.post(
        Uri.parse('$baseUrl/payments/verify'),
        headers: await _headers,
        body: jsonEncode({
          'orderId': orderId,
          'paymentId': paymentId,
        }),
      ));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['error'] ?? 'Failed to verify payment');
      }
    } catch (e) {
      debugPrint('Verify payment error: $e');
      rethrow;
    }
  }

  // Mantra Notes (user-stored mantras, note-taker style)
  static Future<List<dynamic>> getMantraNotes() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/mantra-notes'),
        headers: await _headers,
      ));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to get mantra notes');
      }
    } catch (e) {
      debugPrint('Get mantra notes error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getMantraNote(String id) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/mantra-notes/$id'),
        headers: await _headers,
      ));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('Mantra note not found');
      } else {
        throw Exception('Failed to get mantra note');
      }
    } catch (e) {
      debugPrint('Get mantra note error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createMantraNote({
    required String heading,
    String? description,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      final response = await _requestWithRetry(() async => http.post(
        Uri.parse('$baseUrl/mantra-notes'),
        headers: await _headers,
        body: jsonEncode({'heading': heading, 'description': description ?? ''}),
      ));

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['error'] ?? 'Failed to create mantra note');
      }
    } catch (e) {
      debugPrint('Create mantra note error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateMantraNote({
    required String id,
    required String heading,
    String? description,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      final response = await _requestWithRetry(() async => http.put(
        Uri.parse('$baseUrl/mantra-notes/$id'),
        headers: await _headers,
        body: jsonEncode({'heading': heading, 'description': description ?? ''}),
      ));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['error'] ?? 'Failed to update mantra note');
      }
    } catch (e) {
      debugPrint('Update mantra note error: $e');
      rethrow;
    }
  }

  static Future<void> deleteMantraNote(String id) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      final response = await _requestWithRetry(() async => http.delete(
        Uri.parse('$baseUrl/mantra-notes/$id'),
        headers: await _headers,
      ));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete mantra note');
      }
    } catch (e) {
      debugPrint('Delete mantra note error: $e');
      rethrow;
    }
  }

  static Future<List<dynamic>> getDonations(String userId) async {
    try {
      final response = await _requestWithRetry(() async => http.get(
        Uri.parse('$baseUrl/donations/$userId'),
        headers: await _headers,
      ));
      
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


