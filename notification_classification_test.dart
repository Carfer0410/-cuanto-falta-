// Simulación de NotificationType enum para pruebas
enum NotificationType {
  challenge,
  achievement,
  event,
  motivation,
  planning,
  system,
  reminder,
  general
}

/// Función de prueba para verificar clasificación de notificaciones
NotificationType determineNotificationType(String title, String body) {
  final titleLower = title.toLowerCase();
  final bodyLower = body.toLowerCase();
  
  // Patrones para identificar tipos de notificación
  // ORDEN IMPORTANTE: Los más específicos primero
  
  // 1. RETOS/CHALLENGES (prioridad alta - incluye confirmaciones y recordatorios)
  if (titleLower.contains('reto') || titleLower.contains('challenge') ||
      titleLower.contains('racha') || titleLower.contains('streak') ||
      bodyLower.contains('confirmar') || bodyLower.contains('confirm') ||
      bodyLower.contains('reto') || bodyLower.contains('challenge') ||
      titleLower.contains('🔥') || titleLower.contains('💪') ||
      titleLower.contains('🛡️') || titleLower.contains('💔')) {
    return NotificationType.challenge;
  }
  
  // 2. LOGROS/ACHIEVEMENTS
  if (titleLower.contains('logro') || titleLower.contains('achievement') || 
      titleLower.contains('🎉') || titleLower.contains('🏆')) {
    return NotificationType.achievement;
  }
  
  // 3. EVENTOS (solo para eventos específicos, no para recordatorios de retos)
  if (titleLower.contains('evento') || titleLower.contains('event') ||
      (titleLower.contains('📅') && !bodyLower.contains('reto') && !bodyLower.contains('confirmar'))) {
    return NotificationType.event;
  }
  
  // 4. MOTIVACIÓN
  if (titleLower.contains('motivación') || titleLower.contains('motivation') ||
      bodyLower.contains('sigue') || bodyLower.contains('ánimo') ||
      titleLower.contains('💭') || titleLower.contains('🌟')) {
    return NotificationType.motivation;
  }
  
  // 5. PLANIFICACIÓN/PERSONALIZACIÓN
  if (titleLower.contains('planificación') || titleLower.contains('estilo') ||
      titleLower.contains('personalización') || titleLower.contains('🎨')) {
    return NotificationType.planning;
  }
  
  // 6. SISTEMA
  if (titleLower.contains('sistema') || titleLower.contains('system') ||
      titleLower.contains('configuración') || titleLower.contains('⚙️')) {
    return NotificationType.system;
  }
  
  // 7. RECORDATORIOS GENERALES (solo si no son de retos)
  if ((titleLower.contains('recordatorio') || titleLower.contains('reminder') ||
       titleLower.contains('⏰') || titleLower.contains('🔔')) &&
      !bodyLower.contains('reto') && !bodyLower.contains('confirmar')) {
    return NotificationType.reminder;
  }
  
  return NotificationType.general;
}

void main() {
  print('🧪 === PRUEBA DE CLASIFICACIÓN DE NOTIFICACIONES ===\n');
  
  // Casos de prueba
  final testCases = [
    {
      'title': '⏰ ¡Últimos 29 minutos!',
      'body': 'Recuerda confirmar tu reto antes de las 23:59. ¡Solo quedan 29 minutos!',
      'expected': NotificationType.challenge
    },
    {
      'title': '🔔 Ventana de confirmación abierta',
      'body': 'Confirma tus retos diarios. La ventana cierra a las 23:59.',
      'expected': NotificationType.challenge
    },
    {
      'title': '📅 Evento próximo',
      'body': 'El evento Feria de Cali empieza mañana.',
      'expected': NotificationType.event
    },
    {
      'title': '🎉 ¡Logro desbloqueado!',
      'body': 'Has completado 7 días seguidos.',
      'expected': NotificationType.achievement
    },
    {
      'title': '🛡️ Ficha de perdón usada',
      'body': 'Ficha usada para "meditación". Racha preservada.',
      'expected': NotificationType.challenge
    },
    {
      'title': '💔 Racha perdida',
      'body': 'No confirmaste "ejercicio" ayer. Racha reseteada.',
      'expected': NotificationType.challenge
    },
    {
      'title': '🎨 ¡Bienvenido!',
      'body': 'Personaliza tu experiencia configurando tu estilo de planificación.',
      'expected': NotificationType.planning
    },
    {
      'title': '⏰ Recordatorio',
      'body': 'No olvides revisar tus eventos de hoy.',
      'expected': NotificationType.reminder
    }
  ];
  
  int passed = 0;
  int failed = 0;
  
  for (int i = 0; i < testCases.length; i++) {
    final test = testCases[i];
    final result = determineNotificationType(test['title'] as String, test['body'] as String);
    final expected = test['expected'] as NotificationType;
    
    if (result == expected) {
      print('✅ Caso ${i + 1}: CORRECTO');
      print('   Título: "${test['title']}"');
      print('   Clasificado como: $result');
      passed++;
    } else {
      print('❌ Caso ${i + 1}: FALLO');
      print('   Título: "${test['title']}"');
      print('   Esperado: $expected');
      print('   Obtenido: $result');
      failed++;
    }
    print('');
  }
  
  print('📊 === RESUMEN ===');
  print('✅ Casos correctos: $passed');
  print('❌ Casos fallidos: $failed');
  print('📈 Porcentaje de éxito: ${(passed / testCases.length * 100).toStringAsFixed(1)}%');
  
  if (failed == 0) {
    print('🎉 ¡Todas las pruebas pasaron! La clasificación funciona correctamente.');
  } else {
    print('⚠️  Hay casos que necesitan revisión.');
  }
}
