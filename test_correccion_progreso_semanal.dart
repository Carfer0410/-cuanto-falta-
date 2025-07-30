/// 🧪 Prueba de la corrección del progreso semanal
/// Verifica que la barra "esta semana" se calcule correctamente después de fallar

void main() {
  print('🧪 === PRUEBA DE CORRECCIÓN: PROGRESO SEMANAL ===\n');
  
  // Simular el estado del usuario antes del fallo
  final confirmationHistory = [
    DateTime(2025, 7, 28), // Lunes - confirmado
  ];
  
  final failedDays = [
    DateTime(2025, 7, 29), // Martes - falló sin perdón
  ];
  
  print('📋 ESTADO DEL RETO:');
  print('  • Reto iniciado: 27/07/2025 (Domingo)');
  print('  • Confirmaciones: ${confirmationHistory.map((d) => "${d.day}/${d.month}").join(", ")}');
  print('  • Días fallidos: ${failedDays.map((d) => "${d.day}/${d.month}").join(", ")}');
  print('  • Racha actual: 0 (se perdió)');
  
  // Probar el cálculo ANTES de la corrección
  print('\n❌ ANTES DE LA CORRECCIÓN:');
  final resultadoAntes = calcularProgresoSemanalAntes(confirmationHistory, DateTime(2025, 7, 29));
  print('  • Días completados: ${resultadoAntes["completed"]}');
  print('  • Total días: ${resultadoAntes["total"]}');
  print('  • Mostrado: ${resultadoAntes["completed"]}/${resultadoAntes["total"]} días');
  print('  • 🔴 PROBLEMA: Usuario ve "1/2" pero perdió la racha');
  
  // Probar el cálculo DESPUÉS de la corrección
  print('\n✅ DESPUÉS DE LA CORRECCIÓN:');
  final resultadoDespues = calcularProgresoSemanalDespues(confirmationHistory, failedDays, DateTime(2025, 7, 29));
  print('  • Días completados: ${resultadoDespues["completed"]}');
  print('  • Total días: ${resultadoDespues["total"]}');
  print('  • Mostrado: ${resultadoDespues["completed"]}/${resultadoDespues["total"]} días');
  print('  • 🟢 CORRECTO: Usuario ve "0/2" coherente con racha perdida');
  
  // Probar casos adicionales
  print('\n🧪 CASOS ADICIONALES:');
  
  // Caso 1: Sin fallos (debería seguir funcionando normal)
  final casoSinFallos = calcularProgresoSemanalDespues([DateTime(2025, 7, 28)], [], DateTime(2025, 7, 29));
  print('  • Sin fallos: ${casoSinFallos["completed"]}/${casoSinFallos["total"]} días ✅');
  
  // Caso 2: Múltiples confirmaciones antes del fallo
  final confirmacionesMultiples = [
    DateTime(2025, 7, 28), // Lunes
    DateTime(2025, 7, 29), // Martes (después falló)
  ];
  final falloTarde = [DateTime(2025, 7, 30)]; // Miércoles
  final casoMultiple = calcularProgresoSemanalDespues(confirmacionesMultiples, falloTarde, DateTime(2025, 7, 30));
  print('  • Múltiples confirmaciones + fallo: ${casoMultiple["completed"]}/${casoMultiple["total"]} días');
  print('    (Debería ser 0/3 porque el fallo del miércoles invalida todo)');
  
  print('\n🎯 RESUMEN DE LA CORRECCIÓN:');
  print('  ✅ Mantiene historial de confirmaciones (hechos históricos)');
  print('  ✅ Calcula progreso semanal considerando fallos posteriores');
  print('  ✅ Consistencia: Racha perdida = Progreso semanal reiniciado');
  print('  ✅ Lógica UX: "Si fallé, las confirmaciones anteriores ya no cuentan"');
}

// Simulación del cálculo ANTES de la corrección (buggy)
Map<String, int> calcularProgresoSemanalAntes(List<DateTime> historial, DateTime hoy) {
  final inicioSemana = hoy.subtract(Duration(days: hoy.weekday - 1));
  final hoyData = DateTime(hoy.year, hoy.month, hoy.day);
  
  int diasCompletados = 0;
  int totalDias = 0;
  
  for (int i = 0; i < 7; i++) {
    final dia = inicioSemana.add(Duration(days: i));
    final diaData = DateTime(dia.year, dia.month, dia.day);
    
    if (diaData.isAfter(hoyData)) break;
    totalDias++;
    
    // LÓGICA ANTERIOR (BUGGY): Solo verifica si fue confirmado
    final confirmado = historial.any((confirmacion) {
      final confirmData = DateTime(confirmacion.year, confirmacion.month, confirmacion.day);
      return confirmData.isAtSameMomentAs(diaData);
    });
    
    if (confirmado) {
      diasCompletados++;
    }
  }
  
  return {'completed': diasCompletados, 'total': totalDias};
}

// Simulación del cálculo DESPUÉS de la corrección (fixed)
Map<String, int> calcularProgresoSemanalDespues(List<DateTime> historial, List<DateTime> fallos, DateTime hoy) {
  final inicioSemana = hoy.subtract(Duration(days: hoy.weekday - 1));
  final hoyData = DateTime(hoy.year, hoy.month, hoy.day);
  
  int diasCompletados = 0;
  int totalDias = 0;
  
  for (int i = 0; i < 7; i++) {
    final dia = inicioSemana.add(Duration(days: i));
    final diaData = DateTime(dia.year, dia.month, dia.day);
    
    if (diaData.isAfter(hoyData)) break;
    totalDias++;
    
    // NUEVA LÓGICA (CORREGIDA): Verifica confirmación Y ausencia de fallos posteriores
    final confirmado = historial.any((confirmacion) {
      final confirmData = DateTime(confirmacion.year, confirmacion.month, confirmacion.day);
      return confirmData.isAtSameMomentAs(diaData);
    });
    
    final tienefallosPosterior = fallos.any((fallo) {
      final falloData = DateTime(fallo.year, fallo.month, fallo.day);
      return falloData.isAfter(diaData) || falloData.isAtSameMomentAs(diaData);
    });
    
    // Solo cuenta si fue confirmado Y no hay fallos posteriores
    if (confirmado && !tienefallosPosterior) {
      diasCompletados++;
    }
  }
  
  return {'completed': diasCompletados, 'total': totalDias};
}
