// 🧪 TEST ESPECÍFICO: CONFIRMACIÓN DESPUÉS DE RETO RETROACTIVO
// Archivo: test_confirmacion_despues_retroactivo.dart

void main() {
  print('=== 🔍 TEST: CONFIRMACIÓN DESPUÉS DE RETO RETROACTIVO ===\n');
  
  testEscenarioCompleto();
}

void testEscenarioCompleto() {
  print('🎯 ESCENARIO COMPLETO: Reto retroactivo + Confirmación HOY');
  
  // PASO 1: Usuario crea reto retroactivo
  print('\n📅 PASO 1: Creación de reto retroactivo');
  
  final today = DateTime(2025, 7, 30);
  final startDate = DateTime(2025, 7, 27); // 3 días atrás
  final daysToGrant = 3;
  
  print('  • Hoy: ${today.day}/${today.month}');
  print('  • Fecha inicio: ${startDate.day}/${startDate.month}');
  print('  • Días a otorgar: $daysToGrant');
  
  // Crear historial retroactivo (igual que grantBackdatedStreak)
  final backdatedHistory = <DateTime>[];
  for (int i = 0; i < daysToGrant; i++) {
    final confirmDate = startDate.add(Duration(days: i));
    backdatedHistory.add(confirmDate);
  }
  
  print('  • Historial retroactivo: ${backdatedHistory.map((d) => '${d.day}/${d.month}').join(', ')}');
  
  // Calcular racha inicial (igual que grantBackdatedStreak)
  final initialStreak = calculateStreakForHistory(backdatedHistory);
  print('  • Racha inicial calculada: $initialStreak días');
  
  // PASO 2: Usuario confirma HOY
  print('\n📅 PASO 2: Confirmación de HOY');
  
  // Agregar confirmación de hoy (igual que confirmChallenge)
  final newHistory = [...backdatedHistory, today];
  print('  • Nuevo historial: ${newHistory.map((d) => '${d.day}/${d.month}').join(', ')}');
  
  // Recalcular racha (igual que confirmChallenge)
  final newStreak = calculateStreakForHistory(newHistory);
  print('  • Nueva racha calculada: $newStreak días');
  
  // ANÁLISIS
  print('\n🔍 ANÁLISIS:');
  print('  • Racha antes de confirmar HOY: $initialStreak días');
  print('  • Racha después de confirmar HOY: $newStreak días');
  print('  • Diferencia: ${newStreak - initialStreak} días');
  
  if (newStreak == initialStreak + 1) {
    print('  ✅ CORRECTO: La racha aumentó en 1 día (confirmación de HOY)');
  } else if (newStreak == initialStreak) {
    print('  ⚠️ PROBLEMA: La racha no aumentó (algo está mal)');
  } else if (newStreak < initialStreak) {
    print('  ❌ ERROR GRAVE: La racha disminuyó (bug serio)');
  } else {
    print('  ❓ EXTRAÑO: La racha aumentó más de 1 día');
  }
  
  // VERIFICACIÓN DETALLADA
  print('\n🧮 VERIFICACIÓN DETALLADA:');
  print('Historial esperado para racha de ${daysToGrant + 1} días:');
  print('  27/07 → 28/07 → 29/07 → 30/07 (4 días consecutivos)');
  
  if (newStreak == daysToGrant + 1) {
    print('  ✅ RESULTADO ESPERADO CORRECTO');
  } else {
    print('  ❌ RESULTADO INCORRECTO - HAY UN BUG');
  }
}

// Simular la lógica de _calculateStreak
int calculateStreakForHistory(List<DateTime> confirmationHistory) {
  if (confirmationHistory.isEmpty) return 0;
  
  // Obtener confirmaciones únicas
  final uniqueConfirmations = <DateTime>{};
  for (final confirmation in confirmationHistory) {
    final normalizedDate = DateTime(confirmation.year, confirmation.month, confirmation.day);
    uniqueConfirmations.add(normalizedDate);
  }
  
  final sortedConfirmations = uniqueConfirmations.toList();
  sortedConfirmations.sort((a, b) => b.compareTo(a)); // Más reciente primero
  
  print('    Confirmaciones ordenadas: ${sortedConfirmations.map((d) => '${d.day}/${d.month}').join(', ')}');
  
  int currentStreak = 0;
  DateTime expectedDate = sortedConfirmations.first;
  
  print('    Empezando desde: ${expectedDate.day}/${expectedDate.month}');
  
  for (final confirmDate in sortedConfirmations) {
    print('    🔍 Verificando: ${confirmDate.day}/${confirmDate.month} vs ${expectedDate.day}/${expectedDate.month}');
    
    if (confirmDate.isAtSameMomentAs(expectedDate)) {
      currentStreak++;
      expectedDate = expectedDate.subtract(Duration(days: 1));
      print('    ✅ Racha: $currentStreak, siguiente: ${expectedDate.day}/${expectedDate.month}');
    } else {
      print('    ❌ Hueco detectado, parar');
      break;
    }
  }
  
  return currentStreak;
}
