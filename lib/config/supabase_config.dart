import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Helper to safely read from dotenv, falling back on default if not loaded
  static String _getEnvVar(String key, String fallback) {
    try {
      final val = dotenv.env[key];
      return (val != null && val.isNotEmpty) ? val : fallback;
    } catch (_) {
      return fallback;
    }
  }
  // Supabase credentials from environment variables
  static String get supabaseUrl =>
      _getEnvVar('SUPABASE_URL', 'https://your-project.supabase.co');
  
  static String get supabaseAnonKey =>
      _getEnvVar('SUPABASE_ANON_KEY', 'your-anon-key');
  
  // Google Maps API Key
  static String get googleMapsApiKey =>
      _getEnvVar('GOOGLE_MAPS_API_KEY', 'your-google-maps-api-key');
  
  // App configuration
  static String get appName =>
      _getEnvVar('APP_NAME', 'Parkit');
  
  static String get appEnvironment =>
      _getEnvVar('APP_ENVIRONMENT', 'development');
  
  // Nombres de las tablas
  static String get usersTable =>
      _getEnvVar('USERS_TABLE', 'users');
  
  static String get autosTable =>
      _getEnvVar('AUTOS_TABLE', 'autos');
  
  static String get estacionamientosTable =>
      _getEnvVar('ESTACIONAMIENTOS_TABLE', 'estacionamientos');
  
  static String get publicidadesTable =>
      _getEnvVar('PUBLICIDADES_TABLE', 'publicidades');
  
  // Notification configuration
  static String get notificationChannelId =>
      _getEnvVar('NOTIFICATION_CHANNEL_ID', 'parkit_channel');
  
  // Sensor sensitivity
  static double get movementThreshold =>
      double.tryParse(_getEnvVar('MOVEMENT_THRESHOLD', '2.0')) ?? 2.0;
  
  static double get gyroThreshold =>
      double.tryParse(_getEnvVar('GYRO_THRESHOLD', '0.5')) ?? 0.5;
  
  // Validation method to check if required env variables are set
  static bool get isConfigured {
    return supabaseUrl != 'https://your-project.supabase.co'
        && supabaseAnonKey != 'your-anon-key'
        && googleMapsApiKey != 'your-google-maps-api-key';
  }
  
  // Get missing configuration items
  static List<String> get missingConfig {
    final missing = <String>[];
    if (supabaseUrl == 'https://your-project.supabase.co') {
      missing.add('SUPABASE_URL');
    }
    if (supabaseAnonKey == 'your-anon-key') {
      missing.add('SUPABASE_ANON_KEY');
    }
    if (googleMapsApiKey == 'your-google-maps-api-key') {
      missing.add('GOOGLE_MAPS_API_KEY');
    }
    return missing;
  }
} 