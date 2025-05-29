import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  // Inicializar el estado de autenticación
  void _initializeAuth() {
    // Escuchar cambios en el estado de autenticación
    _authService.authStateChanges.listen((AuthState authState) {
      _handleAuthStateChange(authState);
    });

    // Cargar usuario actual si existe sesión
    _loadCurrentUser();
  }

  // Manejar cambios en el estado de autenticación
  void _handleAuthStateChange(AuthState authState) {
    final event = authState.event;
    
    switch (event) {
      case AuthChangeEvent.signedIn:
        _loadCurrentUser();
        break;
      case AuthChangeEvent.signedOut:
        _currentUser = null;
        notifyListeners();
        break;
      case AuthChangeEvent.userUpdated:
        _loadCurrentUser();
        break;
      default:
        break;
    }
  }

  // Cargar datos del usuario actual
  Future<void> _loadCurrentUser() async {
    if (!_authService.isAuthenticated) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    try {
      final userProfile = await _authService.getUserProfile();
      _currentUser = userProfile;
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar perfil del usuario: $e');
    }
  }

  // Registrar nuevo usuario
  Future<bool> signUp({
    required String email,
    required String password,
    String? nombre,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        nombre: nombre,
      );

      if (response.user != null) {
        await _loadCurrentUser();
        _setLoading(false);
        return true;
      } else {
        _setError('Error al crear la cuenta');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  // Iniciar sesión
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadCurrentUser();
        _setLoading(false);
        return true;
      } else {
        _setError('Credenciales incorrectas');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await _authService.signOut();
      _currentUser = null;
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  // Actualizar perfil del usuario
  Future<bool> updateProfile({
    String? nombre,
    String? autoId,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final updatedUser = _currentUser!.copyWith(
        nombre: nombre ?? _currentUser!.nombre,
        autoId: autoId ?? _currentUser!.autoId,
      );

      await _authService.updateUserProfile(updatedUser);
      _currentUser = updatedUser;
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  // Resetear contraseña
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  // Recargar datos del usuario
  Future<void> refreshUser() async {
    await _loadCurrentUser();
  }

  // Métodos privados para manejo de estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Convertir errores a mensajes amigables
  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Email o contraseña incorrectos';
        case 'Email rate limit exceeded':
          return 'Demasiados intentos. Intenta más tarde';
        case 'User already registered':
          return 'El email ya está registrado';
        case 'Password should be at least 6 characters':
          return 'La contraseña debe tener al menos 6 caracteres';
        case 'Unable to validate email address: invalid format':
          return 'Formato de email inválido';
        default:
          return error.message;
      }
    }
    
    return error.toString();
  }

  // Limpiar errores manualmente
  void clearError() {
    _clearError();
  }
} 