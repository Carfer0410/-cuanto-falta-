/// Modelo para estrategias de retos/desafíos
class ChallengeStrategy {
  final int id;
  final int challengeId;
  final String title;
  final String description;
  final String category; // daily, weekly, monthly, etc.
  final int priority; // 1-5, donde 1 es más importante
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  ChallengeStrategy({
    this.id = 0,
    required this.challengeId,
    required this.title,
    required this.description,
    required this.category,
    this.priority = 3,
    this.isCompleted = false,
    this.completedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convertir a Map para la base de datos
  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'challengeId': challengeId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Crear desde Map de la base de datos
  factory ChallengeStrategy.fromMap(Map<String, dynamic> map) {
    return ChallengeStrategy(
      id: map['id'] ?? 0,
      challengeId: map['challengeId'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      priority: map['priority'] ?? 3,
      isCompleted: (map['isCompleted'] ?? 0) == 1,
      completedAt: map['completedAt'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
        : null,
      createdAt: map['createdAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
        : DateTime.now(),
    );
  }

  /// Crear copia con cambios
  ChallengeStrategy copyWith({
    int? id,
    int? challengeId,
    String? title,
    String? description,
    String? category,
    int? priority,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return ChallengeStrategy(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Obtener emoji basado en categoría
  String get categoryEmoji {
    switch (category.toLowerCase()) {
      case 'daily':
        return '📅';
      case 'weekly':
        return '📊';
      case 'monthly':
        return '📈';
      case 'milestone':
        return '🎯';
      case 'preparation':
        return '🛠️';
      case 'motivation':
        return '💪';
      case 'tracking':
        return '📋';
      case 'reward':
        return '🎁';
      default:
        return '✨';
    }
  }

  /// Obtener color basado en prioridad
  int get priorityColor {
    switch (priority) {
      case 1:
        return 0xFFE53E3E; // Rojo - Crítico
      case 2:
        return 0xFFFF8C00; // Naranja - Alto
      case 3:
        return 0xFFFFC107; // Amarillo - Medio
      case 4:
        return 0xFF4CAF50; // Verde - Bajo
      case 5:
        return 0xFF9E9E9E; // Gris - Opcional
      default:
        return 0xFF2196F3; // Azul - Default
    }
  }

  /// Obtener texto de prioridad
  String get priorityText {
    switch (priority) {
      case 1:
        return 'Crítico';
      case 2:
        return 'Alto';
      case 3:
        return 'Medio';
      case 4:
        return 'Bajo';
      case 5:
        return 'Opcional';
      default:
        return 'Normal';
    }
  }

  @override
  String toString() {
    return 'ChallengeStrategy{id: $id, challengeId: $challengeId, title: $title, category: $category, priority: $priority, isCompleted: $isCompleted}';
  }
}
