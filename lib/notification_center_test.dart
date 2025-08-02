import 'package:flutter/material.dart';
import 'notification_center_service.dart';
import 'notification_center_models.dart';

/// Script de prueba para el centro de notificaciones
class NotificationCenterTestScript {
  
  /// Ejecutar todas las pruebas del centro de notificaciones
  static Future<void> runAllTests() async {
    debugPrint('🧪 === INICIANDO PRUEBAS DEL CENTRO DE NOTIFICACIONES ===');
    
    try {
      await testBasicOperations();
      await testNotificationTypes();
      await testPersistence();
      await testStatistics();
      
      debugPrint('✅ === TODAS LAS PRUEBAS COMPLETADAS EXITOSAMENTE ===');
    } catch (e) {
      debugPrint('❌ Error en las pruebas: $e');
    }
  }

  /// Probar operaciones básicas del centro
  static Future<void> testBasicOperations() async {
    debugPrint('🧪 Probando operaciones básicas...');
    
    final service = NotificationCenterService.instance;
    
    // Limpiar para empezar fresh
    await service.deleteAllNotifications();
    
    // Agregar notificación de prueba
    await service.addNotification(
      title: '🧪 Notificación de Prueba',
      body: 'Esta es una notificación de prueba del sistema',
      type: NotificationType.general,
      payload: 'test_payload',
    );
    
    assert(service.notifications.length == 1, 'Debería haber 1 notificación');
    assert(service.unreadCount == 1, 'Debería haber 1 notificación no leída');
    
    // Marcar como leída
    final notificationId = service.notifications.first.id;
    await service.markAsRead(notificationId);
    
    assert(service.unreadCount == 0, 'No debería haber notificaciones no leídas');
    assert(service.notifications.first.isRead, 'La notificación debería estar marcada como leída');
    
    debugPrint('✅ Operaciones básicas funcionando correctamente');
  }

  /// Probar diferentes tipos de notificaciones
  static Future<void> testNotificationTypes() async {
    debugPrint('🧪 Probando tipos de notificaciones...');
    
    final service = NotificationCenterService.instance;
    await service.deleteAllNotifications();
    
    // Agregar una notificación de cada tipo
    for (final type in NotificationType.values) {
      await service.addNotification(
        title: '${type.icon} ${type.displayName}',
        body: 'Notificación de prueba de tipo ${type.displayName}',
        type: type,
      );
    }
    
    assert(service.notifications.length == NotificationType.values.length, 
           'Debería haber ${NotificationType.values.length} notificaciones');
    
    // Verificar que cada tipo está presente
    for (final type in NotificationType.values) {
      final typeNotifications = service.getNotificationsByType(type);
      assert(typeNotifications.isNotEmpty, 'Debería haber notificaciones de tipo ${type.displayName}');
    }
    
    debugPrint('✅ Tipos de notificaciones funcionando correctamente');
  }

  /// Probar persistencia de datos
  static Future<void> testPersistence() async {
    debugPrint('🧪 Probando persistencia de datos...');
    
    final service = NotificationCenterService.instance;
    await service.deleteAllNotifications();
    
    // Agregar notificaciones de prueba
    await service.addNotification(
      title: '💾 Prueba de Persistencia 1',
      body: 'Esta notificación debería persistir después del reinicio',
      type: NotificationType.system,
    );
    
    await service.addNotification(
      title: '💾 Prueba de Persistencia 2',
      body: 'Esta también debería persistir',
      type: NotificationType.general,
    );
    
    final countBefore = service.notifications.length;
    
    // Simular reinicio reinicializando el servicio
    await service.init();
    
    final countAfter = service.notifications.length;
    
    assert(countBefore == countAfter, 
           'El número de notificaciones debería ser el mismo después del reinicio');
    
    debugPrint('✅ Persistencia de datos funcionando correctamente');
  }

  /// Probar estadísticas del centro
  static Future<void> testStatistics() async {
    debugPrint('🧪 Probando estadísticas...');
    
    final service = NotificationCenterService.instance;
    await service.deleteAllNotifications();
    
    // Agregar notificaciones variadas
    await service.addNotification(
      title: '📊 Estadística 1',
      body: 'Notificación no leída',
      type: NotificationType.achievement,
    );
    
    await service.addNotification(
      title: '📊 Estadística 2',
      body: 'Notificación leída',
      type: NotificationType.challenge,
    );
    
    // Marcar una como leída
    await service.markAsRead(service.notifications.last.id);
    
    final stats = service.statistics;
    
    assert(stats['total'] == 2, 'Debería haber 2 notificaciones totales');
    assert(stats['unread'] == 1, 'Debería haber 1 notificación no leída');
    assert(stats['today'] == 2, 'Debería haber 2 notificaciones de hoy');
    
    debugPrint('✅ Estadísticas funcionando correctamente');
  }

  /// Agregar notificaciones de ejemplo para demostrar el sistema
  static Future<void> addDemoNotifications() async {
    debugPrint('🎭 Agregando notificaciones de demostración...');
    
    final service = NotificationCenterService.instance;
    
    final demoNotifications = [
      {
        'title': '🎉 ¡Felicidades!',
        'body': 'Has completado tu primer reto. ¡Sigue así!',
        'type': NotificationType.achievement,
      },
      {
        'title': '🔥 Racha de 7 días',
        'body': 'Tu reto "Ejercicio diario" lleva 7 días consecutivos',
        'type': NotificationType.challenge,
      },
      {
        'title': '📅 Evento próximo',
        'body': 'Tu evento "Reunión de trabajo" es en 30 minutos',
        'type': NotificationType.event,
      },
      {
        'title': '💪 Mensaje motivacional',
        'body': 'Cada pequeño paso cuenta. ¡No te rindas!',
        'type': NotificationType.motivation,
      },
      {
        'title': '🛡️ Ficha de perdón utilizada',
        'body': 'Se usó una ficha de perdón para "Lectura diaria"',
        'type': NotificationType.challenge,
      },
      {
        'title': '🎨 Personalización disponible',
        'body': 'Configura tu estilo de planificación para una mejor experiencia',
        'type': NotificationType.planning,
      },
      {
        'title': '⚙️ Sistema actualizado',
        'body': 'La aplicación se ha actualizado con nuevas funciones',
        'type': NotificationType.system,
      },
      {
        'title': '⏰ Recordatorio',
        'body': 'No olvides confirmar tus retos de hoy antes de las 23:59',
        'type': NotificationType.reminder,
      },
    ];

    for (int i = 0; i < demoNotifications.length; i++) {
      final notification = demoNotifications[i];
      
      await service.addNotification(
        title: notification['title'] as String,
        body: notification['body'] as String,
        type: notification['type'] as NotificationType,
        customId: 'demo_${i + 1}',
      );
      
      // Agregar un pequeño delay entre notificaciones
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Marcar algunas como leídas para variar
    final notifications = service.notifications;
    if (notifications.length >= 4) {
      await service.markAsRead(notifications[1].id); // Segunda
      await service.markAsRead(notifications[3].id); // Cuarta
    }
    
    debugPrint('✅ ${demoNotifications.length} notificaciones de demo agregadas');
  }

  /// Limpiar todas las notificaciones de prueba
  static Future<void> cleanupTestNotifications() async {
    debugPrint('🧹 Limpiando notificaciones de prueba...');
    
    final service = NotificationCenterService.instance;
    
    // Eliminar notificaciones que contengan "Prueba" o "demo" en el ID
    final toDelete = service.notifications.where((n) => 
        n.title.contains('🧪') || 
        n.title.contains('💾') || 
        n.title.contains('📊') ||
        n.id.startsWith('demo_')
    ).toList();
    
    for (final notification in toDelete) {
      await service.deleteNotification(notification.id);
    }
    
    debugPrint('✅ ${toDelete.length} notificaciones de prueba eliminadas');
  }

  /// Mostrar estadísticas actuales
  static void showCurrentStats() {
    final service = NotificationCenterService.instance;
    final stats = service.statistics;
    
    debugPrint('📊 === ESTADÍSTICAS ACTUALES ===');
    debugPrint('Total: ${stats['total']}');
    debugPrint('No leídas: ${stats['unread']}');
    debugPrint('Hoy: ${stats['today']}');
    debugPrint('Esta semana: ${stats['thisWeek']}');
    debugPrint('Por tipo:');
    
    final byType = stats['byType'] as Map<NotificationType, int>;
    for (final entry in byType.entries) {
      if (entry.value > 0) {
        debugPrint('  ${entry.key.displayName}: ${entry.value}');
      }
    }
    debugPrint('===========================');
  }
}

/// Extensión para ejecutar las pruebas desde cualquier lugar
extension NotificationCenterTesting on NotificationCenterService {
  
  /// Método de conveniencia para ejecutar pruebas
  Future<void> runTests() async {
    await NotificationCenterTestScript.runAllTests();
  }
  
  /// Método para agregar notificaciones de demo
  Future<void> addDemoData() async {
    await NotificationCenterTestScript.addDemoNotifications();
  }
  
  /// Método para limpiar datos de prueba
  Future<void> cleanup() async {
    await NotificationCenterTestScript.cleanupTestNotifications();
  }
  
  /// Mostrar estadísticas en consola
  void showStats() {
    NotificationCenterTestScript.showCurrentStats();
  }
}
