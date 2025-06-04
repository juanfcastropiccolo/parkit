import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/estacionamiento_model.dart';
import '../models/auto_model.dart';
import '../config/supabase_config.dart';

class EstacionamientoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener todos los lugares libres recientes
  Future<List<EstacionamientoModel>> getLugaresLibres({
    Duration maxAge = const Duration(minutes: 15),
  }) async {
    try {
      final cutoff = DateTime.now().subtract(maxAge).toIso8601String();
      final response = await _supabase
          .from(SupabaseConfig.estacionamientosTable)
          .select()
          .eq('status', 'libre')
          .gte('timestamp', cutoff)
          .order('timestamp', ascending: false);

      return (response as List)
          .map((data) => EstacionamientoModel.fromJson(data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener lugares libres filtrados por tamaño de auto
  Future<List<EstacionamientoModel>> getLugaresLibresParaAuto(
    AutoModel auto, {
    Duration maxAge = const Duration(minutes: 15),
  }) async {
    try {
      final cutoff = DateTime.now().subtract(maxAge).toIso8601String();
      final response = await _supabase
          .from(SupabaseConfig.estacionamientosTable)
          .select()
          .eq('status', 'libre')
          .gte('timestamp', cutoff)
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

  // Eliminar lugares libres expirados
  Future<void> limpiarLugaresExpirados(Duration maxAge) async {
    try {
      final cutoff = DateTime.now().subtract(maxAge).toIso8601String();
      await _supabase
          .from(SupabaseConfig.estacionamientosTable)
          .delete()
          .eq('status', 'libre')
          .lt('timestamp', cutoff);
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
          .from(SupabaseConfig.estacionamientosTable)
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
          .from(SupabaseConfig.estacionamientosTable)
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
          .from(SupabaseConfig.estacionamientosTable)
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
          .from(SupabaseConfig.estacionamientosTable)
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
          .from(SupabaseConfig.estacionamientosTable)
          .delete()
          .eq('status', 'libre')
          .lt('timestamp', fechaLimite.toIso8601String());
    } catch (e) {
      rethrow;
    }
  }

  // Stream en tiempo real de cambios en estacionamientos
  Stream<List<EstacionamientoModel>> lugaresLibresStream({
    Duration maxAge = const Duration(minutes: 15),
  }) {
    final cutoff = DateTime.now().subtract(maxAge).toIso8601String();
    return _supabase
        .from(SupabaseConfig.estacionamientosTable)
        .stream(primaryKey: ['id'])
        .eq('status', 'libre')
        .gte('timestamp', cutoff)
        .map((data) =>
            data.map((item) => EstacionamientoModel.fromJson(item)).toList());
  }
}
