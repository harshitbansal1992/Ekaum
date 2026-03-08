// Geocoding service for place autocomplete
// Uses Nominatim OpenStreetMap API (same as reference implementation)

import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceSuggestion {
  final String displayName;
  final double? latitude;
  final double? longitude;
  final String? country;
  final String? state;

  PlaceSuggestion({
    required this.displayName,
    this.latitude,
    this.longitude,
    this.country,
    this.state,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      displayName: json['display_name'] ?? json['name'] ?? '',
      latitude: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      longitude: json['lon'] != null ? double.tryParse(json['lon'].toString()) : null,
      country: json['address']?['country'] ?? json['country'],
      state: json['address']?['state'] ?? json['state'],
    );
  }
}

class GeocodingService {
  // Nominatim API endpoint (same as reference)
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  
  // Rate limiting: 1 request per second (as per Nominatim usage policy)
  static DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(seconds: 1);

  // Search for places (autocomplete)
  static Future<List<PlaceSuggestion>> searchPlaces(String query) async {
    if (query.isEmpty || query.length < 2) {
      return [];
    }

    // Rate limiting
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        await Future.delayed(_minRequestInterval - timeSinceLastRequest);
      }
    }

    try {
      final uri = Uri.parse(
        '$_nominatimBaseUrl/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&limit=5'
        '&addressdetails=1'
        '&extratags=0'
        '&namedetails=0'
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'BSLND-App/1.0', // Required by Nominatim
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _lastRequestTime = DateTime.now();
        
        return data.map((item) => PlaceSuggestion.fromJson(item)).toList();
      } else {
        // Try fallback: Photon API (Komoot's open-source geocoder)
        return await _searchPlacesPhoton(query);
      }
    } catch (e) {
      // Fallback to Photon API on error
      return await _searchPlacesPhoton(query);
    }
  }

  // Fallback: Photon API (same as reference implementation)
  static Future<List<PlaceSuggestion>> _searchPlacesPhoton(String query) async {
    try {
      final uri = Uri.parse(
        'https://photon.komoot.io/api/'
        '?q=${Uri.encodeComponent(query)}'
        '&limit=5'
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> features = data['features'] ?? [];
        
        return features.map((feature) {
          final props = feature['properties'] ?? {};
          final coords = feature['geometry']?['coordinates'] ?? [];
          
          return PlaceSuggestion(
            displayName: props['name'] ?? 
                        (props['city'] != null ? '${props['city']}, ${props['country']}' : '') ??
                        query,
            longitude: coords.isNotEmpty ? coords[0]?.toDouble() : null,
            latitude: coords.length > 1 ? coords[1]?.toDouble() : null,
            country: props['country'],
            state: props['state'],
          );
        }).toList();
      }
    } catch (e) {
      // Return empty list on error
    }
    
    return [];
  }
}

