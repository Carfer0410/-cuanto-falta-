/// 🔍 VERIFICACIÓN ESPECÍFICA: Datos de hitos guardados
/// Este script verifica los datos de SharedPreferences relacionados con hitos

void main() async {
  print('🔍 === VERIFICACIÓN DE DATOS DE HITOS ===\n');
  
  // Verificar estructura de datos en SharedPreferences
  print('📋 DATOS A REVISAR EN SHAREDPREFERENCES:');
  print('');
  
  print('🔧 1. CONFIGURACIÓN DE NOTIFICACIONES');
  print('   📍 Clave: "challenge_notifications_enabled"');
  print('   📍 Valor esperado: true');
  print('   📍 Descripción: Habilita/deshabilita notificaciones de retos');
  print('');
  
  print('🔧 2. FRECUENCIA DE VERIFICACIÓN');
  print('   📍 Clave: "challenge_frequency"');
  print('   📍 Valor por defecto: "6" (horas)');
  print('   📍 Descripción: Cada cuántas horas verifica hitos');
  print('');
  
  print('🔧 3. DATOS DE RETOS (COUNTERS)');
  print('   📍 Clave: "counters"');
  print('   📍 Formato: JSON con array de retos');
  print('   📍 Campos importantes:');
  print('      - challengeStartedAt: fecha de inicio');
  print('      - lastConfirmedDate: última confirmación');
  print('      - isNegativeHabit: tipo de hábito');
  print('      - title: nombre del reto');
  print('');
  
  print('🔧 4. RACHAS INDIVIDUALES');
  print('   📍 Clave: "individual_streaks"');
  print('   📍 Formato: JSON con mapeo de retos a rachas');
  print('   📍 Campos importantes:');
  print('      - currentStreak: días actuales');
  print('      - lastConfirmationDate: última confirmación');
  print('      - isRetroactive: si es reto retroactivo');
  print('');
  
  print('🔧 5. RECORDATORIOS ENVIADOS (ANTI-DUPLICADOS)');
  print('   📍 Patrón de claves: "reminder_sent_[hash]_[tipo]"');
  print('   📍 Ejemplos:');
  print('      - "reminder_sent_123456_week_1"');
  print('      - "reminder_sent_123456_week_1_2025-7-31"');
  print('      - "reminder_sent_123456_milestone_sent_2025-7-31"');
  print('   📍 Valor: timestamp cuando se envió');
  print('');
  
  print('🔧 6. CONFIGURACIÓN DE MOTIVACIÓN');
  print('   📍 Clave: "last_motivation_time"');
  print('   📍 Valor: timestamp de último mensaje motivacional');
  print('   📍 Cooldown: 4 horas entre mensajes');
  print('');
  
  // Guía para verificar datos manualmente
  print('📋 CÓMO VERIFICAR MANUALMENTE:');
  print('');
  print('🔍 OPCIÓN 1 - En Flutter DevTools:');
  print('   1. Abrir DevTools en el navegador');
  print('   2. Ir a la pestaña "Console"');
  print('   3. Ejecutar: SharedPreferences.getInstance().then((prefs) => print(prefs.getKeys()))');
  print('   4. Buscar las claves mencionadas arriba');
  print('');
  
  print('🔍 OPCIÓN 2 - Agregar debugging temporal:');
  print('   1. En main.dart, agregar después de línea 40:');
  print('   2. await _debugSharedPreferences();');
  print('   3. Crear función para imprimir datos');
  print('');
  
  print('🔍 OPCIÓN 3 - Logs de ChallengeNotificationService:');
  print('   1. Buscar en consola Flutter los logs:');
  print('   2. "💪 ChallengeNotificationService: Iniciando verificación"');
  print('   3. "🔔 Verificando reto: [nombre]"');
  print('   4. "🎯 Hito EXACTO encontrado para día X"');
  print('   5. "✅ Notificación motivacional enviada"');
  print('');
  
  // Diagnóstico paso a paso
  print('📋 DIAGNÓSTICO PASO A PASO:');
  print('');
  print('✅ PASO 1: Verificar que el servicio esté activo');
  print('   📍 Log esperado: "💪 ChallengeNotificationService: Iniciando verificación cada X horas"');
  print('   ❌ Si no aparece: Verificar challenge_notifications_enabled = true');
  print('');
  
  print('✅ PASO 2: Verificar que detecte el reto');
  print('   📍 Log esperado: "🔔 Verificando reto: [tu reto]"');
  print('   ❌ Si no aparece: El reto no tiene challengeStartedAt o lastConfirmedDate');
  print('');
  
  print('✅ PASO 3: Verificar cálculo de días');
  print('   📍 Log esperado: "🎯 Hito EXACTO encontrado para día 7: week_1"');
  print('   ❌ Si aparece otro número: El cálculo no da exactamente 7 días');
  print('   ❌ Si dice "No hay hito exacto": Los días calculados no son un hito válido');
  print('');
  
  print('✅ PASO 4: Verificar protecciones anti-duplicados');
  print('   📍 Log esperado: "✅ Notificación motivacional enviada"');
  print('   ❌ Si dice "BLOQUEADO": Ya se envió un hito hoy o antes');
  print('   🔧 Solución temporal: Limpiar datos de recordatorios');
  print('');
  
  print('📋 COMANDOS ÚTILES PARA DEBUGGING:');
  print('');
  print('🧹 Limpiar recordatorios (temporal):');
  print('   await ReminderTracker.clearAllReminders();');
  print('');
  
  print('🧹 Limpiar datos de hitos (temporal):');
  print('   await MilestoneNotificationService.resetAllMilestoneData();');
  print('');
  
  print('🔧 Forzar verificación inmediata:');
  print('   await ChallengeNotificationService._checkChallengesNow();');
  print('');
  
  print('🎯 === RESULTADO ESPERADO ===');
  print('Si todo funciona correctamente, deberías ver en la consola:');
  print('1. "🎯 Hito EXACTO encontrado para día 7: week_1"');
  print('2. "🔔 Generando notificación: 🌟 ¡Una semana completa!"');
  print('3. "✅ Notificación motivacional enviada"');
  print('4. Una notificación push en el dispositivo');
  print('');
  
  print('🚨 PROBLEMAS COMUNES:');
  print('• "No hay hito exacto para día X" → Días calculados ≠ 7');
  print('• "BLOQUEADO: Ya se envió" → Protección anti-duplicados activa');
  print('• "ChallengeNotificationService deshabilitado" → Configuración desactivada');
  print('• No aparecen logs → Servicio no iniciado o reto sin datos válidos');
  
  print('\n🚀 === VERIFICACIÓN COMPLETADA ===');
  print('💡 Usa esta información para diagnosticar el problema específico');
}
