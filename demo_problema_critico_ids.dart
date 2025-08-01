void main() {
  print('🚨 === DEMOSTRACIÓN DEL PROBLEMA CRÍTICO: SISTEMA DE IDs ===');
  print('');

  print('📋 ESCENARIO: Usuario tiene 3 retos y elimina el del medio');
  print('');

  // Estado inicial
  List<String> counters = ['Ejercicio', 'Lectura', 'Meditación'];
  Map<String, int> streaks = {
    'challenge_0': 5, // Ejercicio - 5 días
    'challenge_1': 3, // Lectura - 3 días  
    'challenge_2': 7, // Meditación - 7 días
  };

  print('🏁 ESTADO INICIAL:');
  for (int i = 0; i < counters.length; i++) {
    final challengeId = 'challenge_$i';
    print('   [$i] "${counters[i]}" → $challengeId (racha: ${streaks[challengeId]} días)');
  }
  print('');

  // Usuario elimina "Lectura" (índice 1)
  print('❌ ACCIÓN: Usuario elimina "${counters[1]}" (índice 1)');
  counters.removeAt(1);
  print('');

  print('🔄 ESTADO DESPUÉS DE ELIMINAR:');
  print('   Counters restantes: $counters');
  print('   Pero streaks sigue igual: ${streaks.keys.toList()}');
  print('');

  print('🚨 PROBLEMA: Los IDs ya no coinciden:');
  for (int i = 0; i < counters.length; i++) {
    final challengeId = 'challenge_$i';
    final actualStreakKey = 'challenge_${i == 0 ? 0 : i + 1}'; // El ID real que debería tener
    
    print('   [$i] "${counters[i]}"');
    print('       → UI busca: $challengeId');
    print('       → Streak real: $actualStreakKey');
    print('       → Racha mostrada: ${streaks[challengeId] ?? 'NO ENCONTRADA'}');
    print('       → Racha real: ${streaks[actualStreakKey]}');
    print('       → ¿Coincide?: ${challengeId == actualStreakKey ? "✅" : "❌ NO"}');
    print('');
  }

  print('💥 CONSECUENCIAS:');
  print('   1. "Ejercicio" ahora busca challenge_0 ✅ (correcto)');
  print('   2. "Meditación" ahora busca challenge_1 ❌ (debería ser challenge_2)');
  print('   3. "Meditación" mostrará racha de 3 días en lugar de 7 días');
  print('   4. Los datos de challenge_2 (7 días) quedan huérfanos');
  print('');

  print('🔧 === SOLUCIONES PROPUESTAS ===');
  print('');

  print('💡 SOLUCIÓN 1: UUID permanente');
  print('   • Agregar campo "uuid" a Counter');
  print('   • Generar UUID al crear reto: uuid.v4()');
  print('   • Usar UUID como challengeId en lugar del índice');
  print('   • UUID nunca cambia aunque se reordene la lista');
  print('');

  print('💡 SOLUCIÓN 2: Reindexar streaks al eliminar');
  print('   • Al eliminar reto en índice X, mover todos los streaks posteriores');
  print('   • challenge_2 → challenge_1, challenge_3 → challenge_2, etc.');
  print('   • Más complejo pero mantiene compatibilidad actual');
  print('');

  print('💡 SOLUCIÓN 3: Sistema híbrido');
  print('   • Mantener challengeId basado en timestamp de creación');
  print('   • Ej: challenge_1643723400000 (timestamp)');
  print('   • Más legible que UUID pero único temporalmente');
  print('');

  print('🎯 RECOMENDACIÓN: Solución 1 (UUID)');
  print('   ✅ Más robusta y escalable');
  print('   ✅ Evita completamente problemas de reordenamiento');
  print('   ✅ Estándar en desarrollo de software');
  print('   ✅ Fácil de implementar con package:uuid');
  print('');

  print('📝 EJEMPLO DE IMPLEMENTACIÓN:');
  print('''
// 1. Agregar uuid dependency en pubspec.yaml
dependencies:
  uuid: ^4.0.0

// 2. Modificar Counter class
class Counter {
  final String uuid; // 🆕 NUEVO CAMPO
  final String title;
  // ... otros campos

  Counter({
    String? uuid, // Opcional para retrocompatibilidad
    required this.title,
    // ... otros parámetros
  }) : uuid = uuid ?? Uuid().v4(); // Generar si no existe
}

// 3. Usar UUID como challengeId
String _getChallengeId(int index) {
  return _counters[index].uuid; // En lugar de 'challenge_\$index'
}
''');

  print('⚠️ MIGRACIÓN SUGERIDA:');
  print('   1. Agregar campo uuid a retos existentes');
  print('   2. Mapear challengeIds actuales a UUIDs');
  print('   3. Actualizar todas las referencias en IndividualStreakService');
  print('   4. Mantener fallback para retos sin UUID (por si acaso)');
}
