import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'notification_center_models.dart';

class NotificationCenterService extends ChangeNotifier {
  static final NotificationCenterService _instance = NotificationCenterService._internal();
  static NotificationCenterService get instance => _instance;
  NotificationCenterService._internal();

  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  static const String _storageKey = 'notification_center_data';
  static const int _maxNotifications = 100; // Límite para evitar crecimiento infinito

  /// Inicializar el servicio cargando notificaciones almacenadas
  Future<void> init() async {
    await _loadNotifications();
    debugPrint('📱 NotificationCenterService inicializado con ${_notifications.length} notificaciones');
  }

  /// Agregar una nueva notificación al centro
  Future<void> addNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? payload,
    String? customId,
  }) async {
    final notification = AppNotification(
      id: customId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      payload: payload,
    );

    // Agregar al inicio de la lista (más recientes primero)
    _notifications.insert(0, notification);

    // Limitar el número de notificaciones
    if (_notifications.length > _maxNotifications) {
      _notifications = _notifications.take(_maxNotifications).toList();
    }

    await _saveNotifications();
    notifyListeners();

    debugPrint('📱 Nueva notificación agregada: $title');
  }

  /// Marcar una notificación como leída
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      notifyListeners();
    }
  }

  /// Marcar todas las notificaciones como leídas
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    await _saveNotifications();
    notifyListeners();
  }

  /// Eliminar una notificación específica
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
    notifyListeners();
  }

  /// Eliminar todas las notificaciones
  Future<void> deleteAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }

  /// Eliminar notificaciones leídas
  Future<void> deleteReadNotifications() async {
    _notifications.removeWhere((n) => n.isRead);
    await _saveNotifications();
    notifyListeners();
  }

  /// Obtener notificaciones filtradas por tipo
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Obtener notificaciones no leídas
  List<AppNotification> get unreadNotifications {
    return _notifications.where((n) => !n.isRead).toList();
  }

  /// Obtener conteo de notificaciones no leídas
  int get unreadCount => unreadNotifications.length;

  /// Obtener notificaciones de hoy
  List<AppNotification> get todayNotifications {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _notifications.where((n) {
      return n.timestamp.isAfter(startOfDay) && n.timestamp.isBefore(endOfDay);
    }).toList();
  }

  /// Obtener notificaciones de la última semana
  List<AppNotification> get thisWeekNotifications {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    return _notifications.where((n) => n.timestamp.isAfter(weekAgo)).toList();
  }

  /// Obtener estadísticas del centro de notificaciones
  Map<String, dynamic> get statistics {
    final typeCount = <NotificationType, int>{};
    for (final type in NotificationType.values) {
      typeCount[type] = getNotificationsByType(type).length;
    }

    return {
      'total': _notifications.length,
      'unread': unreadCount,
      'today': todayNotifications.length,
      'thisWeek': thisWeekNotifications.length,
      'byType': typeCount,
    };
  }

  /// Limpiar notificaciones antiguas (más de 30 días)
  Future<void> cleanOldNotifications() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    _notifications.removeWhere((n) => n.timestamp.isBefore(thirtyDaysAgo));
    await _saveNotifications();
    notifyListeners();
    debugPrint('📱 Notificaciones antiguas limpiadas');
  }

  /// Cargar notificaciones desde almacenamiento
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString(_storageKey);
      
      if (notificationsJson != null) {
        final List<dynamic> jsonList = json.decode(notificationsJson);
        _notifications = jsonList
            .map((json) => AppNotification.fromJson(json))
            .toList();
        
        // Ordenar por timestamp (más recientes primero)
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    } catch (e) {
      debugPrint('❌ Error cargando notificaciones: $e');
      _notifications = [];
    }
  }

  /// Guardar notificaciones en almacenamiento
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String notificationsJson = json.encode(
        _notifications.map((n) => n.toJson()).toList()
      );
      await prefs.setString(_storageKey, notificationsJson);
    } catch (e) {
      debugPrint('❌ Error guardando notificaciones: $e');
    }
  }

  /// Método para testing - agregar notificaciones de ejemplo
  Future<void> addSampleNotifications() async {
    final samples = [
      {
        'title': '🛡️ Ficha de perdón usada',
        'body': 'Se usó una ficha de perdón para "Ejercicio diario". Tu racha siguió creciendo.',
        'type': NotificationType.challenge,
      },
      {
        'title': '🎉 ¡Nuevo logro desbloqueado!',
        'body': 'Has conseguido el logro "Primera semana". ¡Sigue así!',
        'type': NotificationType.achievement,
      },
      {
        'title': '📅 Evento próximo',
        'body': 'Tienes un evento programado para mañana a las 15:00',
        'type': NotificationType.event,
      },
      {
        'title': '💪 Mensaje motivacional',
        'body': 'Cada pequeño paso te acerca más a tu objetivo. ¡No te rindas!',
        'type': NotificationType.motivation,
      },
      {
        'title': '🎨 Personalización disponible',
        'body': 'Configura tu estilo de planificación para una mejor experiencia',
        'type': NotificationType.planning,
      },
    ];

    for (final sample in samples) {
      await addNotification(
        title: sample['title'] as String,
        body: sample['body'] as String,
        type: sample['type'] as NotificationType,
      );
      
      // Agregar un pequeño delay entre notificaciones
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
