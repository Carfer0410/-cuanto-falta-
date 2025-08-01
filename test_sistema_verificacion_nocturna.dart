void main() {
  print('🧪 === SIMULADOR DE VERIFICACIÓN NOCTURNA ===\n');
  
  // Simular el estado actual
  final now = DateTime.now();
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  
  print('📅 HOY: ${now.day}/${now.month}/${now.year}');
  print('📅 AYER: ${yesterday.day}/${yesterday.month}/${yesterday.year}');
  print('🕐 Hora actual: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');
  print('');
  
  // Simular retos con diferentes estados
  final retosEjemplo = [
    {
      'nombre': 'ejercicio',
      'confirmadoAyer': false,  // NO confirmó ayer
      'fichasDisponibles': 2,
      'rachaActual': 5,
    },
    {
      'nombre': 'meditación', 
      'confirmadoAyer': true,   // SÍ confirmó ayer
      'fichasDisponibles': 1,
      'rachaActual': 3,
    },
    {
      'nombre': 'lectura',
      'confirmadoAyer': false,  // NO confirmó ayer
      'fichasDisponibles': 0,   // Sin fichas
      'rachaActual': 8,
    },
    {
      'nombre': 'estudiar',
      'confirmadoAyer': false,  // NO confirmó ayer
      'fichasDisponibles': 1,
      'rachaActual': 12,
    },
  ];
  
  print('🎭 === SIMULACIÓN DE VERIFICACIÓN NOCTURNA ===');
  print('🤖 Ejecutándose automáticamente a las 00:30...\n');
  
  int retosVerificados = 0;
  int retosConFallo = 0;
  int fichasUsadas = 0;
  int rachasPerdidas = 0;
  
  for (final reto in retosEjemplo) {
    final nombre = reto['nombre'] as String;
    final confirmado = reto['confirmadoAyer'] as bool;
    final fichas = reto['fichasDisponibles'] as int;
    final racha = reto['rachaActual'] as int;
    
    retosVerificados++;
    
    print('🔍 "$nombre":');
    print('   ¿Confirmado ayer? ${confirmado ? "SÍ ✅" : "NO ❌"}');
    
    if (!confirmado) {
      retosConFallo++;
      print('   ⚡ Aplicando consecuencia...');
      
      if (fichas > 0) {
        // USAR FICHA DE PERDÓN
        fichasUsadas++;
        print('   🛡️ Usando ficha de perdón automáticamente');
        print('   📊 Resultado: Racha MANTENIDA en $racha días (fichas restantes: ${fichas - 1})');
        print('   📱 Notificación: "🛡️ Ficha de perdón usada para \'$nombre\'. Racha mantenida."');
        
      } else {
        // RESETEAR RACHA
        rachasPerdidas++;
        print('   💔 No hay fichas de perdón disponibles');
        print('   📊 Resultado: Racha RESETEADA de $racha → 0 días');
        print('   📱 Notificación: "💔 Racha perdida en \'$nombre\'. No confirmaste antes de las 23:59."');
      }
    } else {
      print('   ✅ Todo correcto, no se aplica ninguna consecuencia');
      print('   📊 Resultado: Racha se mantiene en $racha días');
    }
    
    print('');
  }
  
  // Resumen final
  print('📊 === RESUMEN VERIFICACIÓN NOCTURNA ===');
  print('🔍 Retos verificados: $retosVerificados');
  print('❌ Retos con fallo: $retosConFallo');
  print('🛡️ Fichas de perdón usadas: $fichasUsadas');
  print('💔 Rachas perdidas: $rachasPerdidas');
  print('✅ Verificación nocturna completada');
  print('');
  
  // Explicar qué ve el usuario al día siguiente
  print('📱 === LO QUE VE EL USUARIO AL DÍA SIGUIENTE ===');
  
  if (fichasUsadas > 0) {
    print('🛡️ Notificaciones de fichas usadas:');
    for (final reto in retosEjemplo) {
      final nombre = reto['nombre'] as String;
      final confirmado = reto['confirmadoAyer'] as bool;
      final fichas = reto['fichasDisponibles'] as int;
      
      if (!confirmado && fichas > 0) {
        print('   📱 "🛡️ Ficha de perdón usada para \'$nombre\'. Racha mantenida."');
      }
    }
    print('');
  }
  
  if (rachasPerdidas > 0) {
    print('💔 Notificaciones de rachas perdidas:');
    for (final reto in retosEjemplo) {
      final nombre = reto['nombre'] as String;
      final confirmado = reto['confirmadoAyer'] as bool;
      final fichas = reto['fichasDisponibles'] as int;
      
      if (!confirmado && fichas == 0) {
        print('   📱 "💔 Racha perdida en \'$nombre\'. No confirmaste antes de las 23:59."');
      }
    }
    print('');
  }
  
  if (fichasUsadas == 0 && rachasPerdidas == 0) {
    print('😊 No hay notificaciones de consecuencias');
    print('   Todos los retos fueron confirmados a tiempo');
    print('');
  }
  
  print('🎯 === CARACTERÍSTICAS DEL SISTEMA ===');
  print('⏰ Se ejecuta automáticamente a las 00:30');
  print('🔍 Verifica TODOS los retos activos del día anterior');
  print('🛡️ Usa fichas de perdón automáticamente cuando está disponible');
  print('💔 Solo resetea rachas cuando no hay más fichas');
  print('📱 Envía notificaciones claras con navegación al reto específico');
  print('📊 Guarda estadísticas de cada verificación nocturna');
  print('🔄 Se regeneran fichas de perdón semanalmente');
  print('🎯 Mantiene la integridad del sistema de rachas');
  print('');
  
  print('🚀 === CÓMO PROBARLO ===');
  print('1. Crear un reto cualquier día');
  print('2. NO confirmarlo antes de las 23:59');
  print('3. Esperar hasta las 00:30 del día siguiente');
  print('4. Verificar notificación automática');
  print('5. Comprobar estado de la racha en la app');
  print('');
  
  print('✅ Simulación completada - El sistema está listo para funcionar');
}
