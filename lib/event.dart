/// Modelo Event para SQLite
/// Atributos:
/// - int? id
/// - String title
/// - DateTime targetDate
/// - String message
/// - String category
/// Métodos:
/// - toMap(): para guardar en SQLite
/// - fromMap(): para leer desde SQLite
class Event {
  int? id;
  String title;
  DateTime targetDate;
  String message;
  String category;

  Event({
    this.id,
    required this.title,
    required this.targetDate,
    required this.message,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetDate': targetDate.toIso8601String(),
      'message': message,
      'category': category,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      targetDate: DateTime.parse(map['targetDate']),
      message: map['message'],
      category: map['category'] ?? 'other',
    );
  }

  bool get isNegativeHabit => title.toLowerCase().contains('dejar');
}
