void main() async {
  print('🧪 === PRUEBA DE RACHA INMEDIATA ===');
  
  // Simular cálculo de días como en la app
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  // Casos de prueba
  final casos = [
    {'fecha': '28-07-2025', 'esperado': 3}, // 28, 29, 30
    {'fecha': '29-07-2025', 'esperado': 2}, // 29, 30
    {'fecha': '30-07-2025', 'esperado': 1}, // 30
    {'fecha': '25-07-2025', 'esperado': 6}, // 25, 26, 27, 28, 29, 30
  ];
  
  print('📅 Fecha actual: ${today.day}/${today.month}/${today.year}');
  print('');
  
  for (final caso in casos) {
    final fechaParts = caso['fecha'].toString().split('-');
    final startDate = DateTime(
      int.parse(fechaParts[2]), 
      int.parse(fechaParts[1]), 
      int.parse(fechaParts[0])
    );
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    
    // CÁLCULO CORREGIDO (inclusivo)
    final daysPassed = today.difference(start).inDays + 1;
    final esperado = caso['esperado'] as int;
    
    final esito = daysPassed == esperado ? '✅' : '❌';
    
    print('🧪 Fecha inicio: ${caso['fecha']}');
    print('   Días calculados: $daysPassed');
    print('   Días esperados: $esperado');
    print('   Resultado: $esito ${daysPassed == esperado ? 'CORRECTO' : 'INCORRECTO'}');
    print('');
  }
  
  print('🎯 Instrucciones para probar:');
  print('1. Abre la app');
  print('2. Crea un nuevo reto');
  print('3. Selecciona fecha del 28 de julio');
  print('4. Guarda el reto');
  print('5. En el diálogo, selecciona "Sí, todos los días"');
  print('6. Deberías ver inmediatamente "3 días cumplidos"');
  print('');
  print('✅ Si ves 3 días, la corrección funciona!');
}
