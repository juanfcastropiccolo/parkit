import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Configuración por defecto para Argentina (Buenos Aires)
  static const double defaultLat = -34.6118;
  static const double defaultLng = -58.3960;

  // Configuraciones de precisión
  static const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // metros
  );

  // Verificar si los servicios de ubicación están habilitados
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Verificar permisos de ubicación
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  // Solicitar permisos de ubicación
  Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Permisos de ubicación denegados');
        return LocationPermission.denied;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Permisos de ubicación denegados permanentemente');
      return LocationPermission.deniedForever;
    }
    
    debugPrint('Permisos de ubicación concedidos');
    return permission;
  }

  // Verificar si tenemos permisos adecuados
  Future<bool> hasLocationPermission() async {
    final permission = await checkLocationPermission();
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }

  // Obtener ubicación actual
  Future<Position?> getCurrentLocation() async {
    try {
      // Verificar si el servicio está habilitado
      if (!await isLocationServiceEnabled()) {
        debugPrint('Servicio de ubicación deshabilitado');
        return null;
      }

      // Verificar permisos
      if (!await hasLocationPermission()) {
        final permission = await requestLocationPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return null;
        }
      }

      // Obtener posición actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      debugPrint('Ubicación obtenida: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('Error al obtener ubicación: $e');
      return null;
    }
  }

  // Obtener ubicación con timeout
  Future<Position?> getCurrentLocationWithTimeout({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      return await getCurrentLocation().timeout(timeout);
    } catch (e) {
      debugPrint('Timeout al obtener ubicación: $e');
      return null;
    }
  }

  // Obtener ubicación por defecto (Buenos Aires)
  Position getDefaultLocation() {
    return Position(
      latitude: defaultLat,
      longitude: defaultLng,
      timestamp: DateTime.now(),
      accuracy: 100.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }

  // Obtener ubicación actual o por defecto
  Future<Position> getCurrentOrDefaultLocation() async {
    final position = await getCurrentLocation();
    return position ?? getDefaultLocation();
  }

  // Stream de cambios de ubicación
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Calcular distancia entre dos puntos
  double calculateDistance(
    double lat1, double lng1,
    double lat2, double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  // Verificar si un punto está dentro de un radio específico
  bool isWithinRadius(
    double currentLat, double currentLng,
    double targetLat, double targetLng,
    double radiusMeters,
  ) {
    final distance = calculateDistance(currentLat, currentLng, targetLat, targetLng);
    return distance <= radiusMeters;
  }

  // Encontrar lugares cercanos dentro de un radio
  List<T> findNearbyPlaces<T>({
    required double currentLat,
    required double currentLng,
    required List<T> places,
    required double Function(T) getLatitude,
    required double Function(T) getLongitude,
    double radiusMeters = 1000, // 1km por defecto
  }) {
    return places.where((place) {
      final placeLat = getLatitude(place);
      final placeLng = getLongitude(place);
      return isWithinRadius(currentLat, currentLng, placeLat, placeLng, radiusMeters);
    }).toList();
  }

  // Ordenar lugares por proximidad
  List<T> sortByDistance<T>({
    required double currentLat,
    required double currentLng,
    required List<T> places,
    required double Function(T) getLatitude,
    required double Function(T) getLongitude,
  }) {
    final placesWithDistance = places.map((place) {
      final distance = calculateDistance(
        currentLat, currentLng,
        getLatitude(place), getLongitude(place),
      );
      return {'place': place, 'distance': distance};
    }).toList();

    placesWithDistance.sort((a, b) => 
        (a['distance'] as double).compareTo(b['distance'] as double));

    return placesWithDistance.map((item) => item['place'] as T).toList();
  }

  // Abrir configuración de ubicación del sistema
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('Error al abrir configuración de ubicación: $e');
    }
  }

  // Abrir configuración de la app
  Future<void> openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('Error al abrir configuración de la app: $e');
    }
  }

  // Formatear coordenadas para mostrar
  String formatCoordinates(double lat, double lng, {int decimals = 6}) {
    return '${lat.toStringAsFixed(decimals)}, ${lng.toStringAsFixed(decimals)}';
  }

  // Verificar si las coordenadas están en Argentina (aproximado)
  bool isInArgentina(double lat, double lng) {
    // Límites aproximados de Argentina
    const double northBound = -21.0;
    const double southBound = -55.0;
    const double westBound = -74.0;
    const double eastBound = -53.0;

    return lat >= southBound && lat <= northBound &&
           lng >= westBound && lng <= eastBound;
  }

  // Obtener nombre de la zona aproximada (mock)
  String getApproximateArea(double lat, double lng) {
    // En una implementación real, usarías geocoding reverso
    if (!isInArgentina(lat, lng)) return 'Ubicación desconocida';

    // Zonas aproximadas de Buenos Aires
    if (lat > -34.5 && lat < -34.7 && lng > -58.6 && lng < -58.3) {
      return 'CABA';
    } else if (lat > -34.9 && lat < -34.4 && lng > -58.8 && lng < -58.0) {
      return 'Gran Buenos Aires';
    } else {
      return 'Argentina';
    }
  }
} 