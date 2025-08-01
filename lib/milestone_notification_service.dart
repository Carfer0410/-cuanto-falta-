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

  /// Mensajes específicos para hitos importantes
  static const Map<int, List<String>> _milestoneMessages = {
    1: [
      "🎉 ¡Primer día completado! El viaje de mil millas comienza con un paso",
      "🌟 ¡Felicidades! Has dado el primer paso hacia tu transformación",
      "💪 Día 1 conquistado. ¡Eres oficialmente un guerrero de hábitos!",
    ],
    3: [
      "🔥 ¡3 días seguidos! Ya estás formando una rutina ganadora",
      "⚡ Tres días de pura determinación. ¡Tu futuro yo te agradece!",
      "🎯 ¡Racha de 3 días! La consistencia es tu nueva identidad",
    ],
    7: [
      "🏆 ¡UNA SEMANA COMPLETA! Has demostrado que tienes lo necesario",
      "👑 7 días de excelencia. ¡Eres oficialmente imparable!",
      "🌟 Una semana perfecta. Tu disciplina está construyendo tu destino",
    ],
    14: [
      "🚀 ¡DOS SEMANAS! Tu compromiso está transformando tu vida",
      "💎 14 días de diamante. Tu constancia brilla con luz propia",
      "🔥 Dos semanas de fuego puro. ¡Nada puede detenerte!",
    ],
    21: [
      "🎪 ¡21 DÍAS! Dicen que este es el punto donde nace un hábito",
      "⚡ ¡TRES SEMANAS DE PODER! Tu transformación es real",
      "🌈 21 días de magia. Has creado algo hermoso en tu vida",
    ],
    30: [
      "👑 ¡UN MES ENTERO! Eres oficialmente un MAESTRO de hábitos",
      "🏅 30 días de gloria. Has construido una fortaleza de disciplina",
      "🔥 ¡CAMPEÓN DE UN MES! Tu dedicación es legendaria",
    ],
    60: [
      "🚀 ¡DOS MESES! Tu consistencia está reescribiendo tu destino",
      "💎 60 días de pureza. Eres un ejemplo de lo que es posible",
      "⭐ Dos meses de estrellato. ¡Brillas con luz propia!",
    ],
    90: [
      "🏆 ¡TRES MESES! Has alcanzado el nivel de LEYENDA",
      "👑 90 días de realeza. Tu reino de disciplina está establecido",
      "🌟 ¡TRIMESTRE PERFECTO! Eres inspiración pura",
    ],
    180: [
      "🚀 ¡MEDIO AÑO! Tu transformación es completamente ÉPICA",
      "💎 180 días de diamante. Eres inquebrantable",
      "⚡ ¡SEIS MESES DE PODER! Has redefinido lo que es posible",
    ],
    365: [
      "👑 ¡UN AÑO COMPLETO! Eres oficialmente un HÉROE de la vida",
      "🏆 365 días de GLORIA ABSOLUTA. Has conquistado el tiempo mismo",
      "🌟 ¡AÑO PERFECTO! Tu legado de disciplina es eterno",
      "🔥 ¡CAMPEÓN ANUAL! Has demostrado que los milagros son reales",
    ],
    730: [
      "🚀 ¡DOS AÑOS! Eres una LEYENDA VIVIENTE de la constancia",
      "👑 730 días de SUPREMACÍA. Has trascendido lo humano",
      "💎 ¡DOS AÑOS DE DIAMANTE! Tu brillantez es cósmica",
    ],
  };

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

  /// Enviar notificación de hito específico
  static Future<void> _sendMilestoneNotification(String challengeTitle, int days, bool isNegativeHabit) async {
    String title;
    String body;
    
    // 🆕 MEJORADO: Crear frase personalizada basada en el tipo de hábito
    final personalizedPhrase = _createPersonalizedPhrase(challengeTitle, days, isNegativeHabit);
    
    if (_milestoneMessages.containsKey(days)) {
      final messages = _milestoneMessages[days]!;
      final randomMessage = messages[Random().nextInt(messages.length)];
      title = _getMilestoneTitle(days);
      body = '$randomMessage\n\n🎯 $personalizedPhrase';
    } else {
      title = '🏆 ¡Hito Alcanzado!';
      body = '¡Increíble! $personalizedPhrase.\n\nTu dedicación es extraordinaria. ¡Sigue conquistando tus sueños!';
    }

    await NotificationService.instance.showImmediateNotification(
      id: 50000 + days, // ID único para hitos
      title: title,
      body: body,
      payload: NotificationNavigationService.createMilestoneCelebrationPayload(
        milestone: _getMilestoneTitle(days),
        challengeName: challengeTitle,
      ),  // 🆕 NUEVO: Incluir payload de navegación
    );
  }

  /// Obtener título apropiado para el hito
  static String _getMilestoneTitle(int days) {
    if (days == 1) return '🎉 ¡Primer Día!';
    if (days == 3) return '🔥 ¡3 Días!';
    if (days == 7) return '🏆 ¡1 Semana!';
    if (days == 14) return '🚀 ¡2 Semanas!';
    if (days == 21) return '⚡ ¡3 Semanas!';
    if (days == 30) return '👑 ¡1 Mes!';
    if (days == 60) return '💎 ¡2 Meses!';
    if (days == 90) return '🌟 ¡3 Meses!';
    if (days == 180) return '🚀 ¡6 Meses!';
    if (days == 365) return '👑 ¡1 Año!';
    if (days == 730) return '🏆 ¡2 Años!';
    return '🎯 ¡Hito Especial!';
  }

  /// 🆕 NUEVO: Crear frase personalizada basada en el tipo de hábito
  static String _createPersonalizedPhrase(String challengeTitle, int days, bool isNegativeHabit) {
    // Limpiar el título del reto removiendo prefijos comunes
    String cleanTitle = _getCleanChallengeTitle(challengeTitle, isNegativeHabit);
    
    // Crear frase según el tipo de hábito
    if (isNegativeHabit) {
      // Para hábitos negativos (dejar de hacer algo)
      return '$days días sin $cleanTitle';
    } else {
      // Para hábitos positivos (hacer algo)
      return '$days días $cleanTitle';
    }
  }

  /// Limpiar título del reto removiendo prefijos comunes
  static String _getCleanChallengeTitle(String title, bool isNegativeHabit) {
    final lowerTitle = title.toLowerCase().trim();
    
    if (isNegativeHabit) {
      // Remover prefijos comunes para hábitos negativos
      if (lowerTitle.startsWith('dejar de ')) {
        return lowerTitle.substring(9); // "dejar de fumar" → "fumar"
      }
      if (lowerTitle.startsWith('no ')) {
        return lowerTitle.substring(3); // "no fumar" → "fumar"
      }
      if (lowerTitle.startsWith('dejar ')) {
        return lowerTitle.substring(6); // "dejar fumar" → "fumar"
      }
      if (lowerTitle.startsWith('parar de ')) {
        return lowerTitle.substring(9); // "parar de fumar" → "fumar"
      }
      if (lowerTitle.startsWith('evitar ')) {
        return lowerTitle.substring(7); // "evitar fumar" → "fumar"
      }
    } else {
      // Remover prefijos comunes para hábitos positivos
      if (lowerTitle.startsWith('hacer ')) {
        return 'haciendo ' + lowerTitle.substring(6); // "hacer ejercicio" → "haciendo ejercicio"
      }
      if (lowerTitle.startsWith('empezar a ')) {
        return 'haciendo ' + lowerTitle.substring(10); // "empezar a leer" → "haciendo leer"
      }
      if (lowerTitle.startsWith('comenzar a ')) {
        return 'haciendo ' + lowerTitle.substring(11); // "comenzar a correr" → "haciendo correr"
      }
      if (lowerTitle.startsWith('leer')) {
        return 'leyendo';
      }
      if (lowerTitle.startsWith('correr')) {
        return 'corriendo';
      }
      if (lowerTitle.startsWith('ejercicio')) {
        return 'haciendo ejercicio';
      }
      if (lowerTitle.startsWith('meditar')) {
        return 'meditando';
      }
      if (lowerTitle.startsWith('estudiar')) {
        return 'estudiando';
      }
      // Para otros casos, agregar "haciendo" si no tiene verbo
      if (!lowerTitle.contains('ando') && !lowerTitle.contains('iendo') && !lowerTitle.contains('haciendo')) {
        return 'haciendo ' + lowerTitle;
      }
    }
    
    return lowerTitle;
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
