/// 🔧 FUNCIÓN DE DEBUGGING TEMPORAL para main.dart
/// Agrega esta función a main.dart para diagnosticar los datos de hitos

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Función para debuggear datos de SharedPreferences relacionados con hitos
/// Agregar en main.dart después de la línea 40, antes de runApp()
Future<void> debugSharedPreferences() async {
  print('\n🔍 === DEBUGGING SHAREDPREFERENCES ===');
  
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Configuración de notificaciones
    print('\n📋 1. CONFIGURACIÓN DE NOTIFICACIONES');
    final notificationsEnabled = prefs.getBool('challenge_notifications_enabled') ?? true;
    final frequency = prefs.getString('challenge_frequency') ?? '6';
    print('   ✅ challenge_notifications_enabled: $notificationsEnabled');
    print('   ✅ challenge_frequency: $frequency horas');
    
    if (!notificationsEnabled) {
      print('   🚨 ¡PROBLEMA! Las notificaciones están DESHABILITADAS');
    }
    
    // 2. Datos de retos (counters)
    print('\n📋 2. DATOS DE RETOS');
    final countersJson = prefs.getString('counters');
    if (countersJson != null) {
      try {
        final List<dynamic> counters = jsonDecode(countersJson);
        print('   ✅ Total de retos: ${counters.length}');
        
        for (int i = 0; i < counters.length; i++) {
          final counter = counters[i];
          final title = counter['title'] ?? 'Sin título';
          final challengeStarted = counter['challengeStartedAt'];
          final lastConfirmed = counter['lastConfirmedDate'];
          final isNegative = counter['isNegativeHabit'] ?? false;
          
          print('\n   📍 Reto ${i + 1}: "$title"');
          print('      - Hábito negativo: $isNegative');
          print('      - Fecha inicio: $challengeStarted');
          print('      - Última confirmación: $lastConfirmed');
          
          // Verificar si tiene los datos necesarios para hitos
          if (challengeStarted == null) {
            print('      🚨 ¡PROBLEMA! challengeStartedAt es NULL');
          }
          if (lastConfirmed == null) {
            print('      🚨 ¡PROBLEMA! lastConfirmedDate es NULL');
          }
          
          // Calcular días de racha si es posible
          if (challengeStarted != null && lastConfirmed != null) {
            try {
              final startDate = DateTime.parse(challengeStarted);
              final confirmedDate = DateTime.parse(lastConfirmed);
              final days = confirmedDate.difference(startDate).inDays + 1;
              print('      ✅ Días calculados: $days');
              
              if (days == 7) {
                print('      🎯 ¡ESTE RETO DEBERÍA RECIBIR HITO DE 1 SEMANA!');
              }
            } catch (e) {
              print('      ❌ Error calculando días: $e');
            }
          }
        }
      } catch (e) {
        print('   ❌ Error parseando counters: $e');
      }
    } else {
      print('   ⚠️ No hay datos de counters');
    }
    
    // 3. Rachas individuales
    print('\n📋 3. RACHAS INDIVIDUALES');
    final streaksJson = prefs.getString('individual_streaks');
    if (streaksJson != null) {
      try {
        final Map<String, dynamic> streaks = jsonDecode(streaksJson);
        print('   ✅ Total de rachas: ${streaks.length}');
        
        streaks.forEach((key, value) {
          final currentStreak = value['currentStreak'] ?? 0;
          final lastConfirmation = value['lastConfirmationDate'];
          final isRetroactive = value['isRetroactive'] ?? false;
          
          print('\n   📍 Racha ID: $key');
          print('      - Días actuales: $currentStreak');
          print('      - Última confirmación: $lastConfirmation');
          print('      - Es retroactivo: $isRetroactive');
          
          if (currentStreak == 7) {
            print('      🎯 ¡ESTA RACHA DEBERÍA RECIBIR HITO DE 1 SEMANA!');
          }
        });
      } catch (e) {
        print('   ❌ Error parseando streaks: $e');
      }
    } else {
      print('   ⚠️ No hay datos de individual_streaks');
    }
    
    // 4. Recordatorios enviados (buscar patrones de week_1)
    print('\n📋 4. RECORDATORIOS ENVIADOS (week_1)');
    final allKeys = prefs.getKeys();
    final reminderKeys = allKeys.where((key) => 
      key.startsWith('reminder_sent_') && key.contains('week_1')
    ).toList();
    
    if (reminderKeys.isNotEmpty) {
      print('   ✅ Recordatorios de week_1 encontrados:');
      for (final key in reminderKeys) {
        final timestamp = prefs.getInt(key);
        final date = timestamp != null 
          ? DateTime.fromMillisecondsSinceEpoch(timestamp).toString()
          : 'null';
        print('      - $key: $date');
      }
      print('   🚨 Si hay recordatorios de today, se bloquearán duplicados');
    } else {
      print('   ✅ No hay recordatorios de week_1 (perfecto para nuevos hitos)');
    }
    
    // 5. Verificar si hay bloqueos de hoy
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    final todayBlocks = allKeys.where((key) => 
      key.contains(todayKey) && key.startsWith('reminder_sent_')
    ).toList();
    
    print('\n📋 5. BLOQUEOS DE HOY ($todayKey)');
    if (todayBlocks.isNotEmpty) {
      print('   🚨 BLOQUEOS ACTIVOS para hoy:');
      for (final key in todayBlocks) {
        print('      - $key');
      }
      print('   ⚠️ Estos bloqueos pueden prevenir nuevos hitos hoy');
    } else {
      print('   ✅ No hay bloqueos para hoy (perfecto para hitos)');
    }
    
    // 6. Resumen del diagnóstico
    print('\n📋 6. RESUMEN DEL DIAGNÓSTICO');
    
    if (!notificationsEnabled) {
      print('   🚨 PROBLEMA CRÍTICO: Notificaciones deshabilitadas');
      print('   🔧 Solución: Ir a Configuración → Notificaciones → Habilitar');
    } else {
      print('   ✅ Notificaciones habilitadas');
    }
    
    // Buscar retos candidatos para hito de 7 días
    bool foundWeekCandidate = false;
    if (countersJson != null) {
      try {
        final List<dynamic> counters = jsonDecode(countersJson);
        for (final counter in counters) {
          final challengeStarted = counter['challengeStartedAt'];
          final lastConfirmed = counter['lastConfirmedDate'];
          
          if (challengeStarted != null && lastConfirmed != null) {
            final startDate = DateTime.parse(challengeStarted);
            final confirmedDate = DateTime.parse(lastConfirmed);
            final days = confirmedDate.difference(startDate).inDays + 1;
            
            if (days == 7) {
              foundWeekCandidate = true;
              print('   🎯 CANDIDATO ENCONTRADO: "${counter['title']}" tiene exactamente 7 días');
            }
          }
        }
      } catch (e) {
        // Error ya reportado arriba
      }
    }
    
    if (!foundWeekCandidate) {
      print('   ⚠️ No se encontraron retos con exactamente 7 días');
      print('   💡 El hito solo se envía cuando hay EXACTAMENTE 7 días');
    }
    
    print('\n🔄 PRÓXIMOS PASOS:');
    if (!notificationsEnabled) {
      print('   1. 🔧 Habilitar notificaciones en configuración');
    }
    if (todayBlocks.isNotEmpty) {
      print('   2. 🧹 (Opcional) Limpiar bloqueos de hoy para testing');
    }
    if (foundWeekCandidate) {
      print('   3. ⏰ Esperar hasta 30 minutos para el próximo timer');
      print('   4. 👀 Monitorear logs en consola Flutter');
    } else {
      print('   3. ⏰ Esperar hasta que un reto tenga exactamente 7 días');
    }
    
  } catch (e) {
    print('❌ Error general en debugging: $e');
  }
  
  print('\n🚀 === DEBUGGING COMPLETADO ===\n');
}

// INSTRUCCIONES DE USO:
// 1. Agregar esta función a main.dart
// 2. En la función main(), después de línea 40, agregar:
//    await debugSharedPreferences();
// 3. Ejecutar la app y revisar la consola Flutter
// 4. Remover la llamada cuando termines el debugging
