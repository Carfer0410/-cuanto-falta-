/// 🎯 HERRAMIENTAS DE DEBUGGING PARA HITOS
/// Script Dart ejecutable para diagnosticar notificaciones de hitos

/// Simula la verificación de configuración
void main() async {
  print('🔍 === HERRAMIENTAS DE DEBUGGING HITOS ===\n');
  
  print('📋 COMANDOS PARA COPIAR EN FLUTTER DEVTOOLS CONSOLE:');
  print('(Copia y pega estos comandos uno por uno en la consola)\n');
  
  // Comando 1: Verificar configuración
  print('// 🔧 COMANDO 1: Verificar configuración de notificaciones');
  print('SharedPreferences.getInstance().then((prefs) {');
  print('  final enabled = prefs.getBool(\'challenge_notifications_enabled\') ?? true;');
  print('  print(\'🔔 Notificaciones habilitadas: \$enabled\');');
  print('  if (!enabled) print(\'🚨 ¡PROBLEMA! Notificaciones deshabilitadas\');');
  print('});\n');
  
  // Comando 2: Verificar datos de retos
  print('// 🔧 COMANDO 2: Ver retos y calcular días');
  print('SharedPreferences.getInstance().then((prefs) {');
  print('  final countersJson = prefs.getString(\'counters\');');
  print('  if (countersJson != null) {');
  print('    final List<dynamic> counters = jsonDecode(countersJson);');
  print('    print(\'📋 RETOS ENCONTRADOS: \${counters.length}\');');
  print('    for (int i = 0; i < counters.length; i++) {');
  print('      final counter = counters[i];');
  print('      final title = counter[\'title\'];');
  print('      final startDate = counter[\'challengeStartedAt\'];');
  print('      final lastConfirmed = counter[\'lastConfirmedDate\'];');
  print('      print(\'\\n📍 Reto \${i + 1}: "\$title"\');');
  print('      if (startDate != null && lastConfirmed != null) {');
  print('        final start = DateTime.parse(startDate);');
  print('        final confirmed = DateTime.parse(lastConfirmed);');
  print('        final days = confirmed.difference(start).inDays + 1;');
  print('        print(\'   ✅ Días: \$days\');');
  print('        if (days == 7) print(\'   🎯 ¡ESTE RETO DEBERÍA RECIBIR HITO DE 1 SEMANA!\');');
  print('      } else {');
  print('        print(\'   ❌ Falta fecha de inicio o confirmación\');');
  print('      }');
  print('    }');
  print('  }');
  print('});\n');
  
  // Comando 3: Verificar bloqueos
  print('// 🔧 COMANDO 3: Verificar bloqueos anti-duplicados');
  print('SharedPreferences.getInstance().then((prefs) {');
  print('  final today = DateTime.now();');
  print('  final todayKey = \'\${today.year}-\${today.month}-\${today.day}\';');
  print('  final allKeys = prefs.getKeys();');
  print('  final todayBlocks = allKeys.where((key) =>');
  print('    key.contains(todayKey) && key.startsWith(\'reminder_sent_\')).toList();');
  print('  print(\'🛡️ BLOQUEOS PARA HOY (\$todayKey):\');');
  print('  if (todayBlocks.isEmpty) {');
  print('    print(\'   ✅ No hay bloqueos (perfecto para nuevos hitos)\');');
  print('  } else {');
  print('    print(\'   🚨 BLOQUEOS ACTIVOS:\');');
  print('    for (final key in todayBlocks) print(\'      - \$key\');');
  print('  }');
  print('});\n');
  
  // Comando 4: Limpiar bloqueos
  print('// 🔧 COMANDO 4: Limpiar bloqueos (SOLO PARA TESTING)');
  print('SharedPreferences.getInstance().then((prefs) {');
  print('  final today = DateTime.now();');
  print('  final todayKey = \'\${today.year}-\${today.month}-\${today.day}\';');
  print('  final allKeys = prefs.getKeys();');
  print('  final todayBlocks = allKeys.where((key) =>');
  print('    key.contains(todayKey) && key.startsWith(\'reminder_sent_\')).toList();');
  print('  print(\'🧹 LIMPIANDO \${todayBlocks.length} bloqueos de hoy...\');');
  print('  for (final key in todayBlocks) {');
  print('    prefs.remove(key);');
  print('    print(\'   ✅ Eliminado: \$key\');');
  print('  }');
  print('  print(\'🚀 Bloqueos limpiados. Ahora pueden enviarse nuevos hitos.\');');
  print('});\n');
  
  // Instrucciones
  print('� INSTRUCCIONES DE USO:');
  print('1. 🚀 Ejecutar la app Flutter');
  print('2. 🌐 Abrir Flutter DevTools en el navegador');
  print('3. 📱 Ir a la pestaña "Console"');
  print('4. 📝 Copiar y pegar los comandos uno por uno');
  print('5. 👀 Revisar los resultados\n');
  
  print('🎯 ORDEN RECOMENDADO:');
  print('1. Comando 1: Verificar configuración');
  print('2. Comando 2: Ver retos y días');
  print('3. Comando 3: Verificar bloqueos');
  print('4. (Si hay bloqueos) Comando 4: Limpiar bloqueos\n');
  
  print('🚨 PROBLEMAS COMUNES:');
  print('• "Notificaciones deshabilitadas" → Ir a Configuración → Habilitar');
  print('• "Falta fecha de inicio" → Reto no iniciado correctamente');
  print('• "Bloqueos activos" → Ya se envió un hito hoy');
  print('• "No hay retos con 7 días" → Esperar a que alcance 7 días exactos\n');
  
  print('💡 TIP: El hito de 7 días se envía automáticamente cuando:');
  print('• Hay exactamente 7 días de racha');
  print('• No se ha enviado ningún hito hoy para ese reto');
  print('• Las notificaciones están habilitadas');
  print('• ChallengeNotificationService está activo\n');
  
  print('🚀 === DEBUGGING COMPLETADO ===');
}
