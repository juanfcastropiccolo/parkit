import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../config/supabase_config.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener usuario actual
  User? get currentUser => _supabase.auth.currentUser;
  
  // Stream del estado de autenticación
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Verificar si el usuario está autenticado
  bool get isAuthenticated => currentUser != null;

  // Registrar nuevo usuario
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? nombre,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'nombre': nombre},
      );
      
      // Si el registro es exitoso, crear el perfil del usuario
      if (response.user != null) {
        await _createUserProfile(response.user!, nombre);
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Iniciar sesión
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener perfil del usuario
  Future<UserModel?> getUserProfile() async {
    try {
      if (!isAuthenticated) return null;
      
      final response = await _supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', currentUser!.id)
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Actualizar perfil del usuario
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _supabase
          .from(SupabaseConfig.usersTable)
          .update(user.toJson())
          .eq('id', user.id);
    } catch (e) {
      rethrow;
    }
  }

  // Crear perfil del usuario en la base de datos
  Future<void> _createUserProfile(User user, String? nombre) async {
    try {
      final userModel = UserModel(
        id: user.id,
        email: user.email ?? '',
        nombre: nombre ?? user.userMetadata?['nombre'],
      );
      
      await _supabase
          .from(SupabaseConfig.usersTable)
          .insert(userModel.toJson());
    } catch (e) {
      // Si el usuario ya existe, no hacer nada
    }
  }

  // Resetear contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }
} 