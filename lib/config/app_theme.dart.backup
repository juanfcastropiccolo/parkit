import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales inspirados en señalización argentina
  static const Color primaryCeleste = Color(0xFF00B4D8);
  static const Color primaryAzul = Color(0xFF0077B6);
  static const Color secondaryAzul = Color(0xFF023E8A);
  static const Color accentCeleste = Color(0xFF90E0EF);
  
  // Colores de apoyo
  static const Color surfaceColor = Color(0xFFF8FFFE);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color onSurfaceColor = Color(0xFF2D3748);
  static const Color successGreen = Color(0xFF38A169);
  static const Color warningOrange = Color(0xFFE53E3E);
  
  // Colores para marcadores del mapa
  static const Color marcadorLibre = Color(0xFF38A169);
  static const Color marcadorOcupado = Color(0xFFE53E3E);
  static const Color marcadorPublicidad = Color(0xFF3182CE);

  static ThemeData get lightTheme {
    return ThemeData(
      // Configuración básica
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Esquema de colores
      colorScheme: const ColorScheme.light(
        primary: primaryCeleste,
        secondary: primaryAzul,
        tertiary: accentCeleste,
        surface: surfaceColor,
        background: backgroundLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurfaceColor,
        onBackground: onSurfaceColor,
        error: warningOrange,
      ),

      // Fuente principal
      fontFamily: 'Roboto',
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryCeleste,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Roboto',
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonTheme(
        backgroundColor: primaryCeleste,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: CircleBorder(),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCeleste,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryCeleste,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryCeleste,
          side: const BorderSide(color: primaryCeleste, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryCeleste, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: warningOrange),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: warningOrange, width: 2),
        ),
        labelStyle: const TextStyle(
          color: onSurfaceColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: onSurfaceColor.withOpacity(0.6),
          fontSize: 16,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 2,
        shadowColor: onSurfaceColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundLight,
        selectedItemColor: primaryCeleste,
        unselectedItemColor: onSurfaceColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: backgroundLight,
        surfaceTintColor: primaryCeleste,
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: primaryCeleste,
        textColor: onSurfaceColor,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: accentCeleste.withOpacity(0.2),
        labelStyle: const TextStyle(
          color: primaryAzul,
          fontWeight: FontWeight.w500,
        ),
        side: const BorderSide(color: accentCeleste),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryCeleste;
          }
          return Colors.grey[400];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryCeleste.withOpacity(0.5);
          }
          return Colors.grey[300];
        }),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryCeleste,
        linearTrackColor: accentCeleste,
        circularTrackColor: accentCeleste,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: onSurfaceColor.withOpacity(0.1),
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: const ColorScheme.dark(
        primary: accentCeleste,
        secondary: primaryCeleste,
        surface: Color(0xFF1A202C),
        background: Color(0xFF121212),
        onPrimary: Color(0xFF1A202C),
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),

      fontFamily: 'Roboto',
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A202C),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  // Estilos de texto personalizados
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: onSurfaceColor,
    fontFamily: 'Roboto',
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: onSurfaceColor,
    fontFamily: 'Roboto',
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: onSurfaceColor,
    fontFamily: 'Roboto',
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: onSurfaceColor,
    fontFamily: 'Roboto',
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: onSurfaceColor,
    fontFamily: 'Roboto',
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: onSurfaceColor,
    fontFamily: 'Roboto',
  );

  // Estilos específicos para la app
  static const TextStyle logoText = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: primaryCeleste,
    fontFamily: 'Roboto',
    letterSpacing: 1.2,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'Roboto',
  );

  static const TextStyle captionText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: onSurfaceColor,
    fontFamily: 'Roboto',
    letterSpacing: 0.4,
  );

  // Decoraciones para contenedores
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: onSurfaceColor.withOpacity(0.1),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration gradientDecoration = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryCeleste, primaryAzul],
    ),
  );
} 