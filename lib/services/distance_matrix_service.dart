import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/estacionamiento_model.dart';

class DistanceElement {
  final String distanceText; // "1.2 km"
  final int distanceValue;   // meters
  final String durationText; // "5 mins"
  final int durationValue;   // seconds
  final String status;

  DistanceElement({
    required this.distanceText,
    required this.distanceValue,
    required this.durationText,
    required this.durationValue,
    required this.status,
  });

  factory DistanceElement.fromJson(Map<String, dynamic> json) {
    if (json['status'] != 'OK') {
      return DistanceElement(
        distanceText: 'N/A',
        distanceValue: 0,
        durationText: 'N/A',
        durationValue: 0,
        status: json['status'] ?? 'UNKNOWN_ERROR',
      );
    }

    return DistanceElement(
      distanceText: json['distance']['text'] ?? 'N/A',
      distanceValue: json['distance']['value'] ?? 0,
      durationText: json['duration']['text'] ?? 'N/A',
      durationValue: json['duration']['value'] ?? 0,
      status: json['status'] ?? 'OK',
    );
  }

  bool get isValid => status == 'OK' && distanceValue > 0;
  
  // Get walking time estimate (roughly 3x driving time)
  String get walkingTime {
    if (!isValid) return 'N/A';
    final walkingSeconds = (durationValue * 3).round();
    final minutes = (walkingSeconds / 60).round();
    return '${minutes} min caminando';
  }
}

class DistanceMatrixService {
  static final DistanceMatrixService _instance = DistanceMatrixService._internal();
  factory DistanceMatrixService() => _instance;
  DistanceMatrixService._internal();

  // Calculate distances from origin to multiple destinations
  Future<List<DistanceElement>> calculateDistances({
    required double originLat,
    required double originLng,
    required List<EstacionamientoModel> destinations,
    String mode = 'driving', // driving, walking, transit
  }) async {
    if (destinations.isEmpty) return [];

    try {
      // Build destinations string
      final destinationsStr = destinations
          .map((dest) => '${dest.lat},${dest.lng}')
          .join('|');

      final url = Uri.parse(
        '${SupabaseConfig.googleDistanceMatrixBaseUrl}'
        '?origins=$originLat,$originLng'
        '&destinations=$destinationsStr'
        '&mode=$mode'
        '&units=metric'
        '&language=es'
        '&region=ar'
        '&key=${SupabaseConfig.googleDistanceMatrixApiKey}'
      );

      debugPrint('Distance Matrix request: $url');

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['rows'].isNotEmpty) {
          final elements = (data['rows'][0]['elements'] as List)
              .map((element) => DistanceElement.fromJson(element))
              .toList();
          
          debugPrint('Distance Matrix calculated for ${elements.length} destinations');
          return elements;
        } else {
          debugPrint('Distance Matrix API error: ${data['status']}');
          return [];
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Distance Matrix error: $e');
      return [];
    }
  }

  // Calculate distance to single destination
  Future<DistanceElement?> calculateDistance({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String mode = 'driving',
  }) async {
    try {
      final url = Uri.parse(
        '${SupabaseConfig.googleDistanceMatrixBaseUrl}'
        '?origins=$originLat,$originLng'
        '&destinations=$destLat,$destLng'
        '&mode=$mode'
        '&units=metric'
        '&language=es'
        '&region=ar'
        '&key=${SupabaseConfig.googleDistanceMatrixApiKey}'
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && 
            data['rows'].isNotEmpty && 
            data['rows'][0]['elements'].isNotEmpty) {
          
          return DistanceElement.fromJson(data['rows'][0]['elements'][0]);
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Distance calculation error: $e');
      return null;
    }
  }

  // Sort parking spots by distance
  Future<List<EstacionamientoModel>> sortByDistance({
    required double originLat,
    required double originLng,
    required List<EstacionamientoModel> parkingSpots,
  }) async {
    if (parkingSpots.isEmpty) return [];

    final distances = await calculateDistances(
      originLat: originLat,
      originLng: originLng,
      destinations: parkingSpots,
    );

    // Create list of parking spots with their distances
    final spotsWithDistance = <Map<String, dynamic>>[];
    
    for (int i = 0; i < parkingSpots.length && i < distances.length; i++) {
      spotsWithDistance.add({
        'spot': parkingSpots[i],
        'distance': distances[i],
      });
    }

    // Sort by distance (valid distances first, then by distance value)
    spotsWithDistance.sort((a, b) {
      final distA = a['distance'] as DistanceElement;
      final distB = b['distance'] as DistanceElement;
      
      if (!distA.isValid && !distB.isValid) return 0;
      if (!distA.isValid) return 1;
      if (!distB.isValid) return -1;
      
      return distA.distanceValue.compareTo(distB.distanceValue);
    });

    return spotsWithDistance
        .map((item) => item['spot'] as EstacionamientoModel)
        .toList();
  }

  // Get nearby parking spots within a radius
  Future<List<EstacionamientoModel>> getNearbySpots({
    required double originLat,
    required double originLng,
    required List<EstacionamientoModel> allSpots,
    int maxDistanceMeters = 2000, // 2km default
  }) async {
    final distances = await calculateDistances(
      originLat: originLat,
      originLng: originLng,
      destinations: allSpots,
    );

    final nearbySpots = <EstacionamientoModel>[];
    
    for (int i = 0; i < allSpots.length && i < distances.length; i++) {
      final distance = distances[i];
      if (distance.isValid && distance.distanceValue <= maxDistanceMeters) {
        nearbySpots.add(allSpots[i]);
      }
    }

    return nearbySpots;
  }
} 