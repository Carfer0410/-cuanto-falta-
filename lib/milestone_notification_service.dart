import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'notification_navigation_service.dart';

/// Servicio especializado en notificaciones de hitos y motivación para retos
class MilestoneNotificationService {
  static const String _lastMilestoneKey = 'last_milestone_notifications';
  static const String _lastMotivationKey = 'last_motivation_time';
  
  /// Hitos importantes para notificaciones (en días)
  static const List<int> _milestones = [
    1, 3, 7, 14, 21, 30, 60, 90, 180, 365, 730, 1095, 1460, 1825 // 1 día, 3 días, 1 semana, 2 semanas, 3 semanas, 1 mes, 2 meses, 3 meses, 6 meses, 1 año, 2 años, 3 años, 4 años, 5 años
  ];
  
  /// Mensajes motivacionales aleatorios
  static const List<String> _motivationalMessages = [
    "🔥 ¡Eres imparable! Cada día te acercas más a tu objetivo",
    "💪 Tu fuerza de voluntad es increíble. ¡Sigue así!",
    "⭐ Eres valiente y puedes afrontar cualquier desafío",
    "🌟 Tu constancia es tu superpoder. ¡No te detengas!",
    "🚀 Cada día que cumples tu reto, te conviertes en una mejor versión de ti",
    "🏆 Los héroes se hacen día a día. ¡Tú eres uno de ellos!",
    "💎 La disciplina que estás construyendo es más valiosa que el oro",
    "🌈 Tu determinación está creando un futuro brillante",
    "⚡ Tienes el poder de cambiar tu vida, un día a la vez",
    "🎯 Mantén el foco. Cada paso cuenta en tu viaje al éxito",
    "🔆 Tu compromiso contigo mismo es inspirador",
    "🌱 Estás creciendo y floreciendo con cada decisión correcta",
    "🎪 ¡Qué espectáculo tan increíble estás dando! Sigue brillando",
    "🏅 Tu perseverancia es digna de admiración",
    "🎨 Estás pintando una obra maestra con tus hábitos diarios",
  ];

  /// Verificar y enviar notificaciones de hitos para un reto específico
  static Future<void> checkMilestoneNotification(
    String challengeId,
    String challengeTitle,
    int currentStreak, {
    bool isNegativeHabit = false,
  }) async {
    if (currentStreak <= 0) return;
    
    // 🔒 DESHABILITADO TEMPORALMENTE: Para evitar duplicados con ChallengeNotificationService
    // El ChallengeNotificationService ya maneja las notificaciones de hitos correctamente
    print('⚠️ MilestoneNotificationService deshabilitado para evitar duplicados');
    print('   ChallengeNotificationService maneja los hitos correctamente');
    return;
  }

  /// Enviar mensaje motivacional aleatorio
  static Future<void> sendMotivationalMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMotivationTime = prefs.getInt(_lastMotivationKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Enviar motivación máximo cada 4 horas
    const motivationCooldown = 4 * 60 * 60 * 1000; // 4 horas en millisegundos
    
    if (now - lastMotivationTime < motivationCooldown) {
      return; // Muy pronto para otra motivación
    }
    
    // Verificar si hay retos activos
    final hasActiveChallenges = await _hasActiveChallenges();
    if (!hasActiveChallenges) {
      return; // No enviar motivación si no hay retos activos
    }
    
    final message = _motivationalMessages[Random().nextInt(_motivationalMessages.length)];
    
    await NotificationService.instance.showImmediateNotification(
      id: 60000 + Random().nextInt(1000), // ID único para motivación
      title: '💪 Mensaje de Ánimo',
      body: message,
      payload: NotificationNavigationService.createChallengesPayload(),  // 🆕 NUEVO: Navegar a retos
    );
    
    // Actualizar última vez que se envió motivación
    await prefs.setInt(_lastMotivationKey, now);
    print('💪 Mensaje motivacional enviado');
  }

  /// Verificar si hay retos activos (con rachas > 0)
  static Future<bool> _hasActiveChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final streaksJson = prefs.getString('individual_streaks');
    
    if (streaksJson == null) return false;
    
    try {
      final Map<String, dynamic> streaksData = Map<String, dynamic>.from(
        jsonDecode(streaksJson) as Map
      );
      
      // Verificar si hay al menos un reto con racha > 0
      for (final streakData in streaksData.values) {
        final currentStreak = streakData['currentStreak'] ?? 0;
        if (currentStreak > 0) {
          return true;
        }
      }
    } catch (e) {
      print('Error verificando retos activos: $e');
    }
    
    return false;
  }

  /// Limpiar datos de hitos para un reto eliminado
  static Future<void> clearMilestoneData(String challengeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_lastMilestoneKey}_$challengeId');
    print('🧹 Datos de hitos limpiados para: $challengeId');
  }

  /// Resetear todos los datos de hitos (para desarrollo)
  static Future<void> resetAllMilestoneData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => 
      key.startsWith(_lastMilestoneKey) || key == _lastMotivationKey
    ).toList();
    
    for (final key in keys) {
      await prefs.remove(key);
    }
    
    print('🧹 Todos los datos de hitos han sido reseteados');
  }

  /// Obtener estadísticas de hitos para un reto
  static Future<Map<String, dynamic>> getMilestoneStats(String challengeId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastMilestones = prefs.getStringList('${_lastMilestoneKey}_$challengeId') ?? [];
    
    final achievedMilestones = lastMilestones
        .map((m) => int.tryParse(m))
        .where((m) => m != null)
        .cast<int>()
        .toList()
      ..sort();
    
    int nextMilestone = 1;
    for (final milestone in _milestones) {
      if (!achievedMilestones.contains(milestone)) {
        nextMilestone = milestone;
        break;
      }
    }
    
    return {
      'achievedMilestones': achievedMilestones,
      'nextMilestone': nextMilestone,
      'totalMilestonesAchieved': achievedMilestones.length,
    };
  }
}
