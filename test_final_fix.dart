/// 🧪 Prueba rápida para verificar que las notificaciones están corregidas
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lib/challenge_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 === PRUEBA FINAL: VERIFICAR CORRECCIÓN ===');
  
  // Limpiar completamente el historial de notificaciones
  await ChallengeNotificationService.clearNotificationHistory();
  
  // Probar el caso específico del usuario: 23-29 julio = 7 días
  print('\n🎯 === CASO DEL USUARIO: 23-29 JULIO ===');
  await ChallengeNotificationService.testRetroactiveChallengeNotification();
  
  print('\n✅ === PRUEBA COMPLETADA ===');
  print('📝 Si todo está correcto, deberías ver:');
  print('   • Título: "🌟 ¡Una semana completa!"');
  print('   • Tipo: "week_1"');
  print('   • NO "🎉 ¡Primer día completado!"');
  print('\n🔥 MilestoneNotificationService ha sido deshabilitado');
  print('   para evitar duplicados con ChallengeNotificationService');
}
