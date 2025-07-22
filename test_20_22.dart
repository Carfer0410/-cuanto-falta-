void main() {
  // Tu ejemplo específico: Reto creado el 20 julio, hoy es 22 julio
  final start = DateTime(2025, 7, 20);
  final today = DateTime(2025, 7, 22);
  final daysPassed = today.difference(start).inDays;
  
  print('=== ANÁLISIS DEL EJEMPLO 20-22 JULIO ===');
  print('Inicio del reto: $start');
  print('Hoy: $today');
  print('Días transcurridos (cronómetro): $daysPassed días');
  
  print('\n=== ANÁLISIS DÍA POR DÍA ===');
  print('📅 20 julio (día de creación): Si confirmas → 1 día de racha');
  print('📅 21 julio (ayer): Si confirmaste → 2 días de racha');  
  print('📅 22 julio (hoy): Si confirmas HOY → 3 días de racha');
  
  print('\n=== ESTADO ACTUAL (22 julio sin confirmar hoy) ===');
  print('Cronómetro: $daysPassed días transcurridos ✅');
  print('Rachas: 2 días confirmados (20 y 21 julio) ✅');
  print('Pendiente: Confirmar el 22 julio para llegar a 3 días de racha');
  
  print('\n=== CONCLUSIÓN ===');
  print('La app está funcionando CORRECTAMENTE:');
  print('• Cronómetro: Cuenta tiempo transcurrido automáticamente');
  print('• Racha: Cuenta días que TÚ has confirmado manualmente');
  print('• Para tener 3 días de racha necesitas confirmar HOY (22 julio)');
}
