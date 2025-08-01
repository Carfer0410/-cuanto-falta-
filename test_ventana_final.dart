void main() async {
  print('🧪 === TEST VENTANA DE CONFIRMACIÓN CORREGIDO ===');
  
  final now = DateTime.now();
  final startDate = DateTime(2025, 7, 28); // 28 de julio
  final daysToGrant = 4; // 28, 29, 30, 31
  
  print('📅 Simulando reto retroactivo:');
  print('   Fecha inicio: 28/07/2025');
  print('   Fecha hoy: ${now.day}/${now.month}/${now.year}');
  print('   Días solicitados: $daysToGrant');
  
  // Simular la lógica CORREGIDA
  final backdatedHistory = <DateTime>[];
  final todayNormalized = DateTime(now.year, now.month, now.day);
  
  for (int i = 0; i < daysToGrant; i++) {
    final confirmDate = startDate.add(Duration(days: i));
    final confirmDateNormalized = DateTime(confirmDate.year, confirmDate.month, confirmDate.day);
    
    // NO incluir HOY en el historial retroactivo
    if (!confirmDateNormalized.isAtSameMomentAs(todayNormalized)) {
      backdatedHistory.add(confirmDate);
    }
  }
  
  print('\n🔄 Resultado:');
  print('   Historial creado: ${backdatedHistory.map((d) => '${d.day}/${d.month}').join(', ')}');
  print('   Días en historial: ${backdatedHistory.length}');
  print('   ¿HOY incluido?: ${backdatedHistory.any((d) => DateTime(d.year, d.month, d.day).isAtSameMomentAs(todayNormalized)) ? "SÍ" : "NO"}');
  
  // Simular la verificación isCompletedToday
  final lastConfirmedDate = backdatedHistory.isNotEmpty ? backdatedHistory.last : null;
  final isCompletedToday = lastConfirmedDate != null && 
                          DateTime(lastConfirmedDate.year, lastConfirmedDate.month, lastConfirmedDate.day)
                              .isAtSameMomentAs(todayNormalized);
  
  print('\n🎯 Verificación de botón:');
  print('   Última confirmación: ${lastConfirmedDate != null ? '${lastConfirmedDate.day}/${lastConfirmedDate.month}' : 'NINGUNA'}');
  print('   ¿Completado hoy?: $isCompletedToday');
  print('   ¿Debe mostrar botón confirmar?: ${!isCompletedToday ? "✅ SÍ" : "❌ NO"}');
  
  // Verificar ventana de confirmación
  final currentHour = now.hour;
  final inWindow = currentHour >= 21 && currentHour <= 23;
  
  print('\n⏰ Ventana de confirmación:');
  print('   Hora actual: ${currentHour}:${now.minute.toString().padLeft(2, '0')}');
  print('   ¿En ventana (21:00-23:59)?: ${inWindow ? "✅ SÍ" : "❌ NO"}');
  
  final shouldShowButton = !isCompletedToday && inWindow;
  print('\n🎯 RESULTADO FINAL:');
  print('   ¿Mostrar botón "¿Cumpliste hoy?"?: ${shouldShowButton ? "✅ SÍ" : "❌ NO"}');
  
  if (!shouldShowButton && inWindow) {
    print('   ⚠️ Si no aparece: Verifica que el reto esté INICIADO');
  }
}
