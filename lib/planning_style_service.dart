import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estilos de planificación disponibles para los usuarios
enum PlanningStyle {
  relaxed,       // Relajado - menos tiempo de preparación
  balanced,      // Equilibrado - tiempos actuales (por defecto)
  methodical,    // Metódico - más tiempo de preparación
  perfectionist  // Perfeccionista - máximo tiempo de preparación
}

/// Servicio para manejar los estilos de planificación personalizados
class PlanningStyleService extends ChangeNotifier {
  static final PlanningStyleService _instance = PlanningStyleService._internal();
  factory PlanningStyleService() => _instance;
  static PlanningStyleService get instance => _instance;
  PlanningStyleService._internal();

  PlanningStyle _currentStyle = PlanningStyle.balanced;
  bool _isInitialized = false;

  PlanningStyle get currentStyle => _currentStyle;
  bool get isInitialized => _isInitialized;

  /// Información detallada de cada estilo
  Map<PlanningStyle, Map<String, dynamic>> get styleInfo => {
    PlanningStyle.relaxed: {
      'name': 'Relajado',
      'emoji': '😌',
      'description': 'Prefiero preparar las cosas sin mucha anticipación',
      'multiplier': 0.6, // 60% del tiempo original
      'example': 'Cumpleaños: invitar 13 días antes'
    },
    PlanningStyle.balanced: {
      'name': 'Equilibrado',
      'emoji': '⚖️',
      'description': 'Me gusta un balance entre planificación y flexibilidad',
      'multiplier': 1.0, // 100% tiempo original
      'example': 'Cumpleaños: invitar 21 días antes'
    },
    PlanningStyle.methodical: {
      'name': 'Metódico',
      'emoji': '📋',
      'description': 'Prefiero tener todo planeado con bastante anticipación',
      'multiplier': 1.5, // 150% del tiempo original
      'example': 'Cumpleaños: invitar 32 días antes'
    },
    PlanningStyle.perfectionist: {
      'name': 'Perfeccionista',
      'emoji': '🎯',
      'description': 'Me gusta planificar todo con la máxima anticipación posible',
      'multiplier': 2.0, // 200% del tiempo original
      'example': 'Cumpleaños: invitar 42 días antes'
    },
  };

  /// Cargar el estilo guardado del usuario
  Future<void> loadPlanningStyle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final styleIndex = prefs.getInt('planning_style_index');
      
      if (styleIndex != null && styleIndex < PlanningStyle.values.length) {
        _currentStyle = PlanningStyle.values[styleIndex];
      } else {
        _currentStyle = PlanningStyle.balanced; // Por defecto
      }
      
      _isInitialized = true;
      notifyListeners();
      
      print('📋 Estilo de planificación cargado: ${getStyleName(_currentStyle)}');
    } catch (e) {
      print('❌ Error cargando estilo de planificación: $e');
      _currentStyle = PlanningStyle.balanced;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Cambiar el estilo de planificación del usuario
  Future<void> setPlanningStyle(PlanningStyle style) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('planning_style_index', style.index);
      
      _currentStyle = style;
      notifyListeners();
      
      print('✅ Estilo de planificación cambiado a: ${getStyleName(style)}');
      print('   Multiplicador: ${getMultiplier(style)}x');
    } catch (e) {
      print('❌ Error guardando estilo de planificación: $e');
    }
  }

  /// Obtener el multiplicador de tiempo para un estilo
  double getMultiplier(PlanningStyle style) {
    return styleInfo[style]!['multiplier'] as double;
  }

  /// Obtener el nombre del estilo
  String getStyleName(PlanningStyle style) {
    return styleInfo[style]!['name'] as String;
  }

  /// Obtener el emoji del estilo
  String getStyleEmoji(PlanningStyle style) {
    return styleInfo[style]!['emoji'] as String;
  }

  /// Obtener la descripción del estilo
  String getStyleDescription(PlanningStyle style) {
    return styleInfo[style]!['description'] as String;
  }

  /// Obtener ejemplo del estilo
  String getStyleExample(PlanningStyle style) {
    return styleInfo[style]!['example'] as String;
  }

  /// Calcular días ajustados según el estilo actual y tiempo disponible
  int getAdjustedDays(int originalDays, {int? maxDaysAvailable}) {
    final multiplier = getMultiplier(_currentStyle);
    var adjustedDays = (originalDays * multiplier).round();
    
    // Si se proporciona tiempo máximo disponible, no excederlo
    if (maxDaysAvailable != null && maxDaysAvailable > 0) {
      adjustedDays = adjustedDays.clamp(1, maxDaysAvailable - 1);
    }
    
    // Rango sensato: mínimo 1 día, máximo 90 días
    return adjustedDays.clamp(1, 90);
  }

  /// Versión legacy para compatibilidad
  int getAdjustedDaysLegacy(int originalDays) {
    return getAdjustedDays(originalDays);
  }

  /// Verificar si el usuario ya configuró su estilo
  Future<bool> hasConfiguredStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('planning_style_index');
  }

  /// Mostrar información del estilo actual
  void printCurrentStyleInfo() {
    final info = styleInfo[_currentStyle]!;
    print('🎨 Estilo actual: ${info['emoji']} ${info['name']}');
    print('   📝 ${info['description']}');
    print('   ⏰ Multiplicador: ${info['multiplier']}x');
    print('   💡 ${info['example']}');
  }
}
