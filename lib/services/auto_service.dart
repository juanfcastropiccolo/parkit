import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auto_model.dart';
import '../config/supabase_config.dart';

class AutoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Crear nuevo auto
  Future<AutoModel> crearAuto({
    required String marca,
    required String modelo,
    int? anio,
    required int largoCm,
    required int anchoCm,
    int? altoCm,
  }) async {
    try {
      final data = {
        'marca': marca,
        'modelo': modelo,
        'anio': anio,
        'largo_cm': largoCm,
        'ancho_cm': anchoCm,
        'alto_cm': altoCm,
      };

      final response = await _supabase
          .from(SupabaseConfig.autosTable)
          .insert(data)
          .select()
          .single();

      return AutoModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Obtener auto por ID
  Future<AutoModel?> getAutoPorId(String autoId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.autosTable)
          .select()
          .eq('id', autoId)
          .maybeSingle();

      if (response == null) return null;
      return AutoModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
  
  // Asignar auto creado al usuario actual (update users.auto_id)
  Future<void> asignarAutoAUsuario(String autoId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    await _supabase
        .from(SupabaseConfig.usersTable)
        .update({'auto_id': autoId})
        .eq('id', user.id);
  }

  // Obtener auto del usuario actual
  Future<AutoModel?> getAutoUsuario() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      // Primero obtener el auto_id del usuario
      final userResponse = await _supabase
          .from(SupabaseConfig.usersTable)
          .select('auto_id')
          .eq('id', userId)
          .maybeSingle();

      if (userResponse == null || userResponse['auto_id'] == null) {
        return null;
      }

      // Luego obtener los datos del auto
      final autoResponse = await _supabase
          .from(SupabaseConfig.autosTable)
          .select()
          .eq('id', userResponse['auto_id'])
          .maybeSingle();

      if (autoResponse == null) return null;
      return AutoModel.fromJson(autoResponse);
    } catch (e) {
      return null;
    }
  }

  // Actualizar auto
  Future<AutoModel> actualizarAuto(AutoModel auto) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.autosTable)
          .update(auto.toJson())
          .eq('id', auto.id)
          .select()
          .single();

      return AutoModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }


  // Eliminar auto
  Future<void> eliminarAuto(String autoId) async {
    try {
      await _supabase
          .from(SupabaseConfig.autosTable)
          .delete()
          .eq('id', autoId);
    } catch (e) {
      rethrow;
    }
  }

  // Obtener dimensiones estimadas por marca y modelo (mock API)
  Future<Map<String, int>?> getDimensionesEstimadas(
    String marca,
    String modelo,
    int? anio,
  ) async {
    // Simulación de una API externa que devuelve dimensiones
    // En una implementación real, esto sería una llamada a una API externa
    await Future.delayed(const Duration(milliseconds: 500));

    // Datos mock basados en autos comunes en Argentina
    final dimensionesMock = {
      'toyota-corolla': {'largo_cm': 460, 'ancho_cm': 178},
      'volkswagen-gol': {'largo_cm': 389, 'ancho_cm': 168},
      'chevrolet-onix': {'largo_cm': 412, 'ancho_cm': 173},
      'ford-ka': {'largo_cm': 374, 'ancho_cm': 169},
      'renault-sandero': {'largo_cm': 413, 'ancho_cm': 173},
      'fiat-cronos': {'largo_cm': 443, 'ancho_cm': 173},
      'peugeot-208': {'largo_cm': 406, 'ancho_cm': 175},
      'honda-city': {'largo_cm': 453, 'ancho_cm': 170},
      'nissan-versa': {'largo_cm': 456, 'ancho_cm': 169},
      'hyundai-hb20': {'largo_cm': 402, 'ancho_cm': 172},
    };

    final key = '${marca.toLowerCase()}-${modelo.toLowerCase()}';
    return dimensionesMock[key];
  }

  // Obtener lista de marcas disponibles
  List<String> getMarcasDisponibles() {
    return [
      'Toyota',
      'Volkswagen',
      'Chevrolet',
      'Ford',
      'Renault',
      'Fiat',
      'Peugeot',
      'Honda',
      'Nissan',
      'Hyundai',
      'Citroën',
      'Suzuki',
      'Jeep',
      'Kia',
      'Mitsubishi',
    ];
  }

  // Obtener modelos por marca (mock)
  List<String> getModelosPorMarca(String marca) {
    final modelos = {
      'Toyota': ['Corolla', 'Etios', 'Yaris', 'Hilux', 'SW4', 'Camry'],
      'Volkswagen': ['Gol', 'Polo', 'Vento', 'Suran', 'Amarok', 'Tiguan'],
      'Chevrolet': ['Onix', 'Prisma', 'Cruze', 'Tracker', 'S10', 'Spin'],
      'Ford': ['Ka', 'Focus', 'EcoSport', 'Ranger', 'Territory', 'Mondeo'],
      'Renault': ['Sandero', 'Logan', 'Fluence', 'Duster', 'Captur', 'Kangoo'],
      'Fiat': ['Cronos', 'Argo', 'Strada', 'Toro', 'Mobi', 'Uno'],
      'Peugeot': ['208', '2008', '308', '408', '3008', '5008'],
      'Honda': ['City', 'Civic', 'Fit', 'HR-V', 'CR-V', 'Pilot'],
      'Nissan': ['Versa', 'March', 'Sentra', 'Kicks', 'X-Trail', 'Frontier'],
      'Hyundai': ['HB20', 'Accent', 'Elantra', 'Creta', 'Tucson', 'Santa Fe'],
    };

    return modelos[marca] ?? [];
  }
} 