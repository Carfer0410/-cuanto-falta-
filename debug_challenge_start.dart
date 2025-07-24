void main() {
  // Simular creación de un reto hoy
  final now = DateTime.now();
  print('Hora actual: $now');
  
  // Esto es lo que debería hacer el código para inicializar challengeStartedAt
  final challengeStartedAt = DateTime(now.year, now.month, now.day);
  print('challengeStartedAt calculado: $challengeStartedAt');
  
  // Calcular diferencia
  final difference = now.difference(challengeStartedAt);
  print('Diferencia: ${difference.inHours} horas, ${difference.inMinutes.remainder(60)} minutos');
  
  // Test: ¿es medianoche?
  final isExactMidnight = challengeStartedAt.hour == 0 && 
                          challengeStartedAt.minute == 0 && 
                          challengeStartedAt.second == 0 &&
                          challengeStartedAt.millisecond == 0;
  
  print('¿Es medianoche exacta? $isExactMidnight');
  print('Componentes de challengeStartedAt:');
  print('  Año: ${challengeStartedAt.year}');
  print('  Mes: ${challengeStartedAt.month}');
  print('  Día: ${challengeStartedAt.day}');
  print('  Hora: ${challengeStartedAt.hour}');
  print('  Minuto: ${challengeStartedAt.minute}');
  print('  Segundo: ${challengeStartedAt.second}');
  print('  Milisegundo: ${challengeStartedAt.millisecond}');
  
  // Verificar que el cronómetro muestre las horas transcurridas del día
  final expectedDuration = now.difference(challengeStartedAt);
  final displayHours = expectedDuration.inHours;
  final displayMinutes = expectedDuration.inMinutes.remainder(60);
  
  print('\n📊 RESULTADO ESPERADO DEL CRONÓMETRO:');
  print('Duración transcurrida: $displayHours horas, $displayMinutes minutos');
  print('(Esto DEBE coincidir con el tiempo que ha pasado desde medianoche)');
}
