/// 🧪 Análisis del caso específico del usuario
/// Reto retroactivo desde 27/07/2025, confirmó "no cumplí", rechazó perdón
/// Estado: 0 días cumplidos, tiempo corrido 2 días 21h 32m, barra "esta semana" 1/2

void main() {
  print('🧪 === ANÁLISIS DEL CASO ESPECÍFICO ===\n');
  
  // Fechas del caso real
  final retoIniciado = DateTime(2025, 7, 27); // Domingo
  final fechaConfirmacion = DateTime(2025, 7, 29); // Martes (HOY)
  
  print('📅 INFORMACIÓN DEL RETO:');
  print('  • Inicio: ${retoIniciado.day}/${retoIniciado.month}/${retoIniciado.year} (${_getDayName(retoIniciado.weekday)})');
  print('  • Hoy: ${fechaConfirmacion.day}/${fechaConfirmacion.month}/${fechaConfirmacion.year} (${_getDayName(fechaConfirmacion.weekday)})');
  print('  • Tipo: Reto RETROACTIVO');
  
  // Calcular tiempo transcurrido
  final tiempoTranscurrido = fechaConfirmacion.difference(retoIniciado);
  print('\n⏰ TIEMPO TRANSCURRIDO:');
  print('  • Total: ${tiempoTranscurrido.inDays} días, ${tiempoTranscurrido.inHours % 24} horas');
  print('  • Esperado por usuario: "2 días 21 horas 32 minutos 42 segundos" ✅');
  
  // Analizar la barra de progreso semanal
  print('\n📊 ANÁLISIS DE LA BARRA "ESTA SEMANA":');
  print('  • Semana actual: Lunes ${_getMonday(fechaConfirmacion).day}/${_getMonday(fechaConfirmacion).month} al Domingo ${_getSunday(fechaConfirmacion).day}/${_getSunday(fechaConfirmacion).month}');
  print('  • Usuario reporta: "1/2 días" en la barra');
  print('  • Días transcurridos esta semana hasta HOY: ${_getDaysInWeekUntilToday(fechaConfirmacion)}');
  
  // Simular el comportamiento del código actual
  print('\n🔍 SIMULACIÓN DEL COMPORTAMIENTO ACTUAL:');
  
  // Estado después de rechazar perdón
  final rachaActual = 0; // Se reseteó por failChallenge()
  final historialConfirmaciones = <DateTime>[]; // Vacío porque perdió la racha
  final diasFallidos = [fechaConfirmacion]; // Se agregó hoy como día fallido
  
  print('  Estado después de "rechazar perdón":');
  print('    • Racha actual: $rachaActual días ✅');
  print('    • Historial confirmaciones: ${historialConfirmaciones.isEmpty ? "vacío" : historialConfirmaciones.map((d) => "${d.day}/${d.month}").join(", ")} ✅');
  print('    • Días fallidos: ${diasFallidos.map((d) => "${d.day}/${d.month}").join(", ")} ✅');
  
  // Calcular progreso semanal según el código actual
  final progresoSemanal = _calcularProgresoSemanal(historialConfirmaciones, fechaConfirmacion);
  
  print('\n📈 CÁLCULO DEL PROGRESO SEMANAL:');
  print('  • Días completados esta semana: ${progresoSemanal["completed"]}');
  print('  • Total días disponibles esta semana: ${progresoSemanal["total"]}');
  print('  • Mostrado como: ${progresoSemanal["completed"]}/${progresoSemanal["total"]} días');
  print('  • Usuario reporta: "1/2 días"');
  
  // Verificar si hay inconsistencia
  if (progresoSemanal["completed"] == 1 && progresoSemanal["total"] == 2) {
    print('\n❌ INCONSISTENCIA DETECTADA:');
    print('  El usuario no confirmó NINGÚN día (racha = 0, historial vacío)');
    print('  Pero la barra muestra "1/2 días" - esto indica un BUG');
    print('\n🔍 POSIBLES CAUSAS:');
    print('  1. El _calculateWeeklyProgress() cuenta días incorrectamente');
    print('  2. Hay confirmaciones fantasma en el historial');
    print('  3. No se limpia correctamente el historial al fallar');
    print('  4. Cuenta el domingo 28/07 como "confirmado" incorrectamente');
  } else if (progresoSemanal["completed"] == 0 && progresoSemanal["total"] == 2) {
    print('\n✅ COMPORTAMIENTO CORRECTO:');
    print('  La barra muestra "0/2 días" - coherente con racha perdida');
  } else {
    print('\n⚠️  RESULTADO INESPERADO:');
    print('  Revisar lógica del cálculo semanal');
  }
  
  print('\n🎯 CONCLUSIÓN:');
  print('Si la barra muestra "1/2" con racha = 0, HAY UN BUG.');
  print('Debería mostrar "0/2" porque no se confirmó ningún día esta semana.');
}

Map<String, int> _calcularProgresoSemanal(List<DateTime> historial, DateTime hoy) {
  final inicioSemana = _getMonday(hoy);
  final hoyData = DateTime(hoy.year, hoy.month, hoy.day);
  
  int diasCompletados = 0;
  int totalDias = 0;
  
  // Contar días de esta semana hasta hoy
  for (int i = 0; i < 7; i++) {
    final dia = inicioSemana.add(Duration(days: i));
    final diaData = DateTime(dia.year, dia.month, dia.day);
    
    if (diaData.isAfter(hoyData)) break; // No contar días futuros
    totalDias++;
    
    // Verificar si se completó este día
    final confirmado = historial.any((confirmacion) {
      final confirmData = DateTime(confirmacion.year, confirmacion.month, confirmacion.day);
      return confirmData.isAtSameMomentAs(diaData);
    });
    
    if (confirmado) {
      diasCompletados++;
    }
  }
  
  return {
    'completed': diasCompletados,
    'total': totalDias,
  };
}

DateTime _getMonday(DateTime date) {
  return date.subtract(Duration(days: date.weekday - 1));
}

DateTime _getSunday(DateTime date) {
  return date.add(Duration(days: 7 - date.weekday));
}

int _getDaysInWeekUntilToday(DateTime today) {
  final monday = _getMonday(today);
  return today.difference(monday).inDays + 1; // +1 porque incluimos hoy
}

String _getDayName(int weekday) {
  switch (weekday) {
    case 1: return 'Lunes';
    case 2: return 'Martes';
    case 3: return 'Miércoles';
    case 4: return 'Jueves';
    case 5: return 'Viernes';
    case 6: return 'Sábado';
    case 7: return 'Domingo';
    default: return 'Desconocido';
  }
}
