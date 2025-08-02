// Test puro de la función de clasificación sin dependencias de Flutter UI

import 'lib/notification_center_models.dart';

// Recreamos la función desde notification_service.dart 
NotificationType _determineNotificationType(String title, String body) {
  final titleLower = title.toLowerCase();
  final bodyLower = body.toLowerCase();
  final fullText = '$titleLower $bodyLower'.toLowerCase();

  // NUEVO ORDEN: Retos tienen prioridad máxima
  // 1. CHALLENGE - Prioridad máxima para confirmar retos
  if (fullText.contains('confirmar') && 
      (fullText.contains('reto') || fullText.contains('challenge') || fullText.contains('hábito'))) {
    return NotificationType.challenge;
  }
  
  if (fullText.contains('ventana de confirmación') || 
      fullText.contains('confirmation window')) {
    return NotificationType.challenge;
  }
  
  if (fullText.contains('últimos') && fullText.contains('minutos') && 
      (fullText.contains('confirmar') || fullText.contains('reto'))) {
    return NotificationType.challenge;
  }

  // 2. ACHIEVEMENT - Logros y rachas
  if (fullText.contains('¡felicidades!') || fullText.contains('logro') || 
      fullText.contains('racha') || fullText.contains('achievement') ||
      fullText.contains('¡increíble!') || fullText.contains('¡excelente!')) {
    return NotificationType.achievement;
  }

  // 3. EVENT - Solo eventos específicos SIN emojis de tiempo
  if ((fullText.contains('evento') || fullText.contains('event')) && 
      !fullText.contains('confirmar') && !fullText.contains('reto')) {
    return NotificationType.event;
  }

  // 4. Clasificación por emoji - DESPUÉS de contenido específico
  if (titleLower.contains('🏆') || titleLower.contains('🎉') || titleLower.contains('✨')) {
    return NotificationType.achievement;
  }

  if (titleLower.contains('📅') && !fullText.contains('reto') && !fullText.contains('confirmar')) {
    return NotificationType.event;
  }

  // 5. MOTIVATION
  if (fullText.contains('motivación') || fullText.contains('motivation') ||
      fullText.contains('ánimo') || fullText.contains('keep going')) {
    return NotificationType.motivation;
  }

  // 6. PLANNING
  if (fullText.contains('planificación') || fullText.contains('planning') ||
      fullText.contains('preparativo') || fullText.contains('strategy')) {
    return NotificationType.planning;
  }

  // 7. SYSTEM
  if (fullText.contains('sistema') || fullText.contains('system') ||
      fullText.contains('error') || fullText.contains('actualización')) {
    return NotificationType.system;
  }

  // 8. REMINDER
  if (fullText.contains('recordatorio') || fullText.contains('reminder') ||
      fullText.contains('no olvides')) {
    return NotificationType.reminder;
  }

  // 9. Default
  return NotificationType.general;
}

void main() {
  print('🧪 === PRUEBA DE CLASIFICACIÓN CORREGIDA ===');
  
  // Casos de prueba específicos
  final testCases = [
    {
      'title': '⏰ ¡Últimos 29 minutos!',
      'body': 'No olvides confirmar tu reto de meditación antes de que termine el día. ¡Ve a la pantalla de retos!',
      'expected': NotificationType.challenge,
      'description': 'Notificación problemática reportada por el usuario'
    },
    {
      'title': '🔔 Ventana de confirmación abierta',
      'body': 'Tu ventana de confirmación para retos está ahora disponible. ¡No olvides confirmar tus hábitos!',
      'expected': NotificationType.challenge,
      'description': 'Ventana de confirmación de retos'
    },
    {
      'title': '📅 Evento próximo',
      'body': 'Tu evento de trabajo está programado para mañana a las 10:00 AM.',
      'expected': NotificationType.event,
      'description': 'Evento real de calendario'
    },
    {
      'title': '⏰ Recordatorio de tiempo',
      'body': 'Faltan 30 minutos para tu evento de reunión semanal.',
      'expected': NotificationType.event,
      'description': 'Recordatorio de evento sin mención de retos'
    },
    {
      'title': '🏆 ¡Felicidades!',
      'body': 'Has alcanzado una racha de 7 días en meditación.',
      'expected': NotificationType.achievement,
      'description': 'Logro de racha'
    },
    {
      'title': '🎯 Motivación diaria',
      'body': 'Recuerda que cada día es una oportunidad para mejorar. ¡Sigue adelante!',
      'expected': NotificationType.motivation,
      'description': 'Mensaje motivacional'
    },
    {
      'title': '📋 Planificación',
      'body': 'Es hora de revisar tus preparativos para la semana siguiente.',
      'expected': NotificationType.planning,
      'description': 'Recordatorio de planificación'
    },
    {
      'title': '🔧 Sistema',
      'body': 'Actualización del sistema completada exitosamente.',
      'expected': NotificationType.system,
      'description': 'Notificación del sistema'
    }
  ];
  
  bool allPassed = true;
  int testNumber = 1;
  
  for (final testCase in testCases) {
    final result = _determineNotificationType(
      testCase['title'] as String, 
      testCase['body'] as String
    );
    final expected = testCase['expected'] as NotificationType;
    final passed = result == expected;
    
    if (!passed) allPassed = false;
    
    final status = passed ? '✅ PASS' : '❌ FAIL';
    print('\n$testNumber. $status - ${testCase['description']}');
    print('   Título: "${testCase['title']}"');
    print('   Resultado: $result');
    print('   Esperado: $expected');
    
    if (!passed) {
      print('   🚨 CLASIFICACIÓN INCORRECTA');
    }
    
    testNumber++;
  }
  
  print('\n' + '='*50);
  if (allPassed) {
    print('🎉 ¡TODOS LOS TESTS PASARON! (${ testCases.length }/8)');
    print('✅ La notificación problemática ahora se clasifica correctamente como CHALLENGE');
  } else {
    print('❌ Algunos tests fallaron');
  }
  print('='*50);
}
