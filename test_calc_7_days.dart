/// 🧪 Prueba rápida para verificar el cálculo de 7 días
/// Caso: Reto iniciado 23 julio, confirmado 29 julio = 7 días
void main() {
  print('🧪 === VERIFICACIÓN DE CÁLCULO 7 DÍAS ===');
  
  // Caso del usuario: 23 julio - 29 julio
  final startDate = DateTime(2025, 7, 23); // 23 julio 2025
  final endDate = DateTime(2025, 7, 29);   // 29 julio 2025
  
  print('📅 Fecha inicio: ${startDate.toString().substring(0, 10)}');
  print('📅 Fecha final: ${endDate.toString().substring(0, 10)}');
  
  // Cálculo usando difference
  final diffDays = endDate.difference(startDate).inDays;
  final totalDays = diffDays + 1;
  
  print('📊 Diferencia (difference): $diffDays días');
  print('➕ Más 1 día de inclusión: $totalDays días totales');
  print('✅ Resultado: $totalDays días');
  
  // Verificar manualmente
  print('\n🔍 === VERIFICACIÓN MANUAL ===');
  print('📅 23 julio (día 1)');
  print('📅 24 julio (día 2)');
  print('📅 25 julio (día 3)');
  print('📅 26 julio (día 4)');
  print('📅 27 julio (día 5)');
  print('📅 28 julio (día 6)');
  print('📅 29 julio (día 7)');
  print('✅ Total manual: 7 días');
  
  if (totalDays == 7) {
    print('\n🎉 ¡CORRECTO! El cálculo devuelve 7 días');
    print('🎯 Debe mostrar: "🌟 ¡Una semana completa!"');
  } else {
    print('\n❌ ERROR: El cálculo devuelve $totalDays días en lugar de 7');
  }
  
  // Probar otros casos
  print('\n🧪 === OTROS CASOS DE PRUEBA ===');
  final testCases = [
    {'start': DateTime(2025, 7, 29), 'end': DateTime(2025, 7, 29), 'expected': 1},
    {'start': DateTime(2025, 7, 27), 'end': DateTime(2025, 7, 29), 'expected': 3},
    {'start': DateTime(2025, 7, 15), 'end': DateTime(2025, 7, 29), 'expected': 15},
  ];
  
  for (final testCase in testCases) {
    final start = testCase['start'] as DateTime;
    final end = testCase['end'] as DateTime;
    final expected = testCase['expected'] as int;
    
    final calculated = end.difference(start).inDays + 1;
    final isCorrect = calculated == expected;
    
    print('📅 ${start.day} → ${end.day} julio: $calculated días ${isCorrect ? '✅' : '❌'} (esperado: $expected)');
  }
}
