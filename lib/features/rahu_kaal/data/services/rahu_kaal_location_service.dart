import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class RahuKaalLocationService {
  static const double _defaultLat = 22.7196;
  static const double _defaultLon = 75.8577;

  static Future<RahuKaalLocationResult> getCurrentLocation({
    Duration webTimeout = const Duration(seconds: 10),
  }) async {
    if (kIsWeb) {
      return _getWebLocationOrFallback(webTimeout);
    }
    return _getDeviceLocation();
  }

  static Future<RahuKaalLocationResult> _getDeviceLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const RahuKaalLocationException('Location services are disabled. Please enable them.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const RahuKaalLocationException('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const RahuKaalLocationException(
        'Location permissions are permanently denied. Please enable in settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final locationDetails = await _resolveLocationDetails(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    return RahuKaalLocationResult(
      position: position,
      latitude: position.latitude,
      longitude: position.longitude,
      cityName: locationDetails.cityName,
      stateName: locationDetails.stateName,
      countryCode: locationDetails.countryCode,
      displayName: locationDetails.displayName,
    );
  }

  static Future<RahuKaalLocationResult> _getWebLocationOrFallback(Duration timeout) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _buildIndoreFallback();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return _buildIndoreFallback();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(timeout);

      final locationDetails = await _resolveLocationDetails(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return RahuKaalLocationResult(
        position: position,
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: locationDetails.cityName,
        stateName: locationDetails.stateName,
        countryCode: locationDetails.countryCode,
        displayName: locationDetails.displayName,
      );
    } catch (_) {
      return _buildIndoreFallback();
    }
  }

  static RahuKaalLocationResult _buildIndoreFallback() {
    return const RahuKaalLocationResult(
      latitude: _defaultLat,
      longitude: _defaultLon,
      cityName: 'Indore',
      stateName: 'Madhya Pradesh',
      countryCode: 'IN',
      displayName: 'Indore, India',
    );
  }

  static Future<_LocationDetails> _resolveLocationDetails({
    required double latitude,
    required double longitude,
  }) async {
    final latLonFallback = _LocationDetails(
      cityName: 'Lat ${latitude.toStringAsFixed(4)}',
      stateName: '',
      countryCode: '',
      displayName: 'Lat ${latitude.toStringAsFixed(4)}, Lon ${longitude.toStringAsFixed(4)}',
    );

    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) {
        return latLonFallback;
      }

      final placemark = placemarks.first;
      final city = [
        placemark.locality,
        placemark.subAdministrativeArea,
        placemark.administrativeArea,
      ].firstWhere((value) => (value ?? '').trim().isNotEmpty, orElse: () => '') ?? '';
      final state = (placemark.administrativeArea ?? '').trim();
      final countryCode = (placemark.isoCountryCode ?? '').trim();
      final country = (placemark.country ?? '').trim();

      final displayParts = <String>[city, state, country].where((part) => part.isNotEmpty).toList();
      final displayName = displayParts.isNotEmpty ? displayParts.join(', ') : latLonFallback.displayName;

      return _LocationDetails(
        cityName: city.isNotEmpty ? city : latLonFallback.cityName,
        stateName: state,
        countryCode: countryCode,
        displayName: displayName,
      );
    } catch (_) {
      return latLonFallback;
    }
  }
}

class RahuKaalLocationResult {
  const RahuKaalLocationResult({
    this.position,
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.stateName,
    required this.countryCode,
    required this.displayName,
  });

  final Position? position;
  final double latitude;
  final double longitude;
  final String cityName;
  final String stateName;
  final String countryCode;
  final String displayName;
}

class RahuKaalLocationException implements Exception {
  const RahuKaalLocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _LocationDetails {
  const _LocationDetails({
    required this.cityName,
    required this.stateName,
    required this.countryCode,
    required this.displayName,
  });

  final String cityName;
  final String stateName;
  final String countryCode;
  final String displayName;
}

