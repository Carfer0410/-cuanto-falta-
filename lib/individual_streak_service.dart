import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'milestone_notification_service.dart';

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
  Future<void> confirmChallenge(String challengeId, String challengeTitle, {bool isNegativeHabit = false}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    debugPrint('🔍 === INICIO confirmChallenge ===');
    debugPrint('🔍 Challenge ID: $challengeId');
    debugPrint('🔍 Challenge Title: $challengeTitle');
    debugPrint('🔍 Is Negative Habit: $isNegativeHabit');
    debugPrint('🔍 Fecha de confirmación: ${today.day}/${today.month}/${today.year}');

    // Asegurar que el desafío existe
    await registerChallenge(challengeId, challengeTitle);
    
    final current = _streaks[challengeId]!;
    
    debugPrint('🔍 Estado ANTES de confirmar:');
    debugPrint('🔍   Racha actual: ${current.currentStreak}');
    debugPrint('🔍   Última confirmación: ${current.lastConfirmedDate}');
    debugPrint('🔍   Historial confirmaciones: ${current.confirmationHistory.map((d) => '${d.day}/${d.month}').join(', ')}');
    debugPrint('🔍   isCompletedToday: ${current.isCompletedToday}');
    
    // No permitir confirmar dos veces el mismo día
    if (current.isCompletedToday) {
      debugPrint('⚠️ Desafío $challengeId ya confirmado hoy');
      return;
    }

    // Agregar confirmación al historial
    final newHistory = [...current.confirmationHistory, now];
    
    debugPrint('🔍 Nuevo historial: ${newHistory.map((d) => '${d.day}/${d.month}').join(', ')}');
    
    // Calcular nueva racha
    int newStreak = _calculateStreak(current.copyWith(
      confirmationHistory: newHistory,
      lastConfirmedDate: now,
    ));
    
    debugPrint('🔍 Nueva racha calculada: $newStreak');
    
    // Calcular puntos con bonus de racha
    int pointsToAdd = 10 + (newStreak * 2);
    
    debugPrint('🔍 Puntos a agregar: $pointsToAdd');
    
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
    
    // 🆕 NUEVO: Verificar y enviar notificaciones de hitos
    await MilestoneNotificationService.checkMilestoneNotification(
      challengeId,
      challengeTitle,
      newStreak,
      isNegativeHabit: isNegativeHabit,
    );
    
    debugPrint('🔍 Estado DESPUÉS de confirmar:');
    final updated = _streaks[challengeId]!;
    debugPrint('🔍   Racha actualizada: ${updated.currentStreak}');
    debugPrint('🔍   Historial final: ${updated.confirmationHistory.map((d) => '${d.day}/${d.month}').join(', ')}');
    debugPrint('✅ Desafío $challengeId confirmado. Racha: $newStreak días');
    debugPrint('🔍 === FIN confirmChallenge ===');
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
    debugPrint('🧮 === INICIO _calculateStreak ===');
    
    if (streak.confirmationHistory.isEmpty) {
      debugPrint('🧮 Historial vacío, retornar 0');
      return 0;
    }
    
    // Simplificado: contar todas las confirmaciones únicas consecutivas
    // empezando desde la fecha más reciente hacia atrás
    
    final sortedConfirmations = [...streak.confirmationHistory];
    sortedConfirmations.sort((a, b) => b.compareTo(a)); // Más reciente primero
    
    debugPrint('🧮 Confirmaciones ordenadas: ${sortedConfirmations.map((d) => '${d.day}/${d.month}').join(', ')}');
    
    if (sortedConfirmations.isEmpty) return 0;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int currentStreak = 0;
    DateTime expectedDate = today;
    
    debugPrint('🧮 Empezando desde hoy: ${expectedDate.day}/${expectedDate.month}');
    
    // Revisar confirmaciones desde hoy hacia atrás
    for (final confirmation in sortedConfirmations) {
      final confirmDate = DateTime(confirmation.year, confirmation.month, confirmation.day);
      
      debugPrint('🧮 Verificando: ${confirmDate.day}/${confirmDate.month}');
      debugPrint('🧮   Esperada: ${expectedDate.day}/${expectedDate.month}');
      
      // Si hay un fallo registrado para esta fecha, parar
      final hasFailed = streak.failedDays.any((failDate) {
        final failed = DateTime(failDate.year, failDate.month, failDate.day);
        return failed.isAtSameMomentAs(confirmDate);
      });
      
      if (hasFailed) {
        debugPrint('🧮   ❌ Hay fallo registrado, parar');
        break;
      }
      
      // Si esta confirmación es para la fecha que esperamos, continuar racha
      if (confirmDate.isAtSameMomentAs(expectedDate)) {
        currentStreak++;
        expectedDate = expectedDate.subtract(Duration(days: 1));
        debugPrint('🧮   ✅ Racha aumenta a: $currentStreak');
        debugPrint('🧮   Siguiente esperada: ${expectedDate.day}/${expectedDate.month}');
      } else if (currentStreak == 0) {
        // Si es la primera confirmación pero no es de hoy, empezar racha desde ahí
        currentStreak = 1;
        expectedDate = confirmDate.subtract(Duration(days: 1));
        debugPrint('🧮   🔄 Primera confirmación no es hoy, empezar desde aquí: $currentStreak');
        debugPrint('🧮   Siguiente esperada: ${expectedDate.day}/${expectedDate.month}');
      } else {
        // Hueco en la racha, parar
        debugPrint('🧮   ❌ Hueco en la racha, parar');
        break;
      }
    }

    debugPrint('🧮 Racha final calculada: $currentStreak');
    debugPrint('🧮 === FIN _calculateStreak ===');
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
    
    // 🆕 NUEVO: Limpiar datos de hitos asociados
    await MilestoneNotificationService.clearMilestoneData(challengeId);
    
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
