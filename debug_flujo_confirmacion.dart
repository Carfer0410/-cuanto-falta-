void main() {
  print('=== ANÁLISIS COMPLETO DEL FLUJO DE CONFIRMACIÓN ===\n');
  
  // ========== ESCENARIO REAL ==========
  print('🎯 ESCENARIO REAL DEL USUARIO:');
  print('  • Reto creado: 20/07/2025');
  print('  • Días transcurridos hasta HOY (22/07): 3 días'); 
  print('  • Reto es RETROACTIVO (ya había días pasados cuando lo creó)');
  print('  • Racha mostrada ANTES de confirmar: 2 días');
  print('  • ❌ PROBLEMA: Al confirmar HOY, la racha BAJÓ en lugar de subir\n');
  
  // ========== ANÁLISIS MATEMÁTICO ==========
  print('📊 ANÁLISIS MATEMÁTICO:');
  print('  Si el reto se creó el 20/07 y estamos a 22/07:');
  print('  ✅ 20/07: Día 1 del reto');
  print('  ✅ 21/07: Día 2 del reto'); 
  print('  ✅ 22/07: Día 3 del reto (HOY)');
  print('  📈 Racha esperada después de confirmar: 3 días\n');
  
  // ========== HIPÓTESIS DEL BUG ==========
  print('🔍 HIPÓTESIS DEL BUG:');
  print('  1. ¿Está el confirmChallenge() borrando confirmaciones previas?');
  print('  2. ¿Hay algún reset que esté limpiando el historial?');
  print('  3. ¿El botón está llamando a failChallenge() en lugar de confirmChallenge()?');
  print('  4. ¿Hay conflicto entre sistema de contadores y sistema de rachas?\n');
  
  // ========== SIMULACIÓN DEL ESTADO ANTES ==========
  print('💾 ESTADO ANTES DE CONFIRMAR (racha = 2 días):');
  final historialAntes = [
    DateTime(2025, 7, 20), // Confirmación retroactiva día 1
    DateTime(2025, 7, 21), // Confirmación retroactiva día 2
  ];
  
  print('  Confirmaciones existentes:');
  for (final conf in historialAntes) {
    print('    - ${conf.day}/${conf.month}: ✅');
  }
  print('  Racha calculada: ${calcularRacha(historialAntes)} días\n');
  
  // ========== SIMULACIÓN DE CONFIRMAR HOY ==========
  print('⚡ SIMULACIÓN: Confirmar el 22/07 (HOY)');
  final hoy = DateTime(2025, 7, 22);
  final historialDespues = [...historialAntes, hoy];
  
  print('  Confirmaciones después de agregar HOY:');
  for (final conf in historialDespues) {
    print('    - ${conf.day}/${conf.month}: ✅');
  }
  final rachaDespues = calcularRacha(historialDespues);
  print('  Racha calculada: $rachaDespues días');
  
  if (rachaDespues > 2) {
    print('  ✅ CORRECTO: La racha debería SUBIR a $rachaDespues días');
  } else {
    print('  ❌ BUG REPRODUCIDO: La racha no sube como esperado');
  }
  
  print('\n=== CONCLUSIÓN ===');
  print('El algoritmo de cálculo es correcto.');
  print('El problema debe estar en:');
  print('  1. La función confirmChallenge() está haciendo algo inesperado');
  print('  2. El botón no está llamando a confirmChallenge()'); 
  print('  3. Hay algún reset/limpieza que borra el historial');
  print('  4. Conflicto de sincronización con otros sistemas');
}

int calcularRacha(List<DateTime> confirmaciones) {
  if (confirmaciones.isEmpty) return 0;
  
  // Ordenar de más reciente a más antiguo
  final sorted = [...confirmaciones];
  sorted.sort((a, b) => b.compareTo(a));
  
  final hoy = DateTime(2025, 7, 22);
  int racha = 0;
  DateTime? esperada = DateTime(hoy.year, hoy.month, hoy.day);
  
  for (final conf in sorted) {
    final fechaConf = DateTime(conf.year, conf.month, conf.day);
    
    if (esperada != null && fechaConf.isAtSameMomentAs(esperada)) {
      racha++;
      esperada = esperada.subtract(Duration(days: 1));
    } else if (racha == 0) {
      // Primera confirmación no es de hoy, empezar desde ahí
      racha = 1;
      esperada = fechaConf.subtract(Duration(days: 1));
    } else {
      // Hueco en racha, parar
      break;
    }
  }
  
  return racha;
}
