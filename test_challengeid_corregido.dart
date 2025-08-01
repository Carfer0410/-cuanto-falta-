void main() async {
  print('🧪 === TEST CORRECCIÓN CHALLENGEID ===');
  
  // Simular el flujo CORREGIDO
  
  // 1. Lista existente de counters
  List<dynamic> existingCounters = [
    {'title': 'ejercicio'},
    {'title': 'leer'},
  ];
  
  print('1️⃣ Estado inicial:');
  print('   Counters existentes: ${existingCounters.length}');
  print('   Índices: 0="ejercicio", 1="leer"');
  
  // 2. Agregar nuevo counter
  final newCounter = {'title': 'meditar'};
  existingCounters.add(newCounter);
  
  print('\n2️⃣ Después de agregar nuevo counter:');
  print('   Counters totales: ${existingCounters.length}');
  print('   Índices: 0="ejercicio", 1="leer", 2="meditar"');
  
  // 3. Generar challengeId CORREGIDO
  final challengeId = 'challenge_${existingCounters.length - 1}'; // Ahora usa length - 1
  
  print('\n3️⃣ ChallengeId generado:');
  print('   Fórmula: challenge_\${list.length - 1}');
  print('   Cálculo: challenge_\${${existingCounters.length} - 1}');
  print('   Resultado: $challengeId');
  
  // 4. Verificar coincidencia con UI
  final uiIndex = 2; // El nuevo counter está en posición 2
  final uiChallengeId = 'challenge_$uiIndex';
  
  print('\n4️⃣ Verificación con UI:');
  print('   Índice del nuevo counter en UI: $uiIndex');
  print('   ChallengeId que busca la UI: $uiChallengeId');
  print('   ChallengeId guardado en streak: $challengeId');
  print('   ¿Coinciden?: ${challengeId == uiChallengeId ? "✅ SÍ" : "❌ NO"}');
  
  if (challengeId == uiChallengeId) {
    print('\n🎉 ¡CORRECCIÓN EXITOSA!');
    print('   La UI ahora encontrará la racha correctamente');
  } else {
    print('\n❌ AÚN HAY PROBLEMA');
    print('   La UI seguirá sin encontrar la racha');
  }
  
  print('\n📋 Para probar:');
  print('1. Crea un reto retroactivo');
  print('2. Verifica en los logs que se crea con challengeId correcto');
  print('3. La racha debería aparecer inmediatamente en la UI');
}
