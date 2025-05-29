import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_theme.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/map_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    debugPrint('Environment variables loaded successfully');
    
    // Initialize Supabase
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    debugPrint('Supabase initialized successfully');
    
    // Initialize notification service
    await NotificationService().initialize();
    debugPrint('Notification service initialized');
    
    // Check if configuration is complete
    if (!SupabaseConfig.isConfigured) {
      debugPrint('Warning: Missing configuration for: ${SupabaseConfig.missingConfig.join(', ')}');
    }
    
  } catch (e) {
    debugPrint('Error during initialization: $e');
    // Continue anyway to show error in app
  }
  
  // Start the app
  runApp(const ParkitApp());
}

class ParkitApp extends StatelessWidget {
  const ParkitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
      ],
      child: MaterialApp(
        title: SupabaseConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        // TODO: Add routes when we create more screens
        // routes: {
        //   '/login': (context) => const LoginScreen(),
        //   '/register': (context) => const RegisterScreen(),
        //   '/map': (context) => const MapScreen(),
        //   '/profile': (context) => const ProfileScreen(),
        // },
      ),
    );
  }
}
