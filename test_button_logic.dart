void main() {
  print('=== SIMULANDO LÓGICA DEL BOTÓN ===');
  
  // Simular tu situación del 22 julio
  final now = DateTime(2025, 7, 22, 10, 30); // 22 julio a las 10:30 AM
  
  // Simular counter con confirmaciones previas
  DateTime? lastConfirmedDate = DateTime(2025, 7, 21); // Confirmado ayer
  DateTime? challengeStartedAt = DateTime(2025, 7, 20); // Iniciado el 20
  
  print('Ahora: $now');
  print('Última confirmación: $lastConfirmedDate');
  print('Reto iniciado: $challengeStartedAt');
  
  // Función _isSameDay simulada
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  print('\n=== EVALUANDO CONDICIONES ===');
  
  // Condición 1: ¿Reto iniciado?
  bool isStarted = true;
  print('1. ¿Reto iniciado? $isStarted');
  
  if (isStarted) {
    // Condición 2: ¿No confirmado hoy?
    bool notConfirmedToday = !isSameDay(lastConfirmedDate, now);
    
    print('2a. ¿Tiene confirmación previa? true');
    print('2b. ¿Última confirmación fue hoy? ${isSameDay(lastConfirmedDate, now)}');
    print('2c. ¿NO confirmado hoy? $notConfirmedToday');
    
    if (notConfirmedToday) {
      print('\n✅ RESULTADO: DEBERÍA MOSTRAR "¿Cumpliste hoy?"');
    } else if (isSameDay(lastConfirmedDate, now)) {
      print('\n✅ RESULTADO: DEBERÍA MOSTRAR "¡Completado hoy!"');
    } else {
      print('\n❓ RESULTADO: CASO NO CONTEMPLADO');
    }
  // ignore: dead_code
  } else {
  }
  
  print('\n=== PROBANDO A DIFERENTES HORAS ===');
  for (int hour in [0, 6, 12, 18, 23]) {
    final testTime = DateTime(2025, 7, 22, hour, 0);
    final shouldShow = !isSameDay(lastConfirmedDate, testTime);
    print('A las ${hour.toString().padLeft(2, '0')}:00 → Mostrar botón: $shouldShow');
  }
}
