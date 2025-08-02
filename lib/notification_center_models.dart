import 'package:flutter/material.dart';

/// Modelo para representar una notificación en el centro de notificaciones
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final String? payload;
  final bool isRead;
  final String? iconData; // Para almacenar el tipo de ícono
  final Color? color;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.payload,
    this.isRead = false,
    this.iconData,
    this.color,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    NotificationType? type,
    String? payload,
    bool? isRead,
    String? iconData,
    Color? color,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      isRead: isRead ?? this.isRead,
      iconData: iconData ?? this.iconData,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
      'payload': payload,
      'isRead': isRead,
      'iconData': iconData,
      'color': color?.value,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      timestamp: DateTime.parse(json['timestamp']),
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.general,
      ),
      payload: json['payload'],
      isRead: json['isRead'] ?? false,
      iconData: json['iconData'],
      color: json['color'] != null ? Color(json['color']) : null,
    );
  }
}

/// Tipos de notificaciones para categorización y personalización visual
enum NotificationType {
  challenge,           // Retos (fichas de perdón, rachas perdidas, etc.)
  event,              // Eventos próximos
  achievement,        // Logros desbloqueados
  reminder,           // Recordatorios generales
  motivation,         // Mensajes motivacionales
  system,             // Mensajes del sistema
  planning,           // Planificación y personalización
  general,            // Notificaciones generales
}

/// Extensión para obtener información visual de cada tipo de notificación
extension NotificationTypeExtension on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.challenge:
        return Icons.local_fire_department;
      case NotificationType.event:
        return Icons.event;
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.reminder:
        return Icons.notifications;
      case NotificationType.motivation:
        return Icons.psychology;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.planning:
        return Icons.palette;
      case NotificationType.general:
        return Icons.info;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.challenge:
        return Colors.orange;
      case NotificationType.event:
        return Colors.blue;
      case NotificationType.achievement:
        return Colors.amber;
      case NotificationType.reminder:
        return Colors.purple;
      case NotificationType.motivation:
        return Colors.green;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.planning:
        return Colors.pink;
      case NotificationType.general:
        return Colors.indigo;
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.challenge:
        return 'Retos';
      case NotificationType.event:
        return 'Eventos';
      case NotificationType.achievement:
        return 'Logros';
      case NotificationType.reminder:
        return 'Recordatorios';
      case NotificationType.motivation:
        return 'Motivación';
      case NotificationType.system:
        return 'Sistema';
      case NotificationType.planning:
        return 'Planificación';
      case NotificationType.general:
        return 'General';
    }
  }
}
