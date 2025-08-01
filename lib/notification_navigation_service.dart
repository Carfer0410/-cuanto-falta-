import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Importar las páginas principales que no requieren parámetros complejos
import 'planning_style_selection_page.dart';
import 'individual_streaks_page.dart';
import 'add_event_page.dart';
import 'add_counter_page.dart';

/// Servicio centralizado para manejar la navegación desde notificaciones
/// Permite que las notificaciones lleven al usuario directamente a la pantalla relevante
class NotificationNavigationService {
  static final NotificationNavigationService _instance = NotificationNavigationService._internal();
  factory NotificationNavigationService() => _instance;
  NotificationNavigationService._internal();
  
  static NotificationNavigationService get instance => _instance;
  
  // Contexto global para navegación
  static BuildContext? _globalContext;
  
  /// Registra el contexto global para navegación
  static void setGlobalContext(BuildContext context) {
    _globalContext = context;
  }
  
  /// Maneja la navegación basada en el payload de la notificación
  static Future<void> handleNotificationNavigation(String? payload) async {
    if (payload == null || payload.isEmpty) {
      print('📱 Notificación sin payload de navegación');
      return;
    }
    
    if (_globalContext == null) {
      print('❌ Error: Contexto global no disponible para navegación');
      return;
    }
    
    try {
      // Parsear el payload JSON
      final data = jsonDecode(payload);
      final action = data['action'] as String?;
      final extra = data['extra'] as Map<String, dynamic>?;
      
      print('📱 Navegando desde notificación: $action');
      print('📱 Datos extra: $extra');
      
      // Navegar según la acción
      await _navigateToDestination(action, extra);
      
    } catch (e) {
      print('❌ Error parseando payload de notificación: $e');
      print('📱 Payload recibido: $payload');
    }
  }
  
  /// Navega a la pantalla de destino basada en la acción
  static Future<void> _navigateToDestination(String? action, Map<String, dynamic>? extra) async {
    if (_globalContext == null || action == null) return;
    
    switch (action) {
      case 'open_home':
        await _navigateToTab(0);
        break;
        
      case 'open_challenges':
        await _navigateToTab(1); // Counters/Challenges tab
        break;
        
      case 'open_dashboard':
        await _navigateToTab(2); // Dashboard tab
        break;
        
      case 'open_settings':
        await _navigateToTab(3); // Settings tab
        break;
        
      case 'open_planning_style':
        await _navigateToPlanningStyle();
        break;
        
      case 'open_individual_streaks':
        await _navigateToIndividualStreaks();
        break;
        
      case 'open_event_preparations':
        // Para esta acción, solo navegar a la pestaña principal y que el usuario busque el evento
        await _navigateToTab(0); // Home tab donde están los eventos
        if (extra != null && extra['eventId'] != null) {
          // Mostrar un snackbar indicando qué evento buscar
          _showEventNavigationHint(extra['eventId'] as String);
        }
        break;
        
      case 'open_add_event':
        await _navigateToAddEvent();
        break;
        
      case 'open_add_challenge':
        await _navigateToAddChallenge();
        break;
        
      case 'challenge_confirmation':
        await _handleChallengeConfirmation(extra);
        break;
        
      case 'milestone_celebration':
        await _handleMilestoneCelebration(extra);
        break;
        
      default:
        print('❌ Acción de navegación no reconocida: $action');
        // Navegar a home por defecto
        await _navigateToTab(0);
    }
  }
  
  /// Muestra un hint sobre qué evento buscar
  static void _showEventNavigationHint(String eventId) {
    if (_globalContext == null) return;
    
    // Encontrar el ScaffoldMessenger más cercano
    ScaffoldMessenger.of(_globalContext!).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.search, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Busca el evento: $eventId',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
  
  /// Navega a una pestaña específica del BottomNavigationBar
  static Future<void> _navigateToTab(int tabIndex) async {
    if (_globalContext == null) return;
    
    // Buscar el estado del RootPage y cambiar la pestaña
    try {
      final rootState = _globalContext!.findAncestorStateOfType<State>();
      if (rootState != null && rootState.mounted) {
        // Simular tap en la pestaña deseada
        print('📱 Navegando a pestaña $tabIndex');
        
        // Nota: Aquí necesitarías acceso al método _onItemTapped del RootPage
        // Implementaremos una solución alternativa usando Navigator
        Navigator.of(_globalContext!).popUntil((route) => route.isFirst);
        
        // Guardar la pestaña deseada en preferencias para que RootPage la lea
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('notification_target_tab', tabIndex);
        
        print('✅ Navegación a pestaña $tabIndex guardada');
      }
    } catch (e) {
      print('❌ Error navegando a pestaña: $e');
    }
  }
  
  /// Navega a la página de configuración de estilo de planificación
  static Future<void> _navigateToPlanningStyle() async {
    if (_globalContext == null) return;
    
    try {
      Navigator.of(_globalContext!).push(
        MaterialPageRoute(
          builder: (context) => PlanningStyleSelectionPage(),
        ),
      );
      
      print('✅ Navegado a PlanningStyleSelectionPage');
    } catch (e) {
      print('❌ Error navegando a PlanningStyleSelectionPage: $e');
      await _navigateToTab(3); // Fallback a settings
    }
  }
  
  /// Navega a la página de rachas individuales
  static Future<void> _navigateToIndividualStreaks() async {
    if (_globalContext == null) return;
    
    try {
      Navigator.of(_globalContext!).push(
        MaterialPageRoute(
          builder: (context) => IndividualStreaksPage(),
        ),
      );
      
      print('✅ Navegado a IndividualStreaksPage');
    } catch (e) {
      print('❌ Error navegando a IndividualStreaksPage: $e');
      await _navigateToTab(1); // Fallback a challenges tab
    }
  }
  
  /// Navega a la página de agregar evento
  static Future<void> _navigateToAddEvent() async {
    if (_globalContext == null) return;
    
    try {
      Navigator.of(_globalContext!).push(
        MaterialPageRoute(
          builder: (context) => AddEventPage(),
        ),
      );
      
      print('✅ Navegado a AddEventPage');
    } catch (e) {
      print('❌ Error navegando a AddEventPage: $e');
      await _navigateToTab(0); // Fallback a home
    }
  }
  
  /// Navega a la página de agregar reto/challenge
  static Future<void> _navigateToAddChallenge() async {
    if (_globalContext == null) return;
    
    try {
      Navigator.of(_globalContext!).push(
        MaterialPageRoute(
          builder: (context) => AddCounterPage(),
        ),
      );
      
      print('✅ Navegado a AddCounterPage');
    } catch (e) {
      print('❌ Error navegando a AddCounterPage: $e');
      await _navigateToTab(1); // Fallback a challenges tab
    }
  }
  
  /// Maneja la confirmación de reto mostrando un diálogo
  static Future<void> _handleChallengeConfirmation(Map<String, dynamic>? extra) async {
    if (_globalContext == null) return;
    
    // Primero navegar a la pestaña de retos
    await _navigateToTab(1);
    
    // Luego mostrar diálogo de confirmación si hay datos extra
    if (extra != null) {
      final challengeName = extra['challengeName'] as String?;
      final message = extra['message'] as String?;
      
      if (challengeName != null) {
        _showChallengeConfirmationDialog(challengeName, message);
      }
    }
  }
  
  /// Maneja la celebración de hito
  static Future<void> _handleMilestoneCelebration(Map<String, dynamic>? extra) async {
    if (_globalContext == null) return;
    
    // Navegar al dashboard para ver progreso
    await _navigateToTab(2);
    
    // Mostrar diálogo de celebración si hay datos extra
    if (extra != null) {
      final milestone = extra['milestone'] as String?;
      final challengeName = extra['challengeName'] as String?;
      
      if (milestone != null) {
        _showMilestoneCelebrationDialog(milestone, challengeName);
      }
    }
  }
  
  /// Muestra diálogo de confirmación de reto
  static void _showChallengeConfirmationDialog(String challengeName, String? message) {
    if (_globalContext == null) return;
    
    showDialog(
      context: _globalContext!,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.timer, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text('🎯 Ventana de Confirmación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Es hora de confirmar tu progreso en:'),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                challengeName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (message != null) ...[
              SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Aquí podrías agregar lógica para confirmar automáticamente
            },
            child: Text('Ir a Retos'),
          ),
        ],
      ),
    );
  }
  
  /// Muestra diálogo de celebración de hito
  static void _showMilestoneCelebrationDialog(String milestone, String? challengeName) {
    if (_globalContext == null) return;
    
    showDialog(
      context: _globalContext!,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber),
            SizedBox(width: 8),
            Text('🎉 ¡Hito Alcanzado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              '¡Has alcanzado el hito:',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                milestone,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.amber.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (challengeName != null) ...[
              SizedBox(height: 8),
              Text('en el reto: $challengeName'),
            ],
            SizedBox(height: 16),
            Text(
              '¡Sigue así! 💪',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Ya estamos en el dashboard, no necesitamos navegar más
            },
            child: Text('Ver Progreso'),
          ),
        ],
      ),
    );
  }
  
  /// Crea un payload JSON para una notificación con acción específica
  static String createNotificationPayload({
    required String action,
    Map<String, dynamic>? extra,
  }) {
    final payload = {
      'action': action,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      if (extra != null) 'extra': extra,
    };
    
    return jsonEncode(payload);
  }
  
  /// Métodos de conveniencia para crear payloads comunes
  static String createHomePayload() => createNotificationPayload(action: 'open_home');
  static String createChallengesPayload() => createNotificationPayload(action: 'open_challenges');
  static String createDashboardPayload() => createNotificationPayload(action: 'open_dashboard');
  static String createSettingsPayload() => createNotificationPayload(action: 'open_settings');
  static String createPlanningStylePayload() => createNotificationPayload(action: 'open_planning_style');
  static String createIndividualStreaksPayload() => createNotificationPayload(action: 'open_individual_streaks');
  static String createAddEventPayload() => createNotificationPayload(action: 'open_add_event');
  static String createAddChallengePayload() => createNotificationPayload(action: 'open_add_challenge');
  
  static String createEventPreparationsPayload(String eventId) => createNotificationPayload(
    action: 'open_event_preparations',
    extra: {'eventId': eventId},
  );
  
  static String createChallengeConfirmationPayload({
    required String challengeName,
    String? message,
  }) => createNotificationPayload(
    action: 'challenge_confirmation',
    extra: {
      'challengeName': challengeName,
      if (message != null) 'message': message,
    },
  );
  
  static String createMilestoneCelebrationPayload({
    required String milestone,
    String? challengeName,
  }) => createNotificationPayload(
    action: 'milestone_celebration',
    extra: {
      'milestone': milestone,
      if (challengeName != null) 'challengeName': challengeName,
    },
  );
  
  /// Verifica si hay una pestaña pendiente de navegación y la activa
  static Future<int?> getAndClearPendingTabNavigation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final targetTab = prefs.getInt('notification_target_tab');
      
      if (targetTab != null) {
        await prefs.remove('notification_target_tab');
        print('📱 Recuperando navegación pendiente a pestaña: $targetTab');
        return targetTab;
      }
    } catch (e) {
      print('❌ Error verificando navegación pendiente: $e');
    }
    return null;
  }
}
