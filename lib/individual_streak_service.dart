import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Información de racha individual para un desafío específico
class ChallengeStreak {
  final String challengeId;
  final String challengeTitle;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastConfirmedDate;
  final List<DateTime> confirmationHistory;
  final List<DateTime> failedDays;
  final int forgivenessTokens; // Nuevo: fichas de perdón
  final DateTime? lastForgivenessUsed;
  final int totalPoints;

  ChallengeStreak({
    required this.challengeId,
    required this.challengeTitle,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastConfirmedDate,
    this.confirmationHistory = const [],
    this.failedDays = const [],
    this.forgivenessTokens = 2, // Iniciar con 2 fichas de perdón
    this.lastForgivenessUsed,
    this.totalPoints = 0,
  });

  Map<String, dynamic> toJson() => {
    'challengeId': challengeId,
    'challengeTitle': challengeTitle,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastConfirmedDate': lastConfirmedDate?.toIso8601String(),
    'confirmationHistory': confirmationHistory.map((d) => d.toIso8601String()).toList(),
    'failedDays': failedDays.map((d) => d.toIso8601String()).toList(),
    'forgivenessTokens': forgivenessTokens,
    'lastForgivenessUsed': lastForgivenessUsed?.toIso8601String(),
    'totalPoints': totalPoints,
  };

  static ChallengeStreak fromJson(Map<String, dynamic> json) => ChallengeStreak(
    challengeId: json['challengeId'] ?? '',
    challengeTitle: json['challengeTitle'] ?? '',
    currentStreak: json['currentStreak'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    lastConfirmedDate: json['lastConfirmedDate'] != null 
        ? DateTime.parse(json['lastConfirmedDate']) 
        : null,
    confirmationHistory: (json['confirmationHistory'] as List<dynamic>? ?? [])
        .map((d) => DateTime.parse(d.toString()))
        .toList(),
    failedDays: (json['failedDays'] as List<dynamic>? ?? [])
        .map((d) => DateTime.parse(d.toString()))
        .toList(),
    forgivenessTokens: json['forgivenessTokens'] ?? 2,
    lastForgivenessUsed: json['lastForgivenessUsed'] != null 
        ? DateTime.parse(json['lastForgivenessUsed']) 
        : null,
    totalPoints: json['totalPoints'] ?? 0,
  );

  ChallengeStreak copyWith({
    String? challengeId,
    String? challengeTitle,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastConfirmedDate,
    List<DateTime>? confirmationHistory,
    List<DateTime>? failedDays,
    int? forgivenessTokens,
    DateTime? lastForgivenessUsed,
    int? totalPoints,
  }) => ChallengeStreak(
    challengeId: challengeId ?? this.challengeId,
    challengeTitle: challengeTitle ?? this.challengeTitle,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    lastConfirmedDate: lastConfirmedDate ?? this.lastConfirmedDate,
    confirmationHistory: confirmationHistory ?? this.confirmationHistory,
    failedDays: failedDays ?? this.failedDays,
    forgivenessTokens: forgivenessTokens ?? this.forgivenessTokens,
    lastForgivenessUsed: lastForgivenessUsed ?? this.lastForgivenessUsed,
    totalPoints: totalPoints ?? this.totalPoints,
  );

  /// Verifica si el desafío ha sido completado hoy
  bool get isCompletedToday {
    if (lastConfirmedDate == null) return false;
    final today = DateTime.now();
    final lastConfirmed = lastConfirmedDate!;
    return lastConfirmed.year == today.year &&
           lastConfirmed.month == today.month &&
           lastConfirmed.day == today.day;
  }

  /// Verifica si el usuario puede usar una ficha de perdón
  bool get canUseForgiveness {
    if (forgivenessTokens <= 0) return false;
    
    // Solo se puede usar una ficha por día
    if (lastForgivenessUsed != null) {
      final today = DateTime.now();
      final lastUsed = lastForgivenessUsed!;
      if (lastUsed.year == today.year &&
          lastUsed.month == today.month &&
          lastUsed.day == today.day) {
        return false;
      }
    }
    
    return true;
  }

  /// Calcula los días consecutivos sin fallar
  int get consecutiveDaysWithoutFailure {
    if (confirmationHistory.isEmpty) return 0;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;

    // Revisar hacia atrás desde hoy
    for (int i = 0; i <= currentStreak; i++) {
      final checkDate = today.subtract(Duration(days: i));
      
      // Si hay un fallo en esta fecha, romper
      final hasFailed = failedDays.any((failDate) {
        final failed = DateTime(failDate.year, failDate.month, failDate.day);
        return failed.isAtSameMomentAs(checkDate);
      });
      
      if (hasFailed) break;
      
      // Si hay confirmación en esta fecha, contar
      final hasConfirmation = confirmationHistory.any((confirmation) {
        final confirmed = DateTime(confirmation.year, confirmation.month, confirmation.day);
        return confirmed.isAtSameMomentAs(checkDate);
      });

      if (hasConfirmation || i == 0) { // Incluir hoy aunque no esté confirmado aún
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}

/// Servicio para manejar rachas individuales por desafío
class IndividualStreakService extends ChangeNotifier {
  static final IndividualStreakService _instance = IndividualStreakService._internal();
  factory IndividualStreakService() => _instance;
  IndividualStreakService._internal();

  static IndividualStreakService get instance => _instance;

  Map<String, ChallengeStreak> _streaks = {};
  Map<String, ChallengeStreak> get streaks => Map.unmodifiable(_streaks);

  /// Cargar rachas desde SharedPreferences
  Future<void> loadStreaks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('individual_streaks');
      if (jsonString != null) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        _streaks = json.map((key, value) => 
            MapEntry(key, ChallengeStreak.fromJson(value)));
      }
    } catch (e) {
      debugPrint('❌ Error loading individual streaks: $e');
      _streaks = {};
    }
    notifyListeners();
  }

  /// Guardar rachas en SharedPreferences
  Future<void> _saveStreaks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = _streaks.map((key, value) => 
          MapEntry(key, value.toJson()));
      final jsonString = jsonEncode(json);
      await prefs.setString('individual_streaks', jsonString);
    } catch (e) {
      debugPrint('❌ Error saving individual streaks: $e');
    }
  }

  /// Registrar o crear un nuevo desafío
  Future<void> registerChallenge(String challengeId, String challengeTitle) async {
    if (!_streaks.containsKey(challengeId)) {
      _streaks[challengeId] = ChallengeStreak(
        challengeId: challengeId,
        challengeTitle: challengeTitle,
      );
      await _saveStreaks();
      notifyListeners();
    }
  }

  /// Confirmar un desafío (mantener/aumentar racha)
  Future<void> confirmChallenge(String challengeId, String challengeTitle) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Asegurar que el desafío existe
    await registerChallenge(challengeId, challengeTitle);
    
    final current = _streaks[challengeId]!;
    
    // No permitir confirmar dos veces el mismo día
    if (current.isCompletedToday) {
      debugPrint('⚠️ Desafío $challengeId ya confirmado hoy');
      return;
    }

    // Agregar confirmación al historial
    final newHistory = [...current.confirmationHistory, now];
    
    // Calcular nueva racha
    int newStreak = _calculateStreak(current.copyWith(
      confirmationHistory: newHistory,
      lastConfirmedDate: now,
    ));
    
    // Calcular puntos con bonus de racha
    int pointsToAdd = 10 + (newStreak * 2);
    
    // Actualizar racha
    _streaks[challengeId] = current.copyWith(
      currentStreak: newStreak,
      longestStreak: newStreak > current.longestStreak ? newStreak : current.longestStreak,
      lastConfirmedDate: now,
      confirmationHistory: newHistory,
      totalPoints: current.totalPoints + pointsToAdd,
    );

    await _saveStreaks();
    notifyListeners();
    
    debugPrint('✅ Desafío $challengeId confirmado. Racha: $newStreak días');
  }

  /// Otorgar racha retroactiva para retos registrados tarde (FUNCIÓN ESPECIAL)
  Future<void> grantBackdatedStreak(String challengeId, String challengeTitle, DateTime startDate, int daysToGrant) async {
    // Asegurar que el desafío existe
    await registerChallenge(challengeId, challengeTitle);
    
    final current = _streaks[challengeId]!;
    
    // Crear historial de confirmaciones retroactivas
    final backdatedHistory = <DateTime>[];
    for (int i = 0; i < daysToGrant; i++) {
      final confirmDate = startDate.add(Duration(days: i));
      backdatedHistory.add(confirmDate);
    }
    
    // Combinar con historial existente y ordenar
    final combinedHistory = [...current.confirmationHistory, ...backdatedHistory];
    combinedHistory.sort();
    
    // Calcular nueva racha basada en el historial completo
    final tempStreak = current.copyWith(
      confirmationHistory: combinedHistory,
      lastConfirmedDate: backdatedHistory.isNotEmpty ? backdatedHistory.last : current.lastConfirmedDate,
    );
    final newStreak = _calculateStreak(tempStreak);
    
    // Calcular puntos totales
    final pointsToAdd = daysToGrant * (10 + (daysToGrant * 2));
    
    // Actualizar racha con datos retroactivos
    _streaks[challengeId] = current.copyWith(
      currentStreak: newStreak,
      longestStreak: newStreak > current.longestStreak ? newStreak : current.longestStreak,
      lastConfirmedDate: backdatedHistory.isNotEmpty ? backdatedHistory.last : current.lastConfirmedDate,
      confirmationHistory: combinedHistory,
      totalPoints: current.totalPoints + pointsToAdd,
    );

    await _saveStreaks();
    notifyListeners();
    
    debugPrint('🎉 Racha retroactiva otorgada: $daysToGrant días para $challengeId. Nueva racha: $newStreak');
  }

  /// Fallar en un desafío (puede usar ficha de perdón)
  Future<bool> failChallenge(String challengeId, String challengeTitle, {bool useForgiveness = false}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Asegurar que el desafío existe
    await registerChallenge(challengeId, challengeTitle);
    
    final current = _streaks[challengeId]!;

    // Intentar usar ficha de perdón si se solicita
    if (useForgiveness && current.canUseForgiveness) {
      _streaks[challengeId] = current.copyWith(
        forgivenessTokens: current.forgivenessTokens - 1,
        lastForgivenessUsed: now,
      );
      
      await _saveStreaks();
      notifyListeners();
      
      debugPrint('🛡️ Ficha de perdón usada para $challengeId. Fichas restantes: ${current.forgivenessTokens - 1}');
      return true; // Fallo perdonado
    }

    // Fallo normal: resetear racha
    final newFailedDays = [...current.failedDays, today];
    
    _streaks[challengeId] = current.copyWith(
      currentStreak: 0,
      failedDays: newFailedDays,
    );

    await _saveStreaks();
    notifyListeners();
    
    debugPrint('💔 Desafío $challengeId falló. Racha reseteada.');
    return false; // Fallo real
  }

  /// Calcular racha actual basada en el historial
  int _calculateStreak(ChallengeStreak streak) {
    if (streak.confirmationHistory.isEmpty) return 1;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int currentStreak = 1;

    // Revisar hacia atrás desde hoy
    for (int i = 1; i <= 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      
      // Si hay un fallo en esta fecha, romper la racha
      final hasFailed = streak.failedDays.any((failDate) {
        final failed = DateTime(failDate.year, failDate.month, failDate.day);
        return failed.isAtSameMomentAs(checkDate);
      });
      
      if (hasFailed) {
        break;
      }
      
      // Si hay confirmación en esta fecha, continuar racha
      final hasConfirmation = streak.confirmationHistory.any((confirmation) {
        final confirmed = DateTime(confirmation.year, confirmation.month, confirmation.day);
        return confirmed.isAtSameMomentAs(checkDate);
      });

      if (hasConfirmation) {
        currentStreak++;
      } else {
        break;
      }
    }

    return currentStreak;
  }

  /// Obtener racha de un desafío específico
  ChallengeStreak? getStreak(String challengeId) {
    return _streaks[challengeId];
  }

  /// Regenerar fichas de perdón (llamar diariamente o semanalmente)
  Future<void> regenerateForgivenessTokens() async {
    bool hasChanges = false;
    
    for (final entry in _streaks.entries) {
      final streak = entry.value;
      
      // Regenerar 1 ficha por semana (máximo 3)
      if (streak.forgivenessTokens < 3) {
        final lastUsed = streak.lastForgivenessUsed;
        if (lastUsed == null || 
            DateTime.now().difference(lastUsed).inDays >= 7) {
          
          _streaks[entry.key] = streak.copyWith(
            forgivenessTokens: (streak.forgivenessTokens + 1).clamp(0, 3),
          );
          hasChanges = true;
        }
      }
    }
    
    if (hasChanges) {
      await _saveStreaks();
      notifyListeners();
      debugPrint('🔄 Fichas de perdón regeneradas');
    }
  }

  /// Obtener estadísticas globales de todos los desafíos
  Map<String, dynamic> getGlobalStats() {
    if (_streaks.isEmpty) {
      return {
        'totalChallenges': 0,
        'activeChallenges': 0,
        'totalPoints': 0,
        'averageStreak': 0.0,
        'longestOverallStreak': 0,
      };
    }

    final totalPoints = _streaks.values
        .map((s) => s.totalPoints)
        .fold<int>(0, (a, b) => a + b);
    
    final averageStreak = _streaks.values
        .map((s) => s.currentStreak)
        .fold<double>(0, (a, b) => a + b) / _streaks.length;
    
    final longestOverallStreak = _streaks.values
        .map((s) => s.longestStreak)
        .fold<int>(0, (a, b) => a > b ? a : b);

    return {
      'totalChallenges': _streaks.length,
      'activeChallenges': _streaks.values.where((s) => s.currentStreak > 0).length,
      'totalPoints': totalPoints,
      'averageStreak': averageStreak,
      'longestOverallStreak': longestOverallStreak,
    };
  }

  /// Eliminar racha de un desafío
  Future<void> removeChallenge(String challengeId) async {
    _streaks.remove(challengeId);
    await _saveStreaks();
    notifyListeners();
  }

  /// Resetear todas las rachas (para desarrollo)
  Future<void> resetAllStreaks() async {
    _streaks.clear();
    await _saveStreaks();
    notifyListeners();
  }

  /// Migrar desde el sistema global de rachas
  Future<void> migrateFromGlobalStreak(Map<String, String> challengeIdToTitle, int globalStreak) async {
    for (final entry in challengeIdToTitle.entries) {
      final challengeId = entry.key;
      final challengeTitle = entry.value;
      
      if (!_streaks.containsKey(challengeId)) {
        // Crear racha inicial basada en la racha global
        _streaks[challengeId] = ChallengeStreak(
          challengeId: challengeId,
          challengeTitle: challengeTitle,
          currentStreak: globalStreak,
          longestStreak: globalStreak,
          lastConfirmedDate: globalStreak > 0 ? DateTime.now() : null,
          totalPoints: globalStreak * 12, // Puntos estimados
        );
      }
    }
    
    await _saveStreaks();
    notifyListeners();
    debugPrint('🔄 Migración desde racha global completada');
  }
}
