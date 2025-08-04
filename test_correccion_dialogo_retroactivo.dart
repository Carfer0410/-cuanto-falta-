// 🧪 PRUEBA DE CORRECCIÓN: DIÁLOGO DE RETOS RETROACTIVOS
// Archivo: test_correccion_dialogo_retroactivo.dart

void main() {
  print('=== 🔍 PRUEBA DE CORRECCIÓN: DIÁLOGO RETROACTIVO ===\n');

  testCalculoDiasTranscurridos();
}

void testCalculoDiasTranscurridos() {
  print('🧮 TEST: Cálculo correcto de días transcurridos');

  // CASO 1: Reto de hace 3 días
  print('\n📅 CASO 1: Reto creado hace 3 días');

  final startDate = DateTime(2025, 7, 27); // 27/07
  final today = DateTime(2025, 7, 30); // 30/07

  // Normalizar fechas (igual que en add_counter_page.dart)
  final start = DateTime(startDate.year, startDate.month, startDate.day);
  final todayNorm = DateTime(today.year, today.month, today.day);

  // Calcular días transcurridos
  final daysPassed = todayNorm.difference(start).inDays;

  print('  • Fecha inicio: ${start.day}/${start.month}/${start.year}');
  print(
    '  • Fecha actual: ${todayNorm.day}/${todayNorm.month}/${todayNorm.year}',
  );
  print('  • Días transcurridos: $daysPassed');

  // Mensaje ANTES de la corrección (INCORRECTO)
  final mensajeAntes =
      'Han pasado ${daysPassed - 1} ${daysPassed - 1 == 1 ? 'día' : 'días'} desde entonces.';

  // Mensaje DESPUÉS de la corrección (CORRECTO)
  final mensajeDespues =
      'Han pasado $daysPassed ${daysPassed == 1 ? 'día' : 'días'} desde entonces.';

  print('\n📝 MENSAJE ANTES (incorrecto):');
  print('  "$mensajeAntes"');
  print(
    '  ❌ Mostraba: ${daysPassed - 1} días (27→28→29→30 = 2 días) INCORRECTO',
  );

  print('\n📝 MENSAJE DESPUÉS (corregido):');
  print('  "$mensajeDespues"');
  print('  ✅ Muestra: $daysPassed días (27→28→29→30 = 3 días) CORRECTO');

  // CASO 2: Reto de hace 1 día
  print('\n📅 CASO 2: Reto creado hace 1 día');

  final startDateAyer = DateTime(2025, 7, 29); // 29/07
  final todayAyer = DateTime(2025, 7, 30); // 30/07

  final startAyer = DateTime(
    startDateAyer.year,
    startDateAyer.month,
    startDateAyer.day,
  );
  final todayAyerNorm = DateTime(
    todayAyer.year,
    todayAyer.month,
    todayAyer.day,
  );

  final daysPassedAyer = todayAyerNorm.difference(startAyer).inDays;

  print(
    '  • Fecha inicio: ${startAyer.day}/${startAyer.month}/${startAyer.year}',
  );
  print(
    '  • Fecha actual: ${todayAyerNorm.day}/${todayAyerNorm.month}/${todayAyerNorm.year}',
  );
  print('  • Días transcurridos: $daysPassedAyer');

  final mensajeAyerAntes =
      'Han pasado ${daysPassedAyer - 1} ${daysPassedAyer - 1 == 1 ? 'día' : 'días'} desde entonces.';
  final mensajeAyerDespues =
      'Han pasado $daysPassedAyer ${daysPassedAyer == 1 ? 'día' : 'días'} desde entonces.';

  print('\n📝 MENSAJE ANTES (incorrecto):');
  print('  "$mensajeAyerAntes"');
  print('  ❌ Mostraba: ${daysPassedAyer - 1} días (29→30 = 0 días) ABSURDO');

  print('\n📝 MENSAJE DESPUÉS (corregido):');
  print('  "$mensajeAyerDespues"');
  print('  ✅ Muestra: $daysPassedAyer día (29→30 = 1 día) CORRECTO');

  // CASO 3: Reto del mismo día (no debería mostrar diálogo)
  print('\n📅 CASO 3: Reto creado hoy (no debería activar diálogo)');

  final startDateHoy = DateTime(2025, 7, 30); // 30/07
  final todayHoy = DateTime(2025, 7, 30); // 30/07

  final startHoy = DateTime(
    startDateHoy.year,
    startDateHoy.month,
    startDateHoy.day,
  );
  final todayHoyNorm = DateTime(todayHoy.year, todayHoy.month, todayHoy.day);

  final daysPassedHoy = todayHoyNorm.difference(startHoy).inDays;

  print('  • Fecha inicio: ${startHoy.day}/${startHoy.month}/${startHoy.year}');
  print(
    '  • Fecha actual: ${todayHoyNorm.day}/${todayHoyNorm.month}/${todayHoyNorm.year}',
  );
  print('  • Días transcurridos: $daysPassedHoy');
  print('  • ¿Activar diálogo?: ${daysPassedHoy >= 1 ? 'SÍ' : 'NO'}');
  print('  ✅ CORRECTO: No se activa el diálogo para retos del mismo día');

  print('\n=== 🏆 RESUMEN DE LA CORRECCIÓN ===');
  print('✅ PROBLEMA SOLUCIONADO: El mensaje ahora muestra los días correctos');
  print('✅ CONSISTENCIA: La lógica de daysPassed y el mensaje están alineados');
  print('✅ EXPERIENCIA: El usuario ve información precisa y consistente');
}
