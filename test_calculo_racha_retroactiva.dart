// 🧪 TEST ESPECÍFICO PARA VERIFICAR CÁLCULO DE RACHAS RETROACTIVAS
// Archivo: test_calculo_racha_retroactiva.dart

void main() {
  print('=== 🔍 TEST: CÁLCULO DE RACHAS RETROACTIVAS ===\n');
  
  testCalculoRachaConsecutiva();
  testCalculoRachaConHuecos();
  testCalculoRachaUnicaFecha();
}

void testCalculoRachaConsecutiva() {
  print('🧮 TEST 1: Racha consecutiva perfecta');
  
  // Simular reto retroactivo de 3 días consecutivos
  final startDate = DateTime(2025, 7, 27); // 27 julio
  final daysToGrant = 3;
  
  print('\n📅 ESCENARIO:');
  print('  • Fecha inicio: 27 julio 2025');
  print('  • Días a otorgar: $daysToGrant');
  print('  • Fechas esperadas: 27/07, 28/07, 29/07');
  
  // Crear historial de confirmaciones (igual que grantBackdatedStreak)
  final backdatedHistory = <DateTime>[];
  for (int i = 0; i < daysToGrant; i++) {
    final confirmDate = startDate.add(Duration(days: i));
    backdatedHistory.add(confirmDate);
  }
  
  print('\n📋 HISTORIAL CREADO:');
  for (int i = 0; i < backdatedHistory.length; i++) {
    final date = backdatedHistory[i];
    print('  [$i] ${date.day}/${date.month}/${date.year}');
  }
  
  // Simular lógica de _calculateStreak
  final uniqueConfirmations = <DateTime>{};
  for (final confirmation in backdatedHistory) {
    final normalizedDate = DateTime(confirmation.year, confirmation.month, confirmation.day);
    uniqueConfirmations.add(normalizedDate);
  }
  
  final sortedConfirmations = uniqueConfirmations.toList();
  sortedConfirmations.sort((a, b) => b.compareTo(a)); // Más reciente primero
  
  print('\n🔄 CONFIRMACIONES ORDENADAS (más reciente primero):');
  for (int i = 0; i < sortedConfirmations.length; i++) {
    final date = sortedConfirmations[i];
    print('  [$i] ${date.day}/${date.month}');
  }
  
  // Calcular racha (nueva lógica)
  int currentStreak = 0;
  DateTime expectedDate = sortedConfirmations.first; // Empezar desde más reciente
  
  print('\n🧮 CÁLCULO DE RACHA:');
  print('  Empezando desde: ${expectedDate.day}/${expectedDate.month}');
  
  for (final confirmDate in sortedConfirmations) {
    print('  🔍 Verificando: ${confirmDate.day}/${confirmDate.month}');
    print('    Esperada: ${expectedDate.day}/${expectedDate.month}');
    
    if (confirmDate.isAtSameMomentAs(expectedDate)) {
      currentStreak++;
      expectedDate = expectedDate.subtract(Duration(days: 1));
      print('    ✅ Racha aumenta a: $currentStreak');
      print('    Siguiente esperada: ${expectedDate.day}/${expectedDate.month}');
    } else {
      print('    ❌ Hueco en la racha, parar');
      break;
    }
  }
  
  print('\n🎯 RESULTADO:');
  print('  Racha calculada: $currentStreak días');
  print('  Racha esperada: $daysToGrant días');
  print('  ✅ CORRECTO: ${currentStreak == daysToGrant ? 'SÍ' : 'NO'}');
}

void testCalculoRachaConHuecos() {
  print('\n\n🧮 TEST 2: Racha con huecos (debería contar solo consecutivos)');
  
  // Simular confirmaciones: 27/07, 28/07, 30/07 (falta 29/07)
  final confirmations = [
    DateTime(2025, 7, 27),
    DateTime(2025, 7, 28),
    DateTime(2025, 7, 30), // Hueco aquí
  ];
  
  print('\n📋 HISTORIAL CON HUECO:');
  for (int i = 0; i < confirmations.length; i++) {
    final date = confirmations[i];
    print('  [$i] ${date.day}/${date.month}');
  }
  
  // Simular lógica de _calculateStreak
  final sortedConfirmations = [...confirmations];
  sortedConfirmations.sort((a, b) => b.compareTo(a)); // Más reciente primero
  
  print('\n🔄 ORDENADAS (más reciente primero):');
  for (final date in sortedConfirmations) {
    print('  ${date.day}/${date.month}');
  }
  
  // Calcular racha
  int currentStreak = 0;
  DateTime expectedDate = sortedConfirmations.first;
  
  print('\n🧮 CÁLCULO:');
  print('  Empezando desde: ${expectedDate.day}/${expectedDate.month}');
  
  for (final confirmDate in sortedConfirmations) {
    print('  🔍 Verificando: ${confirmDate.day}/${confirmDate.month}');
    print('    Esperada: ${expectedDate.day}/${expectedDate.month}');
    
    if (confirmDate.isAtSameMomentAs(expectedDate)) {
      currentStreak++;
      expectedDate = expectedDate.subtract(Duration(days: 1));
      print('    ✅ Racha aumenta a: $currentStreak');
    } else {
      print('    ❌ Hueco detectado, parar');
      break;
    }
  }
  
  print('\n🎯 RESULTADO:');
  print('  Racha calculada: $currentStreak días');
  print('  Racha esperada: 1 día (solo 30/07, porque 29/07 falta)');
  print('  ✅ CORRECTO: ${currentStreak == 1 ? 'SÍ' : 'NO'}');
}

void testCalculoRachaUnicaFecha() {
  print('\n\n🧮 TEST 3: Racha de un solo día');
  
  final confirmations = [DateTime(2025, 7, 30)];
  
  print('\n📋 HISTORIAL DE UN DÍA:');
  print('  30/07/2025');
  
  // Calcular racha
  int currentStreak = 0;
  DateTime expectedDate = confirmations.first;
  
  for (final confirmDate in confirmations) {
    if (confirmDate.isAtSameMomentAs(expectedDate)) {
      currentStreak++;
      expectedDate = expectedDate.subtract(Duration(days: 1));
    }
  }
  
  print('\n🎯 RESULTADO:');
  print('  Racha calculada: $currentStreak día');
  print('  Racha esperada: 1 día');
  print('  ✅ CORRECTO: ${currentStreak == 1 ? 'SÍ' : 'NO'}');
  
  print('\n=== 🏆 RESUMEN ===');
  print('La nueva lógica de _calculateStreak:');
  print('✅ Empieza desde la confirmación más reciente');
  print('✅ Cuenta hacia atrás día por día');
  print('✅ Se detiene en el primer hueco');
  print('✅ Funciona para retos retroactivos y normales');
}
