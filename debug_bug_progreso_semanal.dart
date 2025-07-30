/// 🐛 Reproducción del bug: confirmationHistory no se limpia al fallar
/// Esto explica por qué la barra semanal muestra "1/2" en lugar de "0/2"

void main() {
  print('🐛 === REPRODUCCIÓN DEL BUG DETECTADO ===\n');
  
  // Simular el estado antes del fallo
  final historialAntes = [
    DateTime(2025, 7, 28), // Lunes - confirmado
  ];
  
  print('📋 ESTADO ANTES DEL FALLO:');
  print('  • Historial confirmaciones: ${historialAntes.map((d) => "${d.day}/${d.month}").join(", ")}');
  print('  • Racha actual: ${historialAntes.length}');
  
  // Simular failChallenge() - COMPORTAMIENTO ACTUAL (BUGGY)
  print('\n💔 LLAMADA A failChallenge() - COMPORTAMIENTO ACTUAL:');
  final estadoDespuesBuggy = simularFailChallengeActual(historialAntes);
  print('  • ❌ Racha actual: ${estadoDespuesBuggy["currentStreak"]}');
  print('  • ❌ Historial confirmaciones: ${(estadoDespuesBuggy["confirmationHistory"] as List<DateTime>).map((d) => "${d.day}/${d.month}").join(", ")}');
  print('  • ❌ Días fallidos: ${(estadoDespuesBuggy["failedDays"] as List<DateTime>).map((d) => "${d.day}/${d.month}").join(", ")}');
  
  // Calcular progreso semanal con historial buggy
  final progresoSemanalBuggy = calcularProgresoSemanal(
    estadoDespuesBuggy["confirmationHistory"] as List<DateTime>, 
    DateTime(2025, 7, 29)
  );
  
  print('\n📊 PROGRESO SEMANAL CON BUG:');
  print('  • Días completados: ${progresoSemanalBuggy["completed"]}');
  print('  • Total días: ${progresoSemanalBuggy["total"]}');
  print('  • Mostrado: ${progresoSemanalBuggy["completed"]}/${progresoSemanalBuggy["total"]} días');
  print('  • 🔴 RESULTADO: Usuario ve "1/2 días" ¡INCORRECTO!');
  
  // Simular failChallenge() CORREGIDO
  print('\n✅ LLAMADA A failChallenge() - COMPORTAMIENTO CORREGIDO:');
  final estadoDespuesCorregido = simularFailChallengeCorregido(historialAntes);
  print('  • ✅ Racha actual: ${estadoDespuesCorregido["currentStreak"]}');
  print('  • ✅ Historial confirmaciones: ${(estadoDespuesCorregido["confirmationHistory"] as List<DateTime>).isEmpty ? "VACÍO" : (estadoDespuesCorregido["confirmationHistory"] as List<DateTime>).map((d) => "${d.day}/${d.month}").join(", ")}');
  print('  • ✅ Días fallidos: ${(estadoDespuesCorregido["failedDays"] as List<DateTime>).map((d) => "${d.day}/${d.month}").join(", ")}');
  
  // Calcular progreso semanal corregido
  final progresoSemanalCorregido = calcularProgresoSemanal(
    estadoDespuesCorregido["confirmationHistory"] as List<DateTime>, 
    DateTime(2025, 7, 29)
  );
  
  print('\n📊 PROGRESO SEMANAL CORREGIDO:');
  print('  • Días completados: ${progresoSemanalCorregido["completed"]}');
  print('  • Total días: ${progresoSemanalCorregido["total"]}');
  print('  • Mostrado: ${progresoSemanalCorregido["completed"]}/${progresoSemanalCorregido["total"]} días');
  print('  • 🟢 RESULTADO: Usuario ve "0/2 días" ¡CORRECTO!');
  
  print('\n🎯 CONCLUSIÓN:');
  print('  El bug está en failChallenge() - NO limpia confirmationHistory');
  print('  Solución: Limpiar confirmationHistory al fallar sin perdón');
  print('  RECOMENDACIÓN UX: Mantener progreso semanal porque representa hechos reales');
}

Map<String, dynamic> simularFailChallengeActual(List<DateTime> historialPrevio) {
  // COMPORTAMIENTO ACTUAL (BUGGY): Solo resetea racha, NO limpia historial
  return {
    'currentStreak': 0,
    'confirmationHistory': [...historialPrevio], // ❌ BUG: Se mantiene
    'failedDays': [DateTime(2025, 7, 29)],
  };
}

Map<String, dynamic> simularFailChallengeCorregido(List<DateTime> historialPrevio) {
  // COMPORTAMIENTO CORREGIDO: Resetea racha Y limpia historial
  return {
    'currentStreak': 0,
    'confirmationHistory': <DateTime>[], // ✅ CORREGIDO: Se limpia
    'failedDays': [DateTime(2025, 7, 29)],
  };
}

Map<String, int> calcularProgresoSemanal(List<DateTime> historial, DateTime hoy) {
  final inicioSemana = hoy.subtract(Duration(days: hoy.weekday - 1));
  final hoyData = DateTime(hoy.year, hoy.month, hoy.day);
  
  int diasCompletados = 0;
  int totalDias = 0;
  
  for (int i = 0; i < 7; i++) {
    final dia = inicioSemana.add(Duration(days: i));
    final diaData = DateTime(dia.year, dia.month, dia.day);
    
    if (diaData.isAfter(hoyData)) break;
    totalDias++;
    
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
