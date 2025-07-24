/// Modelo para tareas de preparativos de eventos
class PreparationTask {
  int? id;
  int eventId;
  String title;
  String description;
  bool isCompleted;
  int daysBeforeEvent; // Cuántos días antes del evento debe completarse
  DateTime? completedAt;
  String? personalNote; // 📝 Nueva: Nota personal opcional del usuario
  
  PreparationTask({
    this.id,
    required this.eventId,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.daysBeforeEvent,
    this.completedAt,
    this.personalNote, // 📝 Nueva: Nota personal opcional
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
      'personalNote': personalNote, // 📝 Nueva: Nota personal
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
      personalNote: map['personalNote'], // 📝 Nueva: Nota personal
    );
  }

  /// Verifica si la tarea debe mostrarse ya (según días restantes al evento)
  bool shouldShowTask(DateTime eventDate) {
    final now = DateTime.now();
    final daysUntilEvent = eventDate.difference(now).inDays;
    
    // 🆕 NUEVO: Lógica adaptativa para eventos próximos
    
    // Para eventos muy próximos (menos de 5 días), mostrar todas las tareas
    if (daysUntilEvent <= 5) {
      return true;
    }
    
    // Para eventos próximos (menos de 14 días), ser más flexible
    if (daysUntilEvent <= 14) {
      return daysUntilEvent <= daysBeforeEvent + 2; // +2 días de flexibilidad
    }
    
    // Para eventos normales, usar lógica estándar
    return daysUntilEvent <= daysBeforeEvent;
  }

  /// Verifica si la tarea está vencida (no completada y ya pasó su tiempo ideal)
  bool isOverdue(DateTime eventDate) {
    final now = DateTime.now();
    final daysUntilEvent = eventDate.difference(now).inDays;
    
    // Si ya está completada, no está vencida
    if (isCompleted) return false;
    
    // Si no debe mostrarse aún, no está vencida
    if (!shouldShowTask(eventDate)) return false;
    
    // 🆕 NUEVO: Lógica adaptativa para determinar si está vencida
    
    // Para eventos muy próximos (menos de 5 días), ser muy tolerante
    if (daysUntilEvent <= 5) {
      return daysUntilEvent < (daysBeforeEvent * 0.5).round(); // 50% tolerancia
    }
    
    // Para eventos próximos (menos de 14 días), ser moderadamente tolerante
    if (daysUntilEvent <= 14) {
      return daysUntilEvent < daysBeforeEvent - 3; // 3 días de tolerancia
    }
    
    // Para eventos normales, usar lógica estándar pero más flexible
    return daysUntilEvent < daysBeforeEvent - 2; // 2 días de tolerancia (antes era 2)
  }

  /// 📝 Obtiene la descripción completa incluyendo nota personal si existe
  String getFullDescription() {
    if (personalNote != null && personalNote!.trim().isNotEmpty) {
      return '$description\n📝 $personalNote';
    }
    return description;
  }

  /// 📝 Verifica si tiene nota personal
  bool get hasPersonalNote => personalNote != null && personalNote!.trim().isNotEmpty;
}
