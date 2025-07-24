import 'dart:async';
import 'package:flutter/foundation.dart';
import 'database_helper.dart';
import 'preparation_service.dart';

/// 📊 Servicio para manejar estadísticas globales de eventos
/// Proporciona datos para el mini-dashboard de la pantalla principal
class EventDashboardService extends ChangeNotifier {
  static final EventDashboardService _instance = EventDashboardService._internal();
  static EventDashboardService get instance => _instance;
  EventDashboardService._internal();

  // Estadísticas actuales
  Map<String, dynamic> _dashboardStats = {
    'totalEvents': 0,
    'wellPreparedEvents': 0,  // >= 80% completados
    'needsAttentionEvents': 0, // < 80% completados
    'preparationStreak': 0,    // Días consecutivos con eventos bien preparados
    'lastUpdated': DateTime.now(),
  };

  Map<String, dynamic> get dashboardStats => _dashboardStats;

  /// 🔄 Actualizar todas las estadísticas del dashboard
  Future<void> updateDashboardStats() async {
    try {
      final events = await DatabaseHelper.instance.getEvents();
      final now = DateTime.now();
      
      // Filtrar solo eventos futuros (no pasados)
      final futureEvents = events.where((event) => 
        event.targetDate.isAfter(now.subtract(Duration(days: 1)))
      ).toList();

      int wellPrepared = 0;
      int needsAttention = 0;

      // Analizar cada evento
      for (final event in futureEvents) {
        final stats = await PreparationService.instance.getEventPreparationStats(event.id!);
        final total = stats['total'] ?? 0;
        final completed = stats['completed'] ?? 0;
        
        print('🔍 Evento ${event.title}: total=$total, completed=$completed');
        
        // Solo considerar eventos que TIENEN preparativos
        if (total > 0) {
          // ✅ NUEVA LÓGICA: Un evento está "listo" solo cuando TODAS las tareas están completadas
          if (completed == total) {
            wellPrepared++;
            print('   ✅ Evento LISTO (100% completado: $completed/$total)');
          } else {
            needsAttention++;
            print('   ⚠️ Evento PENDIENTE (completado: $completed/$total = ${((completed/total)*100).toStringAsFixed(1)}%)');
          }
        } else {
          print('   → Sin preparativos, no cuenta');
        }
        // Si no tiene preparativos, no cuenta para ninguna categoría
      }

      // Calcular racha de preparación (simplificado por ahora)
      final streak = await _calculatePreparationStreak();

      _dashboardStats = {
        'totalEvents': futureEvents.length,
        'wellPreparedEvents': wellPrepared,
        'needsAttentionEvents': needsAttention,
        'preparationStreak': streak,
        'lastUpdated': DateTime.now(),
      };

      notifyListeners();
      print('📊 Dashboard stats updated: $wellPrepared well prepared, $needsAttention need attention');
      
    } catch (e) {
      print('❌ Error updating dashboard stats: $e');
    }
  }

  /// 🔥 Calcular racha de preparación (días consecutivos con eventos bien preparados)
  Future<int> _calculatePreparationStreak() async {
    // Por ahora retornamos un valor simple, se puede mejorar después
    // TODO: Implementar lógica completa de racha basada en historial
    return _dashboardStats['preparationStreak'] ?? 3;
  }

  /// 🎯 Obtener mensaje motivacional basado en las estadísticas
  String getMotivationalMessage() {
    final total = _dashboardStats['totalEvents'] as int;
    final wellPrepared = _dashboardStats['wellPreparedEvents'] as int;
    final streak = _dashboardStats['preparationStreak'] as int;

    if (total == 0) {
      return '🌟 ¡Perfecto momento para planificar tu próximo evento!';
    }

    if (wellPrepared == total && total > 0) {
      return '🏆 ¡Increíble! Todos tus eventos están bien preparados';
    }

    if (wellPrepared > total * 0.8) {
      return '✨ ¡Excelente trabajo! La mayoría de tus eventos están listos';
    }

    if (streak >= 7) {
      return '🔥 ¡Racha épica de $streak días organizando perfectamente!';
    }

    if (streak >= 3) {
      return '💪 ¡Buena racha de $streak días! Sigue así';
    }

    return '📈 ¡Estás en el camino correcto! Cada evento preparado cuenta';
  }

  /// 🎨 Obtener color principal del dashboard según el estado general
  String getDashboardColor() {
    final total = _dashboardStats['totalEvents'] as int;
    final wellPrepared = _dashboardStats['wellPreparedEvents'] as int;
    final needsAttention = _dashboardStats['needsAttentionEvents'] as int;

    if (total == 0) return 'blue';
    if (wellPrepared == total) return 'green';
    if (wellPrepared > needsAttention) return 'orange';
    if (needsAttention > wellPrepared * 2) return 'red';
    return 'amber';
  }

  /// 📱 Refrescar datos (para pull-to-refresh)
  Future<void> refresh() async {
    await updateDashboardStats();
  }
}
