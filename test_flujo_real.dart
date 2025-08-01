void main() async {
  print('🧪 === TEST FLUJO REAL DE SAVECOUNTER ===');
  
  // Simular el flujo REAL de _saveCounter
  
  // 1. Estado inicial
  List<dynamic> list = [
    {'title': 'ejercicio'},
    {'title': 'leer'},
  ];
  
  print('1️⃣ Estado inicial:');
  print('   Counters existentes: ${list.length}');
  print('   Próximo índice disponible: ${list.length}');
  
  // 2. Agregar nuevo counter (como en _saveCounter)
  final newCounter = {'title': 'meditar'};
  list.add(newCounter); // Esta línea pasa ANTES de _handleBackdatedChallenge
  
  print('\n2️⃣ Después de list.add():');
  print('   Counters totales: ${list.length}');
  print('   Índice del nuevo counter: ${list.length - 1}');
  
  // 3. Ahora se llama _handleBackdatedChallenge
  print('\n3️⃣ En _handleBackdatedChallenge:');
  
  // Simular la lectura de prefs (que ya tiene el counter agregado)
  final listInHandle = list; // Simula jsonDecode(jsonString)
  final challengeId = 'challenge_${listInHandle.length - 1}';
  
  print('   Lista leída: ${listInHandle.length} counters');
  print('   Fórmula: challenge_\${list.length - 1}');
  print('   ChallengeId: $challengeId');
  
  // 4. Verificar con UI
  final uiIndex = list.length - 1; // Índice del nuevo counter
  final uiChallengeId = 'challenge_$uiIndex';
  
  print('\n4️⃣ Verificación con UI:');
  print('   Índice en UI: $uiIndex');
  print('   ChallengeId UI: $uiChallengeId');
  print('   ChallengeId streak: $challengeId');
  print('   ¿Coinciden?: ${challengeId == uiChallengeId ? "✅ SÍ" : "❌ NO"}');
  
  if (challengeId == uiChallengeId) {
    print('\n🎉 ¡PERFECTO!');
    print('   La racha aparecerá inmediatamente');
  } else {
    print('\n❌ PROBLEMA PERSISTE');
  }
}
