import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

class GeocodingResult {
  final String formattedAddress;
  final double lat;
  final double lng;
  final String placeId;
  final List<String> addressComponents;

  GeocodingResult({
    required this.formattedAddress,
    required this.lat,
    required this.lng,
    required this.placeId,
    required this.addressComponents,
  });

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry']['location'];
    final components = (json['address_components'] as List)
        .map((comp) => comp['long_name'] as String)
        .toList();
    
    return GeocodingResult(
      formattedAddress: json['formatted_address'] ?? '',
      lat: (geometry['lat'] as num).toDouble(),
      lng: (geometry['lng'] as num).toDouble(),
      placeId: json['place_id'] ?? '',
      addressComponents: components,
    );
  }
}

class GeocodingService {
  static final GeocodingService _instance = GeocodingService._internal();
  factory GeocodingService() => _instance;
  GeocodingService._internal();

  // Convertir dirección a coordenadas (geocoding)
  Future<List<GeocodingResult>> geocodeAddress(String address) async {
    try {
      final encodedAddress = Uri.encodeComponent(address);
      final url = Uri.parse(
        '${SupabaseConfig.googleGeocodingBaseUrl}'
        '?address=$encodedAddress'
        '&key=${SupabaseConfig.googleGeocodingApiKey}'
        '&region=ar' // Bias results to Argentina
        '&language=es' // Spanish language results
      );

      debugPrint('Geocoding request: $url');

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final results = (data['results'] as List)
              .map((result) => GeocodingResult.fromJson(result))
              .toList();
          
          debugPrint('Geocoding found ${results.length} results');
          return results;
        } else {
          debugPrint('Geocoding API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
          return [];
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
      return [];
    }
  }

  // Convertir coordenadas a dirección (reverse geocoding)
  Future<GeocodingResult?> reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        '${SupabaseConfig.googleGeocodingBaseUrl}'
        '?latlng=$lat,$lng'
        '&key=${SupabaseConfig.googleGeocodingApiKey}'
        '&language=es' // Spanish language results
      );

      debugPrint('Reverse geocoding request: $url');

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = GeocodingResult.fromJson(data['results'][0]);
          debugPrint('Reverse geocoding result: ${result.formattedAddress}');
          return result;
        } else {
          debugPrint('Reverse geocoding API error: ${data['status']}');
          return null;
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
      return null;
    }
  }

  // Validar si una dirección existe en Argentina
  Future<bool> isValidArgentineAddress(String address) async {
    final results = await geocodeAddress('$address, Argentina');
    
    for (final result in results) {
      // Check if the result contains Argentina in the address components
      if (result.addressComponents.any((component) => 
          component.toLowerCase().contains('argentina'))) {
        return true;
      }
    }
    
    return false;
  }

  // Obtener dirección corta (calle y número)
  String getShortAddress(String formattedAddress) {
    // Extract street name and number from formatted address
    final parts = formattedAddress.split(',');
    return parts.isNotEmpty ? parts[0].trim() : formattedAddress;
  }

  // Buscar direcciones con autocompletado
  Future<List<String>> searchAddressSuggestions(String query) async {
    // This would typically use the Places Autocomplete API
    // For now, return basic geocoding results
    final results = await geocodeAddress(query);
    return results.map((r) => r.formattedAddress).toList();
  }
} 