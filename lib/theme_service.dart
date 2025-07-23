import 'package:flutter/material.dart';

/// Servicio centralizado para manejar temas y colores adaptativos
/// Garantiza consistencia visual en ambos modos (claro/oscuro)
class ThemeService {
  // Singleton
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  /// Obtener color de texto principal según el contexto
  static Color getPrimaryTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.white 
        : Colors.black87;
  }

  /// Obtener color de texto secundario según el contexto
  static Color getSecondaryTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.white70 
        : Colors.grey[600]!;
  }

  /// Obtener color de hint/placeholder según el contexto
  static Color getHintColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.white54 
        : Colors.grey[500]!;
  }

  /// Obtener color de fondo para cards según el contexto
  static Color getCardColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.grey[850]! 
        : Colors.white;
  }

  /// Obtener color de superficie según el contexto
  static Color getSurfaceColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.grey[900]! 
        : Colors.grey[100]!;
  }

  /// Obtener color de border según el contexto
  static Color getBorderColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.grey[700]! 
        : Colors.grey[300]!;
  }

  /// Obtener color de divider según el contexto
  static Color getDividerColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.grey[800]! 
        : Colors.grey[200]!;
  }

  /// Obtener color contraste para iconos según el contexto
  static Color getIconColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.white70 
        : Colors.grey[700]!;
  }

  /// Obtener variante de color orange adaptada al tema
  static Color getOrangeVariant(BuildContext context, {double opacity = 1.0}) {
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      // En modo oscuro, usar una variante más suave del orange
      return Colors.deepOrange[400]!.withOpacity(opacity);
    } else {
      // En modo claro, usar el orange normal
      return Colors.orange.withOpacity(opacity);
    }
  }

  /// Obtener color de success adaptado al tema
  static Color getSuccessColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.green[400]! 
        : Colors.green[600]!;
  }

  /// Obtener color de warning adaptado al tema
  static Color getWarningColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.amber[400]! 
        : Colors.amber[600]!;
  }

  /// Obtener color de error adaptado al tema
  static Color getErrorColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? Colors.red[400]! 
        : Colors.red[600]!;
  }

  /// Tema claro personalizado
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.orange,
      primaryColor: Colors.orange,
      scaffoldBackgroundColor: Colors.grey[50],
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // FloatingActionButton theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      
      // Bottom navigation theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
      ),
      
      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        labelLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: Colors.grey[200],
        thickness: 1,
      ),
    );
  }

  /// Tema oscuro personalizado
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.deepOrange,
      primaryColor: Colors.deepOrange[400],
      scaffoldBackgroundColor: Colors.grey[900],
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: Colors.grey[850],
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey[700]!,
            width: 0.5,
          ),
        ),
      ),
      
      // FloatingActionButton theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.deepOrange[400],
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      
      // Bottom navigation theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.grey[850],
        selectedItemColor: Colors.deepOrange[400],
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepOrange[400]!, width: 2),
        ),
      ),
      
      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Colors.white70),
        bodyMedium: TextStyle(color: Colors.white70),
        labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: Colors.grey[700],
        thickness: 1,
      ),
    );
  }
}

/// Extension para facilitar el acceso a métodos de tema en cualquier BuildContext
extension ThemeExtension on BuildContext {
  /// Verificar si está en modo oscuro
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  
  /// Obtener color de texto principal
  Color get primaryTextColor => ThemeService.getPrimaryTextColor(this);
  
  /// Obtener color de texto secundario
  Color get secondaryTextColor => ThemeService.getSecondaryTextColor(this);
  
  /// Obtener color de hint
  Color get hintColor => ThemeService.getHintColor(this);
  
  /// Obtener color de card
  Color get cardColor => ThemeService.getCardColor(this);
  
  /// Obtener color de superficie
  Color get surfaceColor => ThemeService.getSurfaceColor(this);
  
  /// Obtener color de border
  Color get borderColor => ThemeService.getBorderColor(this);
  
  /// Obtener color de divider
  Color get dividerColor => ThemeService.getDividerColor(this);
  
  /// Obtener color de iconos
  Color get iconColor => ThemeService.getIconColor(this);
  
  /// Obtener variante de orange
  Color get orangeVariant => ThemeService.getOrangeVariant(this);
  
  /// Obtener color de success
  Color get successColor => ThemeService.getSuccessColor(this);
  
  /// Obtener color de warning
  Color get warningColor => ThemeService.getWarningColor(this);
  
  /// Obtener color de error
  Color get errorColor => ThemeService.getErrorColor(this);
}
