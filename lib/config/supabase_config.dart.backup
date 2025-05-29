import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Supabase credentials from environment variables
  static String get supabaseUrl => 
      dotenv.env['SUPABASE_URL'] ?? 'https://your-project.supabase.co';
  
  static String get supabaseAnonKey => 
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'your-anon-key';
  
  // Google Maps API Key
  static String get googleMapsApiKey => 
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'your-google-maps-api-key';
  
  // App configuration
  static String get appName => 
      dotenv.env['APP_NAME'] ?? 'Parkit';
  
  static String get appEnvironment => 
      dotenv.env['APP_ENVIRONMENT'] ?? 'development';
  
  // Nombres de las tablas
  static String get usersTable => 
      dotenv.env['USERS_TABLE'] ?? 'users';
  
  static String get autosTable => 
      dotenv.env['AUTOS_TABLE'] ?? 'autos';
  
  static String get estacionamientosTable => 
      dotenv.env['ESTACIONAMIENTOS_TABLE'] ?? 'estacionamientos';
  
  static String get publicidadesTable => 
      dotenv.env['PUBLICIDADES_TABLE'] ?? 'publicidades';
  
  // Notification configuration
  static String get notificationChannelId => 
      dotenv.env['NOTIFICATION_CHANNEL_ID'] ?? 'parkit_channel';
  
  // Sensor sensitivity
  static double get movementThreshold => 
      double.tryParse(dotenv.env['MOVEMENT_THRESHOLD'] ?? '2.0') ?? 2.0;
  
  static double get gyroThreshold => 
      double.tryParse(dotenv.env['GYRO_THRESHOLD'] ?? '0.5') ?? 0.5;
  
  // Validation method to check if required env variables are set
  static bool get isConfigured {
    return supabaseUrl != 'https://your-project.supabase.co' &&
           supabaseAnonKey != 'your-anon-key' &&
           googleMapsApiKey != 'your-google-maps-api-key';
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