import 'package:flutter/material.dart';
import 'lib/notification_service.dart';
import 'lib/notification_center_service.dart';
import 'lib/notification_center_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 === PRUEBA DE NOTIFICACIÓN EN VIVO ===');
  
  // Inicializar servicios
  await NotificationService.instance.init();
  await NotificationCenterService.instance.init();
  
  // Simular la notificación problemática
  String problematicTitle = "⏰ ¡Últimos 29 minutos!";
  String problematicBody = "No olvides confirmar tu reto de meditación antes de que termine el día. ¡Ve a la pantalla de retos!";
  
  print('📤 Enviando notificación de prueba:');
  print('   Título: "$problematicTitle"');
  print('   Cuerpo: "$problematicBody"');
  
  // Enviar la notificación usando el sistema real
  await NotificationService.instance.showImmediateNotification(
    id: 12345,
    title: problematicTitle,
    body: problematicBody,
    payload: '{"action": "open_challenges", "screen": "challenges"}',
  );
  
  // Esperar un momento para que se procese
  await Future.delayed(Duration(milliseconds: 500));
  
  // Verificar el resultado en el centro de notificaciones
  final notifications = NotificationCenterService.instance.notifications;
  
  print('\n📋 Resultado en Centro de Notificaciones:');
  print('   Total notificaciones: ${notifications.length}');
  
  // Buscar nuestra notificación de prueba
  final testNotification = notifications.firstWhere(
    (n) => n.title == problematicTitle,
    orElse: () => AppNotification(
      id: 'not_found',
      title: 'No encontrada',
      body: '',
      type: NotificationType.general,
      timestamp: DateTime.now(),
    ),
  );
  
  if (testNotification.id != 'not_found') {
    print('✅ Notificación encontrada:');
    print('   ID: ${testNotification.id}');
    print('   Tipo: ${testNotification.type}');
    print('   ¿Es challenge?: ${testNotification.type == NotificationType.challenge}');
    
    if (testNotification.type == NotificationType.challenge) {
      print('🎉 ¡ÉXITO! La notificación se clasificó correctamente como CHALLENGE');
    } else {
      print('❌ ERROR: La notificación se clasificó como ${testNotification.type}');
    }
  } else {
    print('❌ ERROR: Notificación no encontrada en el centro');
  }
  
  print('\n📊 Estado completo del centro:');
  for (var notification in notifications) {
    print('   • "${notification.title}" → ${notification.type}');
  }
  
  print('\n✅ Prueba completada');
}
