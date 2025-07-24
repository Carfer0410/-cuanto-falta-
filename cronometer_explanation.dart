void main() {
  print('=== ANÁLISIS DEL FUNCIONAMIENTO DEL CRONÓMETRO ===\n');
  
  // Caso 1: Crear reto a medianoche (hora ideal)
  final midnight = DateTime(2025, 7, 24, 0, 0, 0); // Medianoche exacta
  final now = DateTime.now();
  
  print('🌙 CASO 1: Reto creado a medianoche');
  print('Hora de creación: $midnight');
  print('Hora actual: $now');
  final midnightDiff = now.difference(midnight);
  print('Cronómetro mostraría: ${midnightDiff.inHours}h ${midnightDiff.inMinutes.remainder(60)}m');
  print('');
  
  // Caso 2: Crear reto ahora (caso real del usuario)
  print('⏰ CASO 2: Reto creado ahora');
  print('Hora de creación: $now');
  final challengeStart = DateTime(now.year, now.month, now.day); // Medianoche del día actual
  print('challengeStartedAt (medianoche): $challengeStart');
  final actualDiff = now.difference(challengeStart);
  print('Cronómetro muestra: ${actualDiff.inHours}h ${actualDiff.inMinutes.remainder(60)}m');
  print('');
  
  print('📝 EXPLICACIÓN:');
  print('Un reto siempre empieza a contar desde medianoche del día que lo creas.');
  print('Si lo creas a las 1:02 PM, el cronómetro mostrará "13h 2m" porque');
  print('ya han pasado 13 horas y 2 minutos desde medianoche de ese día.');
  print('');
  print('✅ ESTO ES CORRECTO - El cronómetro cuenta el progreso del día completo,');
  print('   no desde la hora exacta de creación.');
  print('');
  print('🎯 PROPÓSITO: Permite que todos los retos del mismo día tengan');
  print('   el mismo tiempo base, sin importar a qué hora se crearon.');
  
  // Caso 3: Simular qué pasaría si empezáramos desde la hora actual
  print('');
  print('❌ Si empezáramos desde la hora actual:');
  print('- Reto A creado a las 8:00 AM mostraría menos tiempo');
  print('- Reto B creado a las 2:00 PM mostraría menos tiempo');
  print('- ¡Sería injusto! Los retos del mismo día tendrían tiempos diferentes.');
}
