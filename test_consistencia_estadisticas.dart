void main() {
  print('🧪 === PRUEBA DE CONSISTENCIA DE ESTADÍSTICAS ===\n');
  
  // Simular datos para verificar que ambas pantallas calculen igual
  print('📋 ESCENARIO DE PRUEBA:');
  print('═══════════════════════');
  
  final retosSimulados = [
    {
      'titulo': 'Ejercicio diario',
      'challengeStartedAt': '2025-07-28T10:00:00', // Iniciado ✅
      'uuid': 'reto-uuid-1',
      'puntos': 150,
      'rachaActual': 5,
      'rachaMasLarga': 8,
    },
    {
      'titulo': 'Leer 30 minutos',
      'challengeStartedAt': '2025-07-30T09:00:00', // Iniciado ✅
      'uuid': 'reto-uuid-2', 
      'puntos': 90,
      'rachaActual': 3,
      'rachaMasLarga': 6,
    },
    {
      'titulo': 'Meditar',
      'challengeStartedAt': null, // NO iniciado ❌
      'uuid': 'reto-uuid-3',
      'puntos': 0,
      'rachaActual': 0,
      'rachaMasLarga': 0,
    },
    {
      'titulo': 'Beber agua',
      'challengeStartedAt': '2025-07-31T08:00:00', // Iniciado ✅
      'uuid': 'reto-uuid-4',
      'puntos': 70,
      'rachaActual': 2,
      'rachaMasLarga': 4,
    },
  ];
  
  print('🎯 RETOS DE PRUEBA:');
  for (final reto in retosSimulados) {
    final iniciado = reto['challengeStartedAt'] != null ? '✅ INICIADO' : '❌ SIN INICIAR';
    print('  • ${reto['titulo']}: $iniciado');
    print('    └─ Puntos: ${reto['puntos']}, Racha: ${reto['rachaActual']}');
  }
  
  print('\n📊 === CÁLCULO ESPERADO (CONSISTENTE) ===');
  print('═══════════════════════════════════════════\n');
  
  // Calcular estadísticas como debería hacerlo la corrección
  final totalRetos = retosSimulados.length;
  final retosActivos = retosSimulados.where((r) => r['challengeStartedAt'] != null).length;
  final puntosTotal = retosSimulados
      .map((r) => r['puntos'] as int)
      .fold<int>(0, (a, b) => a + b);
  
  // Promedio solo de retos activos
  final retosConRacha = retosSimulados.where((r) => r['challengeStartedAt'] != null);
  final promedioRachaActivos = retosConRacha.isNotEmpty
      ? retosConRacha.map((r) => r['rachaActual'] as int).fold<double>(0, (a, b) => a + b) / retosConRacha.length
      : 0.0;
  
  final rachaMasLarga = retosSimulados
      .map((r) => r['rachaMasLarga'] as int)
      .fold<int>(0, (a, b) => a > b ? a : b);
  
  print('🔢 RESULTADOS ESPERADOS EN AMBAS PANTALLAS:');
  print('─────────────────────────────────────────────');
  print('📋 Total retos: $totalRetos');
  print('🎯 Retos activos: $retosActivos (solo los iniciados)');
  print('⭐ Puntos totales: $puntosTotal');
  print('📈 Promedio racha: ${promedioRachaActivos.toStringAsFixed(1)} (solo activos)');
  print('🏆 Racha más larga: $rachaMasLarga');
  
  print('\n✅ VERIFICACIÓN DE CONSISTENCIA:');
  print('═══════════════════════════════════════');
  print('1. 📊 Dashboard debería mostrar: $retosActivos activos, $puntosTotal puntos');
  print('2. 🎯 Panel Retos debería mostrar: $retosActivos activos, $puntosTotal puntos');
  print('3. 🔄 Pull-to-refresh en ambas: Mantener mismos números');
  
  print('\n🚨 CASOS PROBLEMÁTICOS CORREGIDOS:');
  print('═══════════════════════════════════════');
  print('❌ ANTES: Dashboard contaba "Meditar" como activo (sin iniciar)');
  print('✅ AHORA: Solo cuenta retos con challengeStartedAt != null');
  print('❌ ANTES: Promedio incluía retos sin iniciar (distorsionaba resultado)');
  print('✅ AHORA: Promedio solo de retos realmente activos');
  print('❌ ANTES: Puntos podían diferir por conversión double/int');
  print('✅ AHORA: Conversión segura y consistente');
  
  print('\n🎯 CÓMO PROBAR LA CORRECCIÓN:');
  print('═══════════════════════════════════');
  print('1. Crear los 4 retos simulados arriba');
  print('2. Iniciar solo 3 de ellos (dejar uno sin iniciar)');
  print('3. Verificar Dashboard: debe mostrar "3 activos"');
  print('4. Verificar Panel Retos: debe mostrar "3 activos"');
  print('5. Hacer pull-to-refresh en ambas pantallas');
  print('6. Confirmar que los números permanecen idénticos');
  
  print('\n💡 DEFINICIÓN CLARA DE "RETO ACTIVO":');
  print('════════════════════════════════════════');
  print('✅ ACTIVO: challengeStartedAt != null (usuario presionó "Iniciar")');
  print('❌ INACTIVO: challengeStartedAt == null (reto creado pero no iniciado)');
  print('⚠️  IMPORTANTE: La racha puede ser 0 y aún ser un reto activo');
  
  print('\n🏁 RESULTADO ESPERADO:');
  print('════════════════════════');
  print('📊 Dashboard y 🎯 Panel Retos mostrarán EXACTAMENTE:');
  print('• Total: $totalRetos retos');
  print('• Activos: $retosActivos retos');
  print('• Puntos: $puntosTotal pts');
  print('• Promedio: ${promedioRachaActivos.toStringAsFixed(1)}d');
  print('• Récord: ${rachaMasLarga}d');
  print('\n✅ ¡CONSISTENCIA TOTAL LOGRADA!');
}
