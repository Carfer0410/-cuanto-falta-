void main() {
  print('=== SIMULACIÓN EXACTA DEL BUG ===\n');
  
  // ========== ESTADO INICIAL ==========
  print('🎯 ESTADO INICIAL (antes de confirmar hoy)');
  final estadoInicial = ChallengeStreak(
    challengeId: 'challenge_0',
    challengeTitle: 'Mi Reto',
    confirmationHistory: [
      DateTime(2025, 7, 20), // Confirmación retroactiva 1
      DateTime(2025, 7, 21), // Confirmación retroactiva 2
    ],
    currentStreak: 2, // La racha que ves en la UI
    lastConfirmedDate: DateTime(2025, 7, 21),
  );
  
  print('Confirmaciones existentes:');
  for (final conf in estadoInicial.confirmationHistory) {
    print('  - ${conf.day}/${conf.month}');
  }
  print('Racha actual: ${estadoInicial.currentStreak} días');
  print('isCompletedToday: ${estadoInicial.isCompletedToday}');
  print('');
  
  // ========== VERIFICAR SI PUEDE CONFIRMAR HOY ==========
  final hoy = DateTime(2025, 7, 22);
  final isCompletedToday = estadoInicial.lastConfirmedDate != null &&
      estadoInicial.lastConfirmedDate!.year == hoy.year &&
      estadoInicial.lastConfirmedDate!.month == hoy.month &&
      estadoInicial.lastConfirmedDate!.day == hoy.day;
  
  print('¿Ya confirmó hoy? $isCompletedToday');
  
  if (isCompletedToday) {
    print('❌ ERROR: El sistema detecta que ya confirmó hoy, no debe permitir confirmar');
    return;
  }
  
  print('✅ Puede confirmar hoy');
  print('');
  
  // ========== SIMULAR CONFIRMACIÓN ==========
  print('⚡ SIMULANDO CONFIRMACIÓN DEL 22/07');
  
  // Agregar confirmación al historial (EXACTAMENTE como lo hace confirmChallenge)
  final newHistory = [...estadoInicial.confirmationHistory, hoy];
  
  print('Nuevo historial de confirmaciones:');
  for (final conf in newHistory) {
    print('  - ${conf.day}/${conf.month}');
  }
  
  // Crear estado temporal para calcular racha
  final tempStreak = ChallengeStreak(
    challengeId: estadoInicial.challengeId,
    challengeTitle: estadoInicial.challengeTitle,
    confirmationHistory: newHistory,
    lastConfirmedDate: hoy,
    currentStreak: estadoInicial.currentStreak, // Esto se recalculará
  );
  
  // Calcular nueva racha (EXACTAMENTE como lo hace _calculateStreak)
  final newStreak = calculateStreak(tempStreak);
  
  print('Nueva racha calculada: $newStreak días');
  
  if (newStreak > estadoInicial.currentStreak) {
    print('✅ CORRECTO: La racha subió de ${estadoInicial.currentStreak} a $newStreak');
  } else if (newStreak == estadoInicial.currentStreak) {
    print('⚠️ NEUTRAL: La racha se mantuvo en $newStreak días');
  } else {
    print('❌ BUG REPRODUCIDO: La racha bajó de ${estadoInicial.currentStreak} a $newStreak');
    print('¡AQUÍ ESTÁ EL PROBLEMA!');
  }
}

// Copia exacta del algoritmo _calculateStreak
int calculateStreak(ChallengeStreak streak) {
  if (streak.confirmationHistory.isEmpty) return 0;
  
  final sortedConfirmations = [...streak.confirmationHistory];
  sortedConfirmations.sort((a, b) => b.compareTo(a)); // Más reciente primero
  
  final now = DateTime(2025, 7, 22); // Simular "hoy"
  final today = DateTime(now.year, now.month, now.day);
  int currentStreak = 0;
  DateTime? expectedDate = today;
  
  print('\n--- CÁLCULO PASO A PASO ---');
  print('Empezando desde: ${expectedDate!.day}/${expectedDate.month}');
  
  for (final confirmation in sortedConfirmations) {
    final confirmDate = DateTime(confirmation.year, confirmation.month, confirmation.day);
    
    print('Verificando: ${confirmDate.day}/${confirmDate.month}');
    print('  Esperada: ${expectedDate!.day}/${expectedDate.month}');
    print('  ¿Coincide? ${confirmDate.isAtSameMomentAs(expectedDate)}');
    
    // Si hay un fallo registrado para esta fecha, parar
    final hasFailed = streak.failedDays.any((failDate) {
      final failed = DateTime(failDate.year, failDate.month, failDate.day);
      return failed.isAtSameMomentAs(confirmDate);
    });
    
    if (hasFailed) {
      print('  ❌ Hay fallo registrado, parar');
      break;
    }
    
    // Si esta confirmación es para la fecha que esperamos, continuar racha
    if (expectedDate != null && confirmDate.isAtSameMomentAs(expectedDate)) {
      currentStreak++;
      expectedDate = expectedDate.subtract(Duration(days: 1));
      print('  ✅ Racha aumenta a: $currentStreak');
      print('  Siguiente esperada: ${expectedDate.day}/${expectedDate.month}');
    } else if (currentStreak == 0) {
      // Si es la primera confirmación pero no es de hoy, empezar racha desde ahí
      currentStreak = 1;
      expectedDate = confirmDate.subtract(Duration(days: 1));
      print('  🔄 Primera confirmación, empezar desde aquí: $currentStreak');
      print('  Siguiente esperada: ${expectedDate.day}/${expectedDate.month}');
    } else {
      // Hueco en la racha, parar
      print('  ❌ Hueco en la racha, parar');
      break;
    }
  }
  
  print('--- FIN CÁLCULO ---\n');
  return currentStreak;
}

class ChallengeStreak {
  final String challengeId;
  final String challengeTitle;
  final List<DateTime> confirmationHistory;
  final List<DateTime> failedDays;
  final int currentStreak;
  final DateTime? lastConfirmedDate;

  ChallengeStreak({
    required this.challengeId,
    required this.challengeTitle,
    this.confirmationHistory = const [],
    this.failedDays = const [],
    this.currentStreak = 0,
    this.lastConfirmedDate,
  });

  bool get isCompletedToday {
    if (lastConfirmedDate == null) return false;
    final today = DateTime.now();
    final lastConfirmed = lastConfirmedDate!;
    return lastConfirmed.year == today.year &&
           lastConfirmed.month == today.month &&
           lastConfirmed.day == today.day;
  }
}
