// 🧪 TEST PARA REPRODUCIR BUG DE RACHA AUTOMÁTICA
// Archivo: test_bug_racha_automatica.dart

void main() {
  print('=== 🔍 REPRODUCCIÓN DEL BUG DE RACHA AUTOMÁTICA ===\n');
  
  // Simular el escenario exacto del bug
  testBugRachaAutomatica();
  
  print('\n=== 🧪 CASOS DE PRUEBA ADICIONALES ===');
  testCasosEdge();
}

void testBugRachaAutomatica() {
  print('🎯 CASO 1: Reto creado el mismo día');
  
  // Simular creación de reto hoy
  final hoy = DateTime.now();
  final fechaInicioSeleccionada = DateTime(hoy.year, hoy.month, hoy.day);
  
  print('📅 Fecha actual: ${hoy.toString()}');
  print('📅 Fecha inicio seleccionada: ${fechaInicioSeleccionada.toString()}');
  
  // Reproducir el cálculo problemático de _handleBackdatedChallenge
  final today = DateTime(hoy.year, hoy.month, hoy.day);
  final start = DateTime(fechaInicioSeleccionada.year, fechaInicioSeleccionada.month, fechaInicioSeleccionada.day);
  
  final daysPassed = today.difference(start).inDays;
  
  print('🔍 today normalizado: $today');
  print('🔍 start normalizado: $start');
  print('🔍 daysPassed calculado: $daysPassed');
  print('🔍 Condición actual (daysPassed < 1): ${daysPassed < 1}');
  print('🔍 ¿Se activaría backdated dialog?: ${daysPassed >= 1}');
  
  if (daysPassed >= 1) {
    print('🚨 BUG REPRODUCIDO: Se activaría diálogo para reto del mismo día');
    print('   → Usuario vería: "Registraste un reto que empezó hace $daysPassed días"');
    print('   → Si usuario dice "Sí", obtendría $daysPassed días de racha');
  } else {
    print('✅ COMPORTAMIENTO CORRECTO: No se activa diálogo backdated');
  }
}

void testCasosEdge() {
  print('\n🔬 CASO 2: Diferencias de medianoche');
  
  // Caso: Usuario crea reto a las 23:59, fecha seleccionada es "hoy"
  final ahoraMedianoche = DateTime(2025, 7, 29, 23, 59);
  final fechaSeleccionada = DateTime(2025, 7, 29); // Mismo día
  
  final today = DateTime(ahoraMedianoche.year, ahoraMedianoche.month, ahoraMedianoche.day);
  final start = DateTime(fechaSeleccionada.year, fechaSeleccionada.month, fechaSeleccionada.day);
  
  final daysPassed = today.difference(start).inDays;
  
  print('⏰ Hora actual: 23:59');
  print('📅 Fecha seleccionada: mismo día');
  print('🔍 daysPassed: $daysPassed');
  print('🔍 ¿Bug de medianoche?: ${daysPassed >= 1}');
  
  print('\n🔬 CASO 3: Reto realmente atrasado (comportamiento correcto)');
  
  final fechaAyer = DateTime(2025, 7, 28);
  final hoyReal = DateTime(2025, 7, 29);
  
  final todayReal = DateTime(hoyReal.year, hoyReal.month, hoyReal.day);
  final startAyer = DateTime(fechaAyer.year, fechaAyer.month, fechaAyer.day);
  
  final daysPassed2 = todayReal.difference(startAyer).inDays;
  
  print('📅 Fecha inicio: 28 julio (ayer)');
  print('📅 Fecha actual: 29 julio (hoy)');
  print('🔍 daysPassed: $daysPassed2');
  print('🔍 ¿Debería activar backdated?: ${daysPassed2 >= 1} ✅');
}

// PROPUESTA DE CORRECCIÓN
void testSolucionPropuesta() {
  print('\n💡 TESTING DE SOLUCIÓN PROPUESTA\n');
  
  final hoy = DateTime.now();
  final fechaInicioSeleccionada = DateTime(hoy.year, hoy.month, hoy.day);
  
  // MÉTODO ACTUAL (PROBLEMÁTICO)
  final today = DateTime(hoy.year, hoy.month, hoy.day);
  final start = DateTime(fechaInicioSeleccionada.year, fechaInicioSeleccionada.month, fechaInicioSeleccionada.day);
  final daysPassed = today.difference(start).inDays;
  
  print('🔴 MÉTODO ACTUAL:');
  print('   daysPassed: $daysPassed');
  print('   Activar backdated: ${daysPassed >= 1}');
  
  // MÉTODO CORREGIDO (PROPUESTO)
  final isActuallyBackdated = start.isBefore(today);
  
  print('🟢 MÉTODO CORREGIDO:');
  print('   start.isBefore(today): $isActuallyBackdated');
  print('   Activar backdated: $isActuallyBackdated');
  
  if (daysPassed >= 1 && !isActuallyBackdated) {
    print('🎯 DIFERENCIA DETECTADA: El método actual tiene falso positivo');
  } else {
    print('✅ Ambos métodos coinciden para este caso');
  }
}
