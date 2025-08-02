// Test script para verificar la clasificación de notificaciones
// Solo importa las dependencias mínimas necesarias

import 'dart:convert';

// Enumerador de tipos de notificación (copiado del archivo original)
enum NotificationType {
  challenge,
  event,
  general,
  preparation,
  milestone,
  all
}

// Función de clasificación copiada del notification_service.dart
NotificationType _determineNotificationType(String title, String body, String? payload) {
  final titleLower = title.toLowerCase();
  final bodyLower = body.toLowerCase();
  
  // Análisis del payload si existe
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
    if (payloadAction.contains('milestone')) {
      return NotificationType.milestone;
    }
    if (payloadAction.contains('preparation') || payloadAction.contains('prepare')) {
      return NotificationType.preparation;
    }
  }
  
  // Prioridad 2: Palabras clave específicas de retos (mayor prioridad)
  if ((titleLower.contains('reto') || bodyLower.contains('reto')) ||
      (titleLower.contains('challenge') || bodyLower.contains('challenge')) ||
      (titleLower.contains('confirmar') && (titleLower.contains('hábito') || bodyLower.contains('hábito'))) ||
      (titleLower.contains('últimos') && bodyLower.contains('confirmar'))) {
    return NotificationType.challenge;
  }
  
  // Prioridad 3: Palabras clave de eventos
  if ((titleLower.contains('evento') || bodyLower.contains('evento')) ||
      (titleLower.contains('event') || bodyLower.contains('event')) ||
      (titleLower.contains('celebración') || bodyLower.contains('celebración'))) {
    return NotificationType.event;
  }
  
  // Prioridad 4: Palabras clave de hitos/logros
  if ((titleLower.contains('hito') || bodyLower.contains('hito')) ||
      (titleLower.contains('logro') || bodyLower.contains('logro')) ||
      (titleLower.contains('milestone') || bodyLower.contains('milestone')) ||
      (titleLower.contains('achievement') || bodyLower.contains('achievement'))) {
    return NotificationType.milestone;
  }
  
  // Prioridad 5: Palabras clave de preparativos
  if ((titleLower.contains('preparativo') || bodyLower.contains('preparativo')) ||
      (titleLower.contains('preparation') || bodyLower.contains('preparation')) ||
      (titleLower.contains('prepárate') || bodyLower.contains('prepárate'))) {
    return NotificationType.preparation;
  }
  
  // Por defecto: general
  return NotificationType.general;
}

void main() {
  print('=== TEST DE CLASIFICACIÓN DE NOTIFICACIONES ===\n');
  
  // Test 1: La notificación problemática reportada por el usuario
  final testTitle1 = '⏰ ¡Últimos 29 minutos!';
  final testBody1 = 'Recuerda confirmar tu reto de meditación antes de las 23:59. ¡Mantén tu racha!';
  final testPayload1 = '{"action":"challenge_confirmation","challengeId":"meditation_challenge","habitName":"meditación","dueTime":"23:59"}';
  
  final result1 = _determineNotificationType(testTitle1, testBody1, testPayload1);
  
  print('TEST 1 - Notificación problemática:');
  print('Título: $testTitle1');
  print('Cuerpo: $testBody1');
  print('Payload: $testPayload1');
  print('Resultado: $result1');
  print('¿Es challenge? ${result1 == NotificationType.challenge ? "✅ SÍ" : "❌ NO"}');
  print('---');
  
  // Test 2: Notificación claramente de evento
  final testTitle2 = '🎉 Nuevo evento disponible';
  final testBody2 = 'Hay un evento especial esperándote en la app';
  final testPayload2 = '{"action":"event_notification","eventId":"special_event"}';
  
  final result2 = _determineNotificationType(testTitle2, testBody2, testPayload2);
  
  print('TEST 2 - Notificación de evento:');
  print('Título: $testTitle2');
  print('Cuerpo: $testBody2');
  print('Payload: $testPayload2');
  print('Resultado: $result2');
  print('¿Es event? ${result2 == NotificationType.event ? "✅ SÍ" : "❌ NO"}');
  print('---');
  
  // Test 3: Variaciones de la notificación problemática
  final testTitle3 = '⏰ ¡Últimos 30 minutos!';
  final testBody3 = 'No olvides confirmar tu reto antes de que termine el día';
  final testPayload3 = '{"action":"challenge_confirmation","challengeId":"test"}';
  
  final result3 = _determineNotificationType(testTitle3, testBody3, testPayload3);
  
  print('TEST 3 - Variación de reto:');
  print('Título: $testTitle3');
  print('Cuerpo: $testBody3');
  print('Payload: $testPayload3');
  print('Resultado: $result3');
  print('¿Es challenge? ${result3 == NotificationType.challenge ? "✅ SÍ" : "❌ NO"}');
  print('---');
  
  // Test 4: Sin payload, solo título y cuerpo
  final testTitle4 = '⏰ ¡Últimos 29 minutos!';
  final testBody4 = 'Recuerda confirmar tu reto de lectura antes de las 23:59';
  final testPayload4 = null;
  
  final result4 = _determineNotificationType(testTitle4, testBody4, testPayload4);
  
  print('TEST 4 - Sin payload:');
  print('Título: $testTitle4');
  print('Cuerpo: $testBody4');
  print('Payload: $testPayload4');
  print('Resultado: $result4');
  print('¿Es challenge? ${result4 == NotificationType.challenge ? "✅ SÍ" : "❌ NO"}');
  print('---');
  
  print('\n=== ANÁLISIS DE PALABRAS CLAVE ===');
  print('Título contiene "Últimos": ${testTitle1.toLowerCase().contains("últimos")}');
  print('Cuerpo contiene "confirmar": ${testBody1.toLowerCase().contains("confirmar")}');
  print('Cuerpo contiene "reto": ${testBody1.toLowerCase().contains("reto")}');
  print('Payload contiene "challenge_confirmation": ${testPayload1.contains("challenge_confirmation")}');
  
  print('\n=== RESUMEN ===');
  if (result1 == NotificationType.challenge) {
    print('✅ La notificación problemática SÍ se está clasificando correctamente como CHALLENGE');
  } else {
    print('❌ PROBLEMA CONFIRMADO: La notificación se está clasificando como ${result1.toString().split('.').last.toUpperCase()}');
  }
}
