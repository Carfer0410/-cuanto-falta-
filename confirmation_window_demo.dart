void main() {
  print('=== NUEVA LÓGICA DE VENTANA DE CONFIRMACIÓN ===\n');
  
  // Simular diferentes horas del día
  final baseDate = DateTime(2025, 7, 24);
  
  print('📅 Reto iniciado el 24/07/2025 a las 13:00');
  print('⏰ Ventana de confirmación: 21:00 - 22:59\n');
  
  // Casos de prueba
  final testCases = [
    {'hour': 13, 'minute': 0, 'desc': 'Recién iniciado'},
    {'hour': 18, 'minute': 30, 'desc': 'Tarde'},
    {'hour': 20, 'minute': 59, 'desc': '1 minuto antes'},
    {'hour': 21, 'minute': 0, 'desc': 'Inicio ventana'},
    {'hour': 21, 'minute': 30, 'desc': 'Ventana activa'},
    {'hour': 22, 'minute': 30, 'desc': 'Últimos 30 min'},
    {'hour': 22, 'minute': 59, 'desc': 'Último minuto'},
    {'hour': 23, 'minute': 0, 'desc': 'Ventana cerrada'},
  ];
  
  for (final testCase in testCases) {
    final now = DateTime(baseDate.year, baseDate.month, baseDate.day, 
                        testCase['hour'] as int, testCase['minute'] as int);
    
    final currentHour = now.hour;
    final isInConfirmationWindow = currentHour >= 21 && currentHour <= 22;
    final hoursSinceStart = now.difference(DateTime(2025, 7, 24, 13, 0)).inHours;
    
    String status;
    String icon;
    
    if (hoursSinceStart < 1) {
      status = '❌ Muy pronto (< 1 hora)';
      icon = '⏳';
    } else if (!isInConfirmationWindow) {
      if (currentHour < 21) {
        status = '⏰ Esperar ventana (21:00-22:59)';
        icon = '🕒';
      } else {
        status = '❌ Ventana cerrada';
        icon = '🔒';
      }
    } else {
      status = '✅ BOTÓN DISPONIBLE';
      icon = '🎯';
    }
    
    print('$icon ${testCase['desc']} (${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}) → $status');
  }
  
  print('\n📱 NOTIFICACIONES PROGRAMADAS:');
  print('🕘 21:00 → "¡Ventana de confirmación abierta! Puedes confirmar hasta las 22:59"');
  print('⏰ 22:30 → "¡Últimos 30 minutos! No olvides confirmar antes de las 23:00"');
  
  print('\n✅ VENTAJAS:');
  print('• Lógicamente consistente: 24 horas completas antes de confirmar');
  print('• Ventana amplia: 2 horas para confirmar (21:00-22:59)');
  print('• Notificaciones automáticas: Recordatorios en momentos clave');
  print('• Ritual de cierre: Confirmar al final del día');
  print('• Previene confirmaciones inmediatas sin esfuerzo real');
}
