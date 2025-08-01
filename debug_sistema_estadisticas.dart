void main() {
  print('🔍 === ANÁLISIS DEL SISTEMA DE ESTADÍSTICAS ===\n');
  
  // Simular datos de retos para analizar las estadísticas
  final retosSimulados = [
    {
      'id': 'ejercicio',
      'titulo': 'Ejercicio diario',
      'rachaActual': 5,
      'rachaMasLarga': 12,
      'ultimaConfirmacion': '2025-07-31',
      'historial': ['2025-07-27', '2025-07-28', '2025-07-29', '2025-07-30', '2025-07-31'],
      'puntosActuales': 150, // ¿Está bien calculado?
    },
    {
      'id': 'lectura',
      'titulo': 'Leer 30 minutos',
      'rachaActual': 3,
      'rachaMasLarga': 8,
      'ultimaConfirmacion': '2025-07-30',
      'historial': ['2025-07-28', '2025-07-29', '2025-07-30'],
      'puntosActuales': 45, // ¿Está bien calculado?
    },
    {
      'id': 'meditacion',
      'titulo': 'Meditación',
      'rachaActual': 0, // Racha rota
      'rachaMasLarga': 15,
      'ultimaConfirmacion': '2025-07-25',
      'historial': [], // Historial limpio después de fallo
      'puntosActuales': 300, // Puntos acumulados antes del fallo
    },
    {
      'id': 'estudio',
      'titulo': 'Estudiar',
      'rachaActual': 7,
      'rachaMasLarga': 7,
      'ultimaConfirmacion': '2025-07-31',
      'historial': ['2025-07-25', '2025-07-26', '2025-07-27', '2025-07-28', '2025-07-29', '2025-07-30', '2025-07-31'],
      'puntosActuales': 210, // ¿Está bien calculado?
    },
  ];
  
  print('📊 DATOS SIMULADOS DE RETOS:');
  print('═══════════════════════════\n');
  
  for (final reto in retosSimulados) {
    print('🎯 ${reto['titulo']}:');
    print('   📈 Racha actual: ${reto['rachaActual']} días');
    print('   🏆 Racha más larga: ${reto['rachaMasLarga']} días');
    print('   📅 Última confirmación: ${reto['ultimaConfirmacion']}');
    print('   📜 Días en historial: ${(reto['historial'] as List).length}');
    print('   ⭐ Puntos actuales: ${reto['puntosActuales']}');
    print('');
  }
  
  // CALCULAR ESTADÍSTICAS GLOBALES COMO LO HACE EL SISTEMA
  print('🧮 === CÁLCULO DE ESTADÍSTICAS GLOBALES ===\n');
  
  // 1. Total de desafíos
  final totalDesafios = retosSimulados.length;
  print('📋 Total de desafíos: $totalDesafios');
  
  // 2. Desafíos activos (con racha > 0)
  final desafiosActivos = retosSimulados.where((reto) => reto['rachaActual'] as int > 0).length;
  print('🔥 Desafíos activos: $desafiosActivos');
  
  // 3. Total de puntos
  final totalPuntos = retosSimulados
      .map((reto) => reto['puntosActuales'] as int)
      .fold<int>(0, (a, b) => a + b);
  print('⭐ Total de puntos: $totalPuntos');
  
  // 4. Promedio de racha (AQUÍ PUEDE ESTAR EL PROBLEMA)
  final promedioRacha = retosSimulados
      .map((reto) => reto['rachaActual'] as int)
      .fold<double>(0, (a, b) => a + b) / retosSimulados.length;
  print('📊 Promedio de racha: ${promedioRacha.toStringAsFixed(1)} días');
  
  // 5. Récord global (racha más larga de todos)
  final recordGlobal = retosSimulados
      .map((reto) => reto['rachaMasLarga'] as int)
      .fold<int>(0, (a, b) => a > b ? a : b);
  print('🏆 Récord global: $recordGlobal días');
  
  print('\n🔍 === ANÁLISIS DE PROBLEMAS POTENCIALES ===\n');
  
  // PROBLEMA 1: Verificar cálculo de puntos
  print('⚠️ PROBLEMA 1: Cálculo de puntos');
  print('═══════════════════════════════════');
  
  for (final reto in retosSimulados) {
    final titulo = reto['titulo'] as String;
    final rachaActual = reto['rachaActual'] as int;
    final historial = (reto['historial'] as List).cast<String>();
    final puntosActuales = reto['puntosActuales'] as int;
    
    // Calcular puntos esperados según la fórmula: 10 + (racha * 2) por cada confirmación
    int puntosEsperados = 0;
    for (int i = 1; i <= historial.length; i++) {
      puntosEsperados += 10 + (i * 2); // 10 base + 2 por día de racha
    }
    
    print('$titulo:');
    print('  Puntos actuales: $puntosActuales');
    print('  Puntos esperados: $puntosEsperados');
    print('  ¿Coincide? ${puntosActuales == puntosEsperados ? "✅ SÍ" : "❌ NO - PROBLEMA"}');
    
    if (puntosActuales != puntosEsperados) {
      print('  🔍 Diferencia: ${puntosActuales - puntosEsperados}');
    }
    print('');
  }
  
  // PROBLEMA 2: Verificar lógica del promedio
  print('⚠️ PROBLEMA 2: Lógica del promedio');
  print('═══════════════════════════════════');
  print('Rachas individuales: ${retosSimulados.map((r) => r['rachaActual']).join(', ')}');
  print('Suma total: ${retosSimulados.map((r) => r['rachaActual'] as int).fold(0, (a, b) => a + b)}');
  print('Cantidad de retos: ${retosSimulados.length}');
  print('Promedio calculado: ${promedioRacha.toStringAsFixed(1)}');
  print('');
  print('🤔 ¿Es lógico incluir retos con racha 0 en el promedio?');
  print('   - Incluir racha 0: Refleja realidad actual ✅');
  print('   - Excluir racha 0: Solo retos activos ❓');
  
  // Calcular promedio alternativo solo de retos activos
  final retosConRacha = retosSimulados.where((reto) => reto['rachaActual'] as int > 0);
  if (retosConRacha.isNotEmpty) {
    final promedioSoloActivos = retosConRacha
        .map((reto) => reto['rachaActual'] as int)
        .fold<double>(0, (a, b) => a + b) / retosConRacha.length;
    print('📊 Promedio solo activos: ${promedioSoloActivos.toStringAsFixed(1)} días');
  }
  
  // PROBLEMA 3: Verificar consistencia de "activos"
  print('\n⚠️ PROBLEMA 3: Definición de "activos"');
  print('═══════════════════════════════════');
  print('Retos con racha > 0: $desafiosActivos de $totalDesafios');
  
  for (final reto in retosSimulados) {
    final titulo = reto['titulo'] as String;
    final rachaActual = reto['rachaActual'] as int;
    final ultimaConfirmacion = reto['ultimaConfirmacion'] as String;
    final esActivo = rachaActual > 0;
    
    print('$titulo: ${esActivo ? "🔥 ACTIVO" : "💔 INACTIVO"} (racha: $rachaActual, última: $ultimaConfirmacion)');
  }
  
  print('\n💡 === RECOMENDACIONES ===');
  print('═══════════════════════════');
  print('1. ✅ Verificar fórmula de puntos en confirmChallenge()');
  print('2. 🤔 Considerar si promedio debe incluir rachas en 0');
  print('3. 📊 Agregar más contexto a las estadísticas');
  print('4. 🎯 Mostrar fecha de última actividad');
  print('5. 📈 Considerar tendencia (subiendo/bajando)');
  
  print('\n🔧 === ESTADÍSTICAS MEJORADAS SUGERIDAS ===');
  print('════════════════════════════════════════════');
  print('📋 Total: $totalDesafios retos');
  print('🔥 Activos: $desafiosActivos retos (${(desafiosActivos / totalDesafios * 100).toStringAsFixed(0)}%)');
  print('⭐ Puntos: $totalPuntos pts');
  print('📊 Promedio: ${promedioRacha.toStringAsFixed(1)}d (todos) | ${retosConRacha.isNotEmpty ? retosConRacha.map((r) => r['rachaActual'] as int).fold<double>(0, (a, b) => a + b) / retosConRacha.length : 0}d (activos)');
  print('🏆 Récord: $recordGlobal días');
  
  print('\n✅ Análisis completado - Revisa los problemas identificados');
}
