void main() async {
  print('🧪 === TEST FLUJO COMPLETO RACHA RETROACTIVA ===');
  
  // Simular el flujo de add_counter_page.dart
  
  // 1. Simular la creación del counter
  print('1️⃣ Simulando creación de counter...');
  
  // Simular lista de counters existente
  List<dynamic> list = [
    {'title': 'ejercicio', 'startDate': '2025-07-25T00:00:00.000Z'},
    {'title': 'leer', 'startDate': '2025-07-28T00:00:00.000Z'},
  ];
  
  // Generar challengeId como en add_counter_page.dart
  final challengeId = 'challenge_${list.length}'; // Sería "challenge_2"
  print('   challengeId generado: $challengeId');
  
  // 2. Simular cálculo de días
  print('\n2️⃣ Simulando cálculo de días...');
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final startDate = DateTime(2025, 7, 28); // 28 de julio
  final start = DateTime(startDate.year, startDate.month, startDate.day);
  
  final daysPassed = today.difference(start).inDays + 1; // CORRECCIÓN APLICADA
  print('   Fecha inicio: 28/07/2025');
  print('   Fecha hoy: ${today.day}/${today.month}/${today.year}');
  print('   Días calculados: $daysPassed');
  
  // 3. Simular creación de historial retroactivo
  print('\n3️⃣ Simulando historial retroactivo...');
  final backdatedHistory = <DateTime>[];
  for (int i = 0; i < daysPassed; i++) {
    final confirmDate = startDate.add(Duration(days: i));
    backdatedHistory.add(confirmDate);
  }
  
  print('   Historial creado: ${backdatedHistory.map((d) => '${d.day}/${d.month}').join(', ')}');
  
  // 4. Simular cálculo de racha (_calculateStreak)
  print('\n4️⃣ Simulando cálculo de racha...');
  
  // Obtener confirmaciones únicas ordenadas (más reciente primero)
  final uniqueConfirmations = <DateTime>{};
  for (final confirmation in backdatedHistory) {
    final normalizedDate = DateTime(confirmation.year, confirmation.month, confirmation.day);
    uniqueConfirmations.add(normalizedDate);
  }
  
  final sortedConfirmations = uniqueConfirmations.toList();
  sortedConfirmations.sort((a, b) => b.compareTo(a)); // Más reciente primero
  
  print('   Confirmaciones ordenadas: ${sortedConfirmations.map((d) => '${d.day}/${d.month}').join(', ')}');
  
  int calculatedStreak = 0;
  DateTime expectedDate = sortedConfirmations.first;
  
  for (final confirmDate in sortedConfirmations) {
    if (confirmDate.isAtSameMomentAs(expectedDate)) {
      calculatedStreak++;
      expectedDate = expectedDate.subtract(Duration(days: 1));
    } else {
      break;
    }
  }
  
  print('   Racha calculada: $calculatedStreak');
  
  // 5. Resultado final
  print('\n🎯 RESULTADO FINAL:');
  print('   challengeId: $challengeId');
  print('   Días retroactivos: $daysPassed');
  print('   Racha aplicada: $calculatedStreak');
  print('   ¿Debería mostrar racha inmediata?: ${calculatedStreak > 0 ? 'SÍ' : 'NO'}');
  
  if (calculatedStreak == daysPassed) {
    print('   ✅ CORRECTO - La racha coincide con los días');
  } else {
    print('   ❌ ERROR - La racha no coincide');
  }
  
  print('\n📋 Instrucciones de debugging:');
  print('1. Abre la app y crea un reto con fecha 28/07/2025');
  print('2. Verifica en la consola estos logs:');
  print('   - "🔍 challengeId: $challengeId"');
  print('   - "🔄 Racha calculada por _calculateStreak: $calculatedStreak"');
  print('   - "🎉 ✅ Reto retroactivo creado con racha calculada: $calculatedStreak días"');
  print('3. En la UI, busca el challengeId "$challengeId" y verifica que muestre $calculatedStreak días');
}
