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
  final int forgivenessTokens; // Fichas de perdón
  final DateTime? lastForgivenessUsed;
  final int totalPoints;
  final bool isRetroactive; // 🆕 NUEVO: Flag para identificar retos retroactivos

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
    this.isRetroactive = false, // 🆕 NUEVO: Por defecto no es retroactivo
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
    'isRetroactive': isRetroactive, // 🆕 NUEVO
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
    isRetroactive: json['isRetroactive'] ?? false, // 🆕 NUEVO: Retrocompatibilidad
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
    bool? isRetroactive, // 🆕 NUEVO
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
    isRetroactive: isRetroactive ?? this.isRetroactive, // 🆕 NUEVO
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
    debugPrint('🔍 === registerChallenge ===');
    debugPrint('🔍 challengeId: $challengeId');
    debugPrint('🔍 challengeTitle: $challengeTitle');
    debugPrint('🔍 ¿Ya existe?: ${_streaks.containsKey(challengeId)}');
    
    if (!_streaks.containsKey(challengeId)) {
      _streaks[challengeId] = ChallengeStreak(
        challengeId: challengeId,
        challengeTitle: challengeTitle,
        currentStreak: 0, // 🔧 CORRECCIÓN: Siempre empezar en 0 para retos nuevos
        longestStreak: 0,
        lastConfirmedDate: null,
        confirmationHistory: const [],
        totalPoints: 0,
      );
      await _saveStreaks();
      notifyListeners();
      debugPrint('🆕 Nuevo reto registrado: $challengeTitle (racha inicial: 0)');
      debugPrint('🔍 Historial inicial vacío: ${_streaks[challengeId]!.confirmationHistory.length} entradas');
    } else {
      final existing = _streaks[challengeId]!;
      debugPrint('🔄 Reto ya existente: $challengeTitle');
      debugPrint('🔍   Racha actual: ${existing.currentStreak}');
      debugPrint('🔍   Historial: ${existing.confirmationHistory.map((d) => '${d.day}/${d.month}').join(', ')}');
    }
  }

  /// 🆕 NUEVO: Migrar datos de racha de ID legacy a UUID
  Future<void> migrateStreakToNewId(String legacyId, String newUuid) async {
    debugPrint('🔄 === migrateStreakToNewId ===');
    debugPrint('🔄 Legacy ID: $legacyId');
    debugPrint('🔄 New UUID: $newUuid');
    
    // Obtener datos del ID legacy
    final legacyStreak = _streaks[legacyId];
    if (legacyStreak == null) {
      debugPrint('⚠️ No se encontraron datos para el ID legacy: $legacyId');
      return;
    }
    
    // Verificar si el UUID ya existe
    if (_streaks.containsKey(newUuid)) {
      debugPrint('⚠️ UUID $newUuid ya existe, conservando datos existentes');
      return;
    }
    
    // Migrar datos al nuevo UUID
    _streaks[newUuid] = legacyStreak.copyWith(
      challengeId: newUuid, // Actualizar el ID interno si existe
      challengeTitle: legacyStreak.challengeTitle, // Preservar título
    );
    
    // Remover entrada legacy
    _streaks.remove(legacyId);
    
    debugPrint('✅ Migración completada: $legacyId → $newUuid');
    debugPrint('   • Racha: ${legacyStreak.currentStreak} días');
    debugPrint('   • Puntos: ${legacyStreak.totalPoints}');
    debugPrint('   • Confirmaciones: ${legacyStreak.confirmationHistory.length}');
    
    // Guardar cambios
    await _saveStreaks();
    notifyListeners();
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

    // 🔧 MEJORADO: Usar flag explícito en lugar de inferir
    int newStreak; // Declarar variable aquí

    if (current.isRetroactive) {
      debugPrint('🔄 Reto retroactivo (marcado explícitamente) - manejo especial');
      
      // Para retos retroactivos, solo agregar confirmación de HOY sin recalcular racha completa
      final newHistory = [...current.confirmationHistory, now];
      
      // Mantener la racha actual + 1 (simple incremento)
      newStreak = current.currentStreak + 1;
      
      debugPrint('🔄 Racha retroactiva mantenida: ${current.currentStreak} + 1 = $newStreak');
      
      // 🔧 CORRECCIÓN CRÍTICA: Para retos retroactivos, recalcular puntos totales
      // Los puntos deben reflejar la racha ACTUAL, no acumularse incorrectamente
      int totalPoints = 10 + (newStreak * 2);
      
      // Actualizar con recálculo total de puntos
      _streaks[challengeId] = current.copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > current.longestStreak ? newStreak : current.longestStreak,
        lastConfirmedDate: now,
        confirmationHistory: newHistory,
        totalPoints: totalPoints, // 🔧 USAR puntos totales, no sumar
      );
    } else {
      debugPrint('🔄 Reto normal - cálculo estándar');
      
      // Agregar confirmación al historial
      final newHistory = [...current.confirmationHistory, now];
      
      debugPrint('🔍 Nuevo historial: ${newHistory.map((d) => '${d.day}/${d.month}').join(', ')}');
      
      // Calcular nueva racha para retos normales
      newStreak = _calculateStreak(current.copyWith(
        confirmationHistory: newHistory,
        lastConfirmedDate: now,
      ));
      
      debugPrint('🔍 Nueva racha calculada: $newStreak');
      
      // 🔧 CORRECCIÓN CRÍTICA: Recalcular puntos totales correctamente
      // Los puntos deben reflejar la racha ACTUAL, no acumularse incorrectamente
      int totalPoints = 10 + (newStreak * 2);
      
      debugPrint('🔍 Puntos totales calculados: $totalPoints (fórmula: 10 + $newStreak * 2)');
      
      // Actualizar racha
      _streaks[challengeId] = current.copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > current.longestStreak ? newStreak : current.longestStreak,
        lastConfirmedDate: now,
        confirmationHistory: newHistory,
        totalPoints: totalPoints, // 🔧 USAR puntos totales, no sumar
      );
    }

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
  /// 🔧 CORREGIDO: Ahora usa _calculateStreak para calcular la racha correctamente
  Future<void> grantBackdatedStreak(String challengeId, String challengeTitle, DateTime startDate, int daysToGrant) async {
    debugPrint('🔄 === INICIANDO grantBackdatedStreak ===');
    debugPrint('🔄 Challenge: $challengeTitle');
    debugPrint('🔄 Start Date: $startDate');
    debugPrint('🔄 Days to Grant: $daysToGrant');
    
    // Crear historial de confirmaciones retroactivas (EXCLUYENDO HOY)
    final backdatedHistory = <DateTime>[];
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    
    for (int i = 0; i < daysToGrant; i++) {
      final confirmDate = startDate.add(Duration(days: i));
      final confirmDateNormalized = DateTime(confirmDate.year, confirmDate.month, confirmDate.day);
      
      // 🔧 CORRECCIÓN CRÍTICA: No incluir HOY en el historial retroactivo
      // HOY debe confirmarse manualmente en la ventana de confirmación
      if (!confirmDateNormalized.isAtSameMomentAs(todayNormalized)) {
        backdatedHistory.add(confirmDate);
      }
    }
    
    debugPrint('🔄 Historial retroactivo creado (SIN hoy): ${backdatedHistory.map((d) => '${d.day}/${d.month}').join(', ')}');
    debugPrint('🔄 HOY (${today.day}/${today.month}) NO incluido - requiere confirmación manual');
    
    // 🔧 CORRECCIÓN: Crear objeto temporal para calcular racha correctamente
    final tempStreak = ChallengeStreak(
      challengeId: challengeId,
      challengeTitle: challengeTitle,
      confirmationHistory: backdatedHistory,
      lastConfirmedDate: backdatedHistory.isNotEmpty ? backdatedHistory.last : null,
    );
    
    // 🔧 USAR _calculateStreak para obtener la racha correcta
    final calculatedStreak = _calculateStreak(tempStreak);
    debugPrint('🔄 Racha calculada por _calculateStreak: $calculatedStreak');
    
    // 🔧 CORRECCIÓN CRÍTICA: Puntos retroactivos = puntos finales únicamente
    // NO sumar progresivamente, solo calcular puntos de la racha final
    int pointsToAdd = 10 + (calculatedStreak * 2);
    debugPrint('🔄 Puntos calculados para racha retroactiva: $pointsToAdd (fórmula: 10 + ${calculatedStreak} * 2)');
    
    // Crear el reto con la racha calculada correctamente
    _streaks[challengeId] = ChallengeStreak(
      challengeId: challengeId,
      challengeTitle: challengeTitle,
      currentStreak: calculatedStreak, // 🔧 USAR racha calculada
      longestStreak: calculatedStreak,
      lastConfirmedDate: backdatedHistory.isNotEmpty ? backdatedHistory.last : null,
      confirmationHistory: backdatedHistory,
      totalPoints: pointsToAdd,
      isRetroactive: true, // 🆕 MARCAR como retroactivo explícitamente
    );

    await _saveStreaks();
    notifyListeners();
    
    debugPrint('🎉 ✅ Reto retroactivo creado con racha calculada: $calculatedStreak días');
    debugPrint('� ¿Completado HOY?: ${_streaks[challengeId]?.isCompletedToday ?? false} (debe ser FALSE para mostrar botón)');
    debugPrint('�🔄 === FIN grantBackdatedStreak ===');
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
      // 🔧 MEJORADO: La ficha de perdón SIMULA confirmación del día perdido
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      
      // Agregar confirmación automática del día perdido
      final newConfirmationHistory = [...current.confirmationHistory, yesterday];
      
      // Recalcular racha con la nueva confirmación simulada
      final tempStreak = current.copyWith(confirmationHistory: newConfirmationHistory);
      final newCurrentStreak = _calculateStreak(tempStreak);
      final newLongestStreak = newCurrentStreak > current.longestStreak 
          ? newCurrentStreak 
          : current.longestStreak;
      
      // 🔧 CORRECCIÓN CRÍTICA: Recalcular puntos totales correctamente
      final totalPoints = 10 + (newCurrentStreak * 2);
      
      _streaks[challengeId] = current.copyWith(
        forgivenessTokens: current.forgivenessTokens - 1,
        lastForgivenessUsed: now,
        confirmationHistory: newConfirmationHistory,
        currentStreak: newCurrentStreak,
        longestStreak: newLongestStreak,
        totalPoints: totalPoints, // 🔧 USAR puntos totales, no sumar
      );
      
      await _saveStreaks();
      notifyListeners();
      
      debugPrint('🛡️ Ficha de perdón usada para $challengeId:');
      debugPrint('   📅 Confirmación simulada: ${yesterday.day}/${yesterday.month}/${yesterday.year}');
      debugPrint('   🔥 Racha actualizada: ${current.currentStreak} → $newCurrentStreak');
      debugPrint('   ⭐ Puntos totales: $totalPoints');
      debugPrint('   🛡️ Fichas restantes: ${current.forgivenessTokens - 1}');
      return true; // Fallo perdonado Y confirmación simulada
    }

    // Fallo normal: resetear racha Y PUNTOS
    final newFailedDays = [...current.failedDays, today];
    
    _streaks[challengeId] = current.copyWith(
      currentStreak: 0,
      failedDays: newFailedDays,
      totalPoints: 0, // 🔧 RESETEAR PUNTOS cuando falla
      confirmationHistory: const [], // 🔧 LIMPIAR historial cuando falla
    );

    await _saveStreaks();
    notifyListeners();
    
    debugPrint('💔 Desafío $challengeId falló. Racha reseteada.');
    return false; // Fallo real
  }

  /// Calcular racha actual basada en el historial
  int _calculateStreak(ChallengeStreak streak) {
    debugPrint('🧮 === INICIO _calculateStreak ===');
    debugPrint('🧮 Challenge: ${streak.challengeTitle}');
    debugPrint('🧮 Historial inicial: ${streak.confirmationHistory.map((d) => '${d.day}/${d.month}').join(', ')}');
    
    if (streak.confirmationHistory.isEmpty) {
      debugPrint('🧮 Historial vacío, retornar 0');
      return 0;
    }
    
    // Obtener todas las confirmaciones únicas (sin duplicados de mismo día)
    final uniqueConfirmations = <DateTime>{};
    for (final confirmation in streak.confirmationHistory) {
      final normalizedDate = DateTime(confirmation.year, confirmation.month, confirmation.day);
      uniqueConfirmations.add(normalizedDate);
    }
    
    final sortedConfirmations = uniqueConfirmations.toList();
    sortedConfirmations.sort((a, b) => b.compareTo(a)); // Más reciente primero
    
    debugPrint('🧮 Confirmaciones únicas ordenadas: ${sortedConfirmations.map((d) => '${d.day}/${d.month}').join(', ')}');
    
    if (sortedConfirmations.isEmpty) return 0;
    
    int currentStreak = 0;
    
    // 🔧 NUEVA LÓGICA: Empezar desde la confirmación más reciente
    DateTime expectedDate = sortedConfirmations.first;
    
    debugPrint('🧮 Empezando desde la confirmación más reciente: ${expectedDate.day}/${expectedDate.month}');
    
    // Contar días consecutivos hacia atrás desde la confirmación más reciente
    for (final confirmDate in sortedConfirmations) {
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
        'averageActiveStreak': 0.0, // 🆕 NUEVO: Promedio solo de activos
        'longestOverallStreak': 0,
        'completionRate': 0.0, // 🆕 NUEVO: Tasa de finalización
      };
    }

    final totalPoints = _streaks.values
        .map((s) => s.totalPoints)
        .fold<int>(0, (a, b) => a + b);
    
    final averageStreak = _streaks.values
        .map((s) => s.currentStreak)
        .fold<double>(0, (a, b) => a + b) / _streaks.length;
    
    // 🆕 NUEVO: Promedio solo de retos activos (racha > 0)
    final activeStreaks = _streaks.values.where((s) => s.currentStreak > 0);
    final averageActiveStreak = activeStreaks.isNotEmpty 
        ? activeStreaks.map((s) => s.currentStreak).fold<double>(0, (a, b) => a + b) / activeStreaks.length
        : 0.0;
    
    final longestOverallStreak = _streaks.values
        .map((s) => s.longestStreak)
        .fold<int>(0, (a, b) => a > b ? a : b);

    // 🆕 NUEVO: Tasa de finalización (retos activos / total)
    final activeChallenges = _streaks.values.where((s) => s.currentStreak > 0).length;
    final completionRate = activeChallenges / _streaks.length;

    return {
      'totalChallenges': _streaks.length,
      'activeChallenges': activeChallenges,
      'totalPoints': totalPoints,
      'averageStreak': averageStreak,
      'averageActiveStreak': averageActiveStreak, // 🆕 NUEVO
      'longestOverallStreak': longestOverallStreak,
      'completionRate': completionRate, // 🆕 NUEVO
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

  /// 🔧 DEBUG: Resetear racha específica para testing
  Future<void> debugResetStreak(String challengeId) async {
    if (_streaks.containsKey(challengeId)) {
      final current = _streaks[challengeId]!;
      _streaks[challengeId] = current.copyWith(
        currentStreak: 0,
        longestStreak: 0,
        lastConfirmedDate: null,
        confirmationHistory: const [],
        totalPoints: 0,
      );
      await _saveStreaks();
      notifyListeners();
      debugPrint('🔧 DEBUG: Racha reseteada para $challengeId');
    }
  }

  /// 🔧 DEBUG: Mostrar estado completo de un reto
  void debugShowStreakState(String challengeId) {
    if (_streaks.containsKey(challengeId)) {
      final streak = _streaks[challengeId]!;
      debugPrint('🔍 === ESTADO COMPLETO DE $challengeId ===');
      debugPrint('🔍 Título: ${streak.challengeTitle}');
      debugPrint('🔍 Racha actual: ${streak.currentStreak}');
      debugPrint('🔍 Racha más larga: ${streak.longestStreak}');
      debugPrint('🔍 Última confirmación: ${streak.lastConfirmedDate}');
      debugPrint('🔍 Historial (${streak.confirmationHistory.length} entradas):');
      for (int i = 0; i < streak.confirmationHistory.length; i++) {
        final date = streak.confirmationHistory[i];
        debugPrint('🔍   [$i] ${date.day}/${date.month}/${date.year}');
      }
      debugPrint('🔍 Puntos totales: ${streak.totalPoints}');
      debugPrint('🔍 ===============================');
    } else {
      debugPrint('🔍 Reto $challengeId no encontrado');
    }
  }

  /// Migrar desde el sistema global de rachas
  Future<void> migrateFromGlobalStreak(Map<String, String> challengeIdToTitle, int globalStreak) async {
    debugPrint('🔄 Iniciando migración desde racha global: $globalStreak días');
    
    for (final entry in challengeIdToTitle.entries) {
      final challengeId = entry.key;
      final challengeTitle = entry.value;
      
      if (!_streaks.containsKey(challengeId)) {
        // 🔧 CORRECCIÓN: Solo crear racha migrada si el globalStreak es significativo
        if (globalStreak > 0) {
          debugPrint('✅ Migrando reto "$challengeTitle" con $globalStreak días de racha');
          
          // Crear racha inicial basada en la racha global
          _streaks[challengeId] = ChallengeStreak(
            challengeId: challengeId,
            challengeTitle: challengeTitle,
            currentStreak: globalStreak,
            longestStreak: globalStreak,
            lastConfirmedDate: globalStreak > 0 ? DateTime.now() : null,
            confirmationHistory: [], // Sin historial específico en migración
            totalPoints: globalStreak * 12, // Puntos estimados
          );
        } else {
          debugPrint('⚠️ Omitiendo migración para "$challengeTitle" (globalStreak: $globalStreak)');
          
          // Crear reto nuevo sin racha previa
          _streaks[challengeId] = ChallengeStreak(
            challengeId: challengeId,
            challengeTitle: challengeTitle,
            currentStreak: 0,
            longestStreak: 0,
            lastConfirmedDate: null,
            confirmationHistory: const [],
            totalPoints: 0,
          );
        }
      } else {
        debugPrint('🔄 Reto "$challengeTitle" ya existe, mantener datos actuales');
      }
    }
    
    await _saveStreaks();
    notifyListeners();
    debugPrint('🔄 Migración desde racha global completada');
  }

  // 🚨 MÉTODO DE EMERGENCIA: Reset completo de datos corruptos
  Future<void> emergencyResetCorruptedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    debugPrint('🚨 EMERGENCIA: Iniciando reset de datos corruptos...');
    
    // 1. Resetear todos los datos de rachas individuales
    await prefs.remove('individual_streaks');
    debugPrint('✅ Rachas individuales eliminadas');
    
    // 2. Resetear flag de migración para permitir nueva migración limpia
    await prefs.setBool('has_migrated_individual_streaks', false);
    debugPrint('✅ Flag de migración reseteado');
    
    // 3. Verificar si hay rachas globales para preservar
    final globalStreak = prefs.getInt('global_streak') ?? 0;
    debugPrint('ℹ️ Racha global encontrada: $globalStreak');
    
    // 4. Limpiar caché local
    _streaks.clear();
    
    debugPrint('🚨 EMERGENCIA: Reset completado. Necesita restart de la app.');
    notifyListeners();
  }

  // 🔧 MÉTODO QUIRÚRGICO: Solo resetear retos problemáticos específicos
  Future<void> surgicalResetKnownBugs() async {
    debugPrint('🔧 QUIRÚRGICO: Iniciando corrección de retos problemáticos...');
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<String> suspiciousChallenges = [];
    
    // Buscar retos con lastConfirmedDate sospechosos
    for (final entry in _streaks.entries) {
      final challengeId = entry.key;
      final streak = entry.value;
      
      if (streak.lastConfirmedDate != null) {
        final lastConfirmed = streak.lastConfirmedDate!;
        final confirmedDate = DateTime(lastConfirmed.year, lastConfirmed.month, lastConfirmed.day);
        
        // Si la última confirmación es HOY y la racha > 0, es sospechoso
        if (confirmedDate.isAtSameMomentAs(today) && streak.currentStreak > 0) {
          suspiciousChallenges.add(challengeId);
          debugPrint('🚨 Reto sospechoso encontrado: $challengeId - Racha: ${streak.currentStreak} - Fecha: ${streak.lastConfirmedDate}');
        }
      }
    }
    
    // Resetear solo los retos sospechosos
    for (final challengeId in suspiciousChallenges) {
      final currentStreak = _streaks[challengeId]!;
      _streaks[challengeId] = currentStreak.copyWith(
        currentStreak: 0,
        lastConfirmedDate: null,
        // Preservar longestStreak y totalPoints
      );
      debugPrint('✅ Reset quirúrgico aplicado a: $challengeId');
    }
    
    // Guardar cambios
    await _saveStreaks();
    notifyListeners();
    debugPrint('🔧 QUIRÚRGICO: Corrección completada. ${suspiciousChallenges.length} retos corregidos.');
  }

  // 🔍 MÉTODO DE DIAGNÓSTICO: Mostrar estado detallado de todos los retos
  void diagnosticShowAllStreaks() {
    debugPrint('🔍 === DIAGNÓSTICO: Estado de todos los retos ===');
    
    if (_streaks.isEmpty) {
      debugPrint('📭 No hay retos registrados');
      return;
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    for (final entry in _streaks.entries) {
      final challengeId = entry.key;
      final streak = entry.value;
      
      debugPrint('🎯 Reto: $challengeId (${streak.challengeTitle})');
      debugPrint('   📊 Racha actual: ${streak.currentStreak}');
      debugPrint('   🏆 Mejor racha: ${streak.longestStreak}');
      debugPrint('   📅 Última confirmación: ${streak.lastConfirmedDate}');
      debugPrint('   💯 Puntos totales: ${streak.totalPoints}');
      
      if (streak.lastConfirmedDate != null) {
        final lastConfirmed = streak.lastConfirmedDate!;
        final confirmedDate = DateTime(lastConfirmed.year, lastConfirmed.month, lastConfirmed.day);
        final daysDiff = today.difference(confirmedDate).inDays;
        
        if (confirmedDate.isAtSameMomentAs(today)) {
          debugPrint('   ⚠️ SOSPECHOSO: Última confirmación es HOY con racha > 0');
        } else if (daysDiff > 0) {
          debugPrint('   📊 Días desde última confirmación: $daysDiff');
        }
      }
      
      debugPrint('   ---');
    }
    
    debugPrint('🔍 === FIN DIAGNÓSTICO ===');
  }
}
