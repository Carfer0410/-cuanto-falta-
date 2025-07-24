void main() {
  print('=== NUEVO COMPORTAMIENTO DEL CRONÓMETRO ===\n');
  
  // Simular creación de un reto
  final now = DateTime.now();
  print('🎯 ESCENARIO: Crear y iniciar un reto');
  print('Hora actual: $now');
  print('');
  
  // Paso 1: Crear reto (challengeStartedAt = null)
  DateTime? challengeStartedAt;
  print('📝 Paso 1: Crear reto');
  print('challengeStartedAt inicial: $challengeStartedAt (null = no iniciado)');
  print('Estado: Reto creado pero NO iniciado');
  print('');
  
  // Paso 2: Usuario presiona "Iniciar reto" (simulando 5 minutos después)
  final startTime = now.add(Duration(minutes: 5));
  challengeStartedAt = startTime;
  print('▶️ Paso 2: Usuario presiona "Iniciar reto"');
  print('Momento exacto de inicio: $challengeStartedAt');
  print('Estado: Cronómetro INICIADO');
  print('');
  
  // Paso 3: Ver cronómetro después de un tiempo (simulando 2 horas después)
  final checkTime = startTime.add(Duration(hours: 2, minutes: 30));
  final elapsed = checkTime.difference(challengeStartedAt);
  
  print('⏱️ Paso 3: Verificar cronómetro después de un tiempo');
  print('Hora de verificación: $checkTime');
  print('Tiempo transcurrido: ${elapsed.inHours}h ${elapsed.inMinutes.remainder(60)}m ${elapsed.inSeconds.remainder(60)}s');
  print('');
  
  print('✅ RESULTADO:');
  print('- El cronómetro cuenta exactamente desde que se presionó "Iniciar"');
  print('- No cuenta tiempo que transcurrió antes de iniciar el reto');
  print('- Es como un cronómetro real de ejercicio/actividad');
  print('');
  
  print('🎯 VENTAJAS:');
  print('- Cronómetro empieza en 00:00:00 cuando inicias');
  print('- Cuenta solo el tiempo activo del reto'); 
  print('- Más intuitivo y preciso para el usuario');
  print('- Perfecto para medir tiempo dedicado a la actividad');
}
