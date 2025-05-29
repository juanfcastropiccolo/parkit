import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/estacionamiento_model.dart';
import '../models/auto_model.dart';
import '../services/distance_matrix_service.dart';
import '../services/geocoding_service.dart';

class EstacionamientoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener todos los lugares libres
  Future<List<EstacionamientoModel>> getLugaresLibres() async {
    try {
      final response = await _supabase
          .from('estacionamientos')
          .select()
          .eq('status', 'libre')
          .order('timestamp', ascending: false);

      return (response as List)
          .map((data) => EstacionamientoModel.fromJson(data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener lugares libres filtrados por tamaño de auto
  Future<List<EstacionamientoModel>> getLugaresLibresParaAuto(AutoModel auto) async {
    try {
      final response = await _supabase
          .from('estacionamientos')
          .select()
          .eq('status', 'libre')
          .gte('largo_cm', auto.largoCm + 10) // Margen de seguridad
          .gte('ancho_cm', auto.anchoCm + 10)
          .order('timestamp', ascending: false);

      return (response as List)
          .map((data) => EstacionamientoModel.fromJson(data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Compartir lugar ocupado
  Future<EstacionamientoModel> compartirLugarOcupado({
    required double lat,
    required double lng,
    required AutoModel auto,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final data = {
        'user_id': userId,
        'lat': lat,
        'lng': lng,
        'largo_cm': auto.largoCm,
        'ancho_cm': auto.anchoCm,
        'status': 'ocupado',
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('estacionamientos')
          .insert(data)
          .select()
          .single();

      return EstacionamientoModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Marcar lugar como libre
  Future<void> marcarLugarComoLibre(String estacionamientoId) async {
    try {
      await _supabase
          .from('estacionamientos')
          .update({
            'status': 'libre',
            'timestamp': DateTime.now().toIso8601String(),
          })
          .eq('id', estacionamientoId);
    } catch (e) {
      rethrow;
    }
  }

  // Obtener lugar ocupado actual del usuario
  Future<EstacionamientoModel?> getLugarOcupadoUsuario() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('estacionamientos')
          .select()
          .eq('user_id', userId)
          .eq('status', 'ocupado')
          .maybeSingle();

      if (response == null) return null;
      return EstacionamientoModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Ocupar un lugar libre
  Future<void> ocuparLugar(String estacionamientoId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      await _supabase
          .from('estacionamientos')
          .update({
            'status': 'ocupado',
            'user_id': userId,
            'timestamp': DateTime.now().toIso8601String(),
          })
          .eq('id', estacionamientoId);
    } catch (e) {
      rethrow;
    }
  }

  // Limpiar lugares antiguos (llamada manual o desde un cron job)
  Future<void> limpiarLugaresAntiguos({int horasAntiguas = 24}) async {
    try {
      final fechaLimite = DateTime.now().subtract(Duration(hours: horasAntiguas));
      
      await _supabase
          .from('estacionamientos')
          .delete()
          .eq('status', 'libre')
          .lt('timestamp', fechaLimite.toIso8601String());
    } catch (e) {
      rethrow;
    }
  }

  // Stream en tiempo real de cambios en estacionamientos
  Stream<List<EstacionamientoModel>> get lugaresLibresStream {
    return _supabase
        .from('estacionamientos')
        .stream(primaryKey: ['id'])
        .eq('status', 'libre')
        .map((data) => data
            .map((item) => EstacionamientoModel.fromJson(item))
            .toList());
  }

  // Get lugares libres sorted by distance
  Future<List<EstacionamientoModel>> getLugaresLibresByDistance({
    required double userLat,
    required double userLng,
  }) async {
    try {
      final lugares = await getLugaresLibres();
      final distanceService = DistanceMatrixService();
      
      return await distanceService.sortByDistance(
        originLat: userLat,
        originLng: userLng,
        parkingSpots: lugares,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get nearby lugares libres within radius
  Future<List<EstacionamientoModel>> getNearbyLugaresLibres({
    required double userLat,
    required double userLng,
    int radiusMeters = 2000,
  }) async {
    try {
      final lugares = await getLugaresLibres();
      final distanceService = DistanceMatrixService();
      
      return await distanceService.getNearbySpots(
        originLat: userLat,
        originLng: userLng,
        allSpots: lugares,
        maxDistanceMeters: radiusMeters,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Compartir lugar with address validation
  Future<EstacionamientoModel> compartirLugarConDireccion({
    required String direccion,
    required AutoModel auto,
  }) async {
    try {
      final geocodingService = GeocodingService();
      final results = await geocodingService.geocodeAddress(direccion);
      
      if (results.isEmpty) {
        throw Exception('No se encontró la dirección especificada');
      }
      
      final location = results.first;
      
      return await compartirLugarOcupado(
        lat: location.lat,
        lng: location.lng,
        auto: auto,
      );
    } catch (e) {
      rethrow;
    }
  }
} 