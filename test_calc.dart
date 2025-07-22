void main() {
  final start = DateTime(2025, 7, 18);
  final today = DateTime(2025, 7, 21);
  final daysPassed = today.difference(start).inDays;
  
  print('Inicio: $start');
  print('Hoy: $today');
  print('Días pasados: $daysPassed');
  
  // Probar diferentes interpretaciones:
  print('\nAnálisis detallado:');
  print('18 julio → 19 julio = 1 día cumplido');
  print('19 julio → 20 julio = 2 días cumplidos');  
  print('20 julio → 21 julio = 3 días cumplidos');
  print('Resultado esperado: 3 días de racha');
}
