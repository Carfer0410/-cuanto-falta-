import 'package:flutter/material.dart';

/// Colores disponibles para personalización de eventos
enum EventColor {
  orange('Naranja', Colors.orange, Color(0xFFFFE0B2)),
  blue('Azul', Colors.blue, Color(0xFFE3F2FD)),
  green('Verde', Colors.green, Color(0xFFE8F5E8)),
  purple('Morado', Colors.purple, Color(0xFFF3E5F5)),
  red('Rojo', Colors.red, Color(0xFFFFEBEE)),
  pink('Rosa', Colors.pink, Color(0xFFFCE4EC)),
  teal('Verde Azulado', Colors.teal, Color(0xFFE0F2F1)),
  amber('Ámbar', Colors.amber, Color(0xFFFFF8E1)),
  indigo('Índigo', Colors.indigo, Color(0xFFE8EAF6)),
  cyan('Cian', Colors.cyan, Color(0xFFE0F7FA));

  const EventColor(this.displayName, this.color, this.lightColor);
  final String displayName;
  final Color color;
  final Color lightColor;
  
  static EventColor fromString(String? colorName) {
    return EventColor.values.firstWhere(
      (color) => color.name == colorName,
      orElse: () => EventColor.orange,
    );
  }
}

/// Iconos disponibles para personalización de eventos
enum EventIcon {
  celebration('Celebración', Icons.celebration),
  cake('Pastel', Icons.cake),
  flight('Vuelo', Icons.flight),
  work('Trabajo', Icons.work),
  school('Estudio', Icons.school),
  favorite('Corazón', Icons.favorite),
  star('Estrella', Icons.star),
  home('Casa', Icons.home),
  sports('Deportes', Icons.sports_soccer),
  music('Música', Icons.music_note),
  camera('Fotografía', Icons.camera_alt),
  restaurant('Comida', Icons.restaurant),
  local_hospital('Salud', Icons.local_hospital),
  shopping('Compras', Icons.shopping_bag),
  beach('Playa', Icons.beach_access),
  movie('Película', Icons.movie),
  fitness('Ejercicio', Icons.fitness_center),
  pets('Mascotas', Icons.pets),
  nature('Naturaleza', Icons.nature),
  emoji_events('Evento', Icons.emoji_events);

  const EventIcon(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
  
  static EventIcon fromString(String? iconName) {
    return EventIcon.values.firstWhere(
      (icon) => icon.name == iconName,
      orElse: () => EventIcon.celebration,
    );
  }
}

/// Modelo Event para SQLite con personalización visual
/// Atributos:
/// - int? id
/// - String title
/// - DateTime targetDate
/// - String message
/// - String category
/// - EventColor color (personalización)
/// - EventIcon icon (personalización)
/// Métodos:
/// - toMap(): para guardar en SQLite
/// - fromMap(): para leer desde SQLite
class Event {
  int? id;
  String title;
  DateTime targetDate;
  String message;
  String category;
  EventColor color;
  EventIcon icon;

  Event({
    this.id,
    required this.title,
    required this.targetDate,
    required this.message,
    required this.category,
    this.color = EventColor.orange,
    this.icon = EventIcon.celebration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetDate': targetDate.toIso8601String(),
      'message': message,
      'category': category,
      'color': color.name,
      'icon': icon.name,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      targetDate: DateTime.parse(map['targetDate']),
      message: map['message'],
      category: map['category'] ?? 'other',
      color: EventColor.fromString(map['color']),
      icon: EventIcon.fromString(map['icon']),
    );
  }

  bool get isNegativeHabit => title.toLowerCase().contains('dejar');
}
