// Script para generar notificación de prueba y verificar clasificación
// Este script simula la creación de una notificación como la problemática

import 'dart:convert';

// Enumerador copiado del proyecto
enum NotificationType {
  challenge,           
  event,              
  achievement,        
  reminder,           
  motivation,         
  system,             
  planning,           
  general,            
}

// Función copiada del notification_service.dart actualizada
NotificationType _determineNotificationType(String title, String body, String? payload) {
  final titleLower = title.toLowerCase();
  final bodyLower = body.toLowerCase();
  
  // Análisis del payload si existe (PRIORIDAD MÁXIMA)
  String? payloadAction;
  if (payload != null && payload.isNotEmpty) {
    try {
      final payloadMap = jsonDecode(payload);
      payloadAction = payloadMap['action']?.toString().toLowerCase();
    } catch (e) {
      // Si el payload no es JSON válido, lo ignoramos
    }
  }
  
  // Prioridad 1: Analizar el payload primero
  if (payloadAction != null) {
    if (payloadAction.contains('challenge') || payloadAction.contains('confirm')) {
      return NotificationType.challenge;
    }
    if (payloadAction.contains('event')) {
      return NotificationType.event;
    }
    if (payloadAction.contains('achievement')) {
      return NotificationType.achievement;
    }
    if (payloadAction.contains('reminder')) {
      return NotificationType.reminder;
    }
  }
  
  // 2. RETOS/CHALLENGES (prioridad ALTA - incluye confirmaciones y recordatorios)
  if (titleLower.contains('reto') || titleLower.contains('challenge') ||
      titleLower.contains('racha') || titleLower.contains('streak') ||
      bodyLower.contains('confirmar') || bodyLower.contains('confirm') ||
      bodyLower.contains('reto') || bodyLower.contains('challenge') ||
      titleLower.contains('🔥') || titleLower.contains('💪') ||
      titleLower.contains('🛡️') || titleLower.contains('💔') ||
      (bodyLower.contains('confirmar') && (bodyLower.contains('23:59') || bodyLower.contains('minutos'))) ||
      (titleLower.contains('últimos') && bodyLower.contains('confirmar'))) {
    return NotificationType.challenge;
  }
  
  // 3. LOGROS/ACHIEVEMENTS
  if (titleLower.contains('logro') || titleLower.contains('achievement') || 
      titleLower.contains('🎉') || titleLower.contains('🏆')) {
    return NotificationType.achievement;
  }
  
  // 4. EVENTOS
  if (titleLower.contains('evento') || titleLower.contains('event') ||
      (titleLower.contains('📅') && !bodyLower.contains('reto') && !bodyLower.contains('confirmar'))) {
    return NotificationType.event;
  }
  
  // Por defecto: general
  return NotificationType.general;
}

void main() {
  print('=== PRUEBA DE NOTIFICACIÓN REAL ===\n');
  
  // Simulamos la notificación exacta que genera ChallengeNotificationService
  final title = '⏰ ¡Últimos 29 minutos!';
  final body = 'Recuerda confirmar tu reto de meditación antes de las 23:59. ¡Mantén tu racha!';
  final payload = jsonEncode({
    "action": "challenge_confirmation",
    "challengeId": "meditation_challenge",
    "habitName": "meditación",
    "dueTime": "23:59"
  });
  
  print('Notificación a clasificar:');
  print('📢 Título: $title');
  print('📝 Cuerpo: $body');
  print('📦 Payload: $payload');
  
  final result = _determineNotificationType(title, body, payload);
  
  print('\n🔍 RESULTADO DE CLASIFICACIÓN:');
  print('Tipo detectado: ${result.toString().split('.').last.toUpperCase()}');
  
  if (result == NotificationType.challenge) {
    print('✅ CORRECTO: Se clasificó como CHALLENGE');
    print('🎯 Esta notificación debería aparecer en la pantalla de Retos');
  } else {
    print('❌ ERROR: Se clasificó como ${result.toString().split('.').last.toUpperCase()}');
    print('⚠️  Debería ser CHALLENGE pero se clasificó incorrectamente');
  }
  
  print('\n📊 ANÁLISIS DEL PAYLOAD:');
  try {
    final payloadMap = jsonDecode(payload);
    final action = payloadMap['action']?.toString() ?? 'NO_ACTION';
    print('Action en payload: $action');
    print('¿Contiene "challenge"? ${action.toLowerCase().contains('challenge')}');
    print('¿Contiene "confirm"? ${action.toLowerCase().contains('confirm')}');
  } catch (e) {
    print('Error analizando payload: $e');
  }
  
  print('\n📊 ANÁLISIS DE TEXTO:');
  print('Título contiene "últimos": ${title.toLowerCase().contains("últimos")}');
  print('Cuerpo contiene "confirmar": ${body.toLowerCase().contains("confirmar")}');
  print('Cuerpo contiene "reto": ${body.toLowerCase().contains("reto")}');
  
  print('\n🔧 ESTADO DE LA CORRECCIÓN:');
  print('La función _determineNotificationType ahora:');
  print('1. ✅ Analiza el payload PRIMERO (prioridad máxima)');
  print('2. ✅ Busca "challenge_confirmation" en action');
  print('3. ✅ Si no hay payload, usa las palabras clave del texto');
  print('4. ✅ Detecta "últimos" + "confirmar" como challenge');
}
