import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'config/app_theme.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/map_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables with different path for web
    if (kIsWeb) {
      await dotenv.load(fileName: "assets/.env");
    } else {
      await dotenv.load(fileName: ".env");
    }
    print('Environment variables loaded successfully');
    
    // Initialize Supabase
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    print('Supabase initialized successfully');
    
    // Initialize notification service
    await NotificationService().initialize();
    print('Notification service initialized');
    
    // Check if configuration is complete
    if (!SupabaseConfig.isConfigured) {
      print('Warning: Missing configuration for: ${SupabaseConfig.missingConfig.join(', ')}');
    }
    
  } catch (e) {
    print('Error during initialization: $e');
    // Continue anyway to show error in app
  }
  
  runApp(const ParkitApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapScreen(),
    );
  }
} 