void main() async {
  print('🧪 === DEBUG VENTANA DE CONFIRMACIÓN ===');
  
  final now = DateTime.now();
  final currentHour = now.hour;
  final currentMinute = now.minute;
  
  print('🕐 Hora actual: ${currentHour}:${currentMinute.toString().padLeft(2, '0')}');
  
  // Verificar si estamos en la ventana de confirmación
  final isInWindow = currentHour >= 21 && currentHour <= 23;
  print('🎯 ¿En ventana de confirmación (21:00-23:59)?: ${isInWindow ? "✅ SÍ" : "❌ NO"}');
  
  if (!isInWindow) {
    if (currentHour < 21) {
      final hoursUntil21 = 21 - currentHour;
      final minutesUntil21 = 60 - currentMinute;
      print('⏰ Faltan ${hoursUntil21}h ${minutesUntil21}min para que abra la ventana (21:00)');
    } else {
      print('⏰ La ventana ya cerró (era hasta las 23:59). Próxima ventana mañana a las 21:00');
    }
  } else {
    final minutesLeft = (23 - currentHour) * 60 + (59 - currentMinute);
    print('⏰ Quedan ${minutesLeft} minutos hasta que cierre la ventana (23:59)');
  }
  
  print('');
  print('📋 DEBUGGING CHECKLIST:');
  print('1. ¿Los retos están iniciados? (challengeStartedAt != null)');
  print('2. ¿Los retos no están confirmados hoy?');
  print('3. ¿La hora está entre 21:00 y 23:59?');
  print('');
  print('🔍 En la app, revisa los logs que deberían aparecer:');
  print('   • "🕐 [nombre_reto] - Hora actual: XX:XX, En ventana: true"');
  print('   • "❌ Botón NO mostrado para [nombre_reto]" (si hay problema)');
  print('   • "⏰ Reto [nombre_reto] esperando ventana" (si fuera de horario)');
  print('');
  print('💡 SOLUCIÓN si no aparece el botón:');
  print('   1. Asegúrate de que el reto esté INICIADO (presiona "Iniciar Reto")');
  print('   2. Verifica que no esté ya confirmado hoy');
  print('   3. Confirma que sea entre 21:00-23:59');
}
