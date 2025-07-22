void main() {
  print('=== DEBUG CONFIRMACIÓN RETROACTIVA ===');
  
  // Simular el estado ANTES de confirmar hoy
  final confirmationHistory = [
    DateTime(2025, 7, 20), // Día 1 retroactivo
    DateTime(2025, 7, 21), // Día 2 retroactivo
  ];
  
  print('Estado ANTES de confirmar hoy:');
  print('Confirmaciones: ${confirmationHistory.map((d) => '${d.day}/${d.month}').join(', ')}');
  print('Racha esperada: 2 días');
  
  // Simular agregar confirmación de HOY
  final newConfirmation = DateTime(2025, 7, 22);
  final newHistory = [...confirmationHistory, newConfirmation];
  
  print('\nDespués de confirmar HOY (22 julio):');
  print('Confirmaciones: ${newHistory.map((d) => '${d.day}/${d.month}').join(', ')}');
  
  // Simular el cálculo de racha (_calculateStreak)
  final sortedConfirmations = [...newHistory];
  sortedConfirmations.sort((a, b) => b.compareTo(a)); // Más reciente primero
  
  print('\nConfirmaciones ordenadas (más reciente primero):');
  for (final conf in sortedConfirmations) {
    print('  - ${conf.day}/${conf.month}/${conf.year}');
  }
  
  final today = DateTime(2025, 7, 22, 0, 0, 0);
  int currentStreak = 0;
  DateTime? expectedDate = DateTime(today.year, today.month, today.day);
  
  print('\nCálculo paso a paso:');
  print('Empezando desde hoy: ${expectedDate!.day}/${expectedDate.month}');
  
  for (final confirmation in sortedConfirmations) {
    final confirmDate = DateTime(confirmation.year, confirmation.month, confirmation.day);
    
    print('\nVerificando confirmación: ${confirmDate.day}/${confirmDate.month}');
    print('  Esperada: ${expectedDate!.day}/${expectedDate.month}');
    print('  ¿Coincide? ${confirmDate.isAtSameMomentAs(expectedDate)}');
    
    if (expectedDate != null && confirmDate.isAtSameMomentAs(expectedDate)) {
      currentStreak++;
      expectedDate = expectedDate.subtract(Duration(days: 1));
      print('  ✅ Racha aumenta a: $currentStreak');
      print('  Siguiente esperada: ${expectedDate.day}/${expectedDate.month}');
    } else if (currentStreak == 0) {
      // Si es la primera confirmación pero no es de hoy, empezar racha desde ahí
      currentStreak = 1;
      expectedDate = confirmDate.subtract(Duration(days: 1));
      print('  🔄 Primera confirmación no es hoy, empezar desde aquí: $currentStreak');
      print('  Siguiente esperada: ${expectedDate.day}/${expectedDate.month}');
    } else {
      // Hueco en la racha, parar
      print('  ❌ Hueco en la racha, parar');
      break;
    }
  }
  
  print('\n=== RESULTADO FINAL ===');
  print('Racha calculada: $currentStreak días');
  print('Racha esperada: 3 días');
  print(currentStreak == 3 ? '✅ CORRECTO' : '❌ INCORRECTO - HAY UN BUG');
}
