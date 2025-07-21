/// Modelo para tareas de preparativos de eventos
class PreparationTask {
  int? id;
  int eventId;
  String title;
  String description;
  bool isCompleted;
  int daysBeforeEvent; // Cuántos días antes del evento debe completarse
  DateTime? completedAt;
  
  PreparationTask({
    this.id,
    required this.eventId,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.daysBeforeEvent,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'daysBeforeEvent': daysBeforeEvent,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory PreparationTask.fromMap(Map<String, dynamic> map) {
    return PreparationTask(
      id: map['id'],
      eventId: map['eventId'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      daysBeforeEvent: map['daysBeforeEvent'],
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt']) 
          : null,
    );
  }

  /// Verifica si la tarea debe mostrarse ya (según días restantes al evento)
  bool shouldShowTask(DateTime eventDate) {
    final now = DateTime.now();
    final daysUntilEvent = eventDate.difference(now).inDays;
    return daysUntilEvent <= daysBeforeEvent;
  }

  /// Verifica si la tarea está vencida (no completada y ya pasó su tiempo ideal)
  bool isOverdue(DateTime eventDate) {
    final now = DateTime.now();
    final daysUntilEvent = eventDate.difference(now).inDays;
    return !isCompleted && shouldShowTask(eventDate) && daysUntilEvent < daysBeforeEvent - 2;
  }
}
