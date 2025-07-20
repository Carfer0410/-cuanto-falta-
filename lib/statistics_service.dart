import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class UserStatistics {
  final int totalEvents;
  final int totalChallenges;
  final int activeChallenges;
  final int completedChallenges;
  final int currentStreak;
  final int longestStreak;
  final Map<String, int> challengesByCategory;
  final Map<String, int> eventsByCategory;
  final List<DateTime> recentActivity;
  final int totalPoints;

  UserStatistics({
    this.totalEvents = 0,
    this.totalChallenges = 0,
    this.activeChallenges = 0,
    this.completedChallenges = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.challengesByCategory = const {},
    this.eventsByCategory = const {},
    this.recentActivity = const [],
    this.totalPoints = 0,
  });

  Map<String, dynamic> toJson() => {
    'totalEvents': totalEvents,
    'totalChallenges': totalChallenges,
    'activeChallenges': activeChallenges,
    'completedChallenges': completedChallenges,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'challengesByCategory': challengesByCategory,
    'eventsByCategory': eventsByCategory,
    'recentActivity': recentActivity.map((d) => d.toIso8601String()).toList(),
    'totalPoints': totalPoints,
  };

  static UserStatistics fromJson(Map<String, dynamic> json) => UserStatistics(
    totalEvents: json['totalEvents'] ?? 0,
    totalChallenges: json['totalChallenges'] ?? 0,
    activeChallenges: json['activeChallenges'] ?? 0,
    completedChallenges: json['completedChallenges'] ?? 0,
    currentStreak: json['currentStreak'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    challengesByCategory: Map<String, int>.from(json['challengesByCategory'] ?? {}),
    eventsByCategory: Map<String, int>.from(json['eventsByCategory'] ?? {}),
    recentActivity: (json['recentActivity'] as List<dynamic>? ?? [])
        .map((d) => DateTime.parse(d.toString()))
        .toList(),
    totalPoints: json['totalPoints'] ?? 0,
  );

  UserStatistics copyWith({
    int? totalEvents,
    int? totalChallenges,
    int? activeChallenges,
    int? completedChallenges,
    int? currentStreak,
    int? longestStreak,
    Map<String, int>? challengesByCategory,
    Map<String, int>? eventsByCategory,
    List<DateTime>? recentActivity,
    int? totalPoints,
  }) => UserStatistics(
    totalEvents: totalEvents ?? this.totalEvents,
    totalChallenges: totalChallenges ?? this.totalChallenges,
    activeChallenges: activeChallenges ?? this.activeChallenges,
    completedChallenges: completedChallenges ?? this.completedChallenges,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    challengesByCategory: challengesByCategory ?? this.challengesByCategory,
    eventsByCategory: eventsByCategory ?? this.eventsByCategory,
    recentActivity: recentActivity ?? this.recentActivity,
    totalPoints: totalPoints ?? this.totalPoints,
  );
}

class StatisticsService extends ChangeNotifier {
  static final StatisticsService _instance = StatisticsService._internal();
  factory StatisticsService() => _instance;
  StatisticsService._internal();

  static StatisticsService get instance => _instance;

  UserStatistics _statistics = UserStatistics();
  UserStatistics get statistics => _statistics;

  // Cargar estadísticas desde SharedPreferences
  Future<void> loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('user_statistics');
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        _statistics = UserStatistics.fromJson(json);
      }
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      _statistics = UserStatistics();
    }
    notifyListeners();
  }

  // Guardar estadísticas en SharedPreferences
  Future<void> _saveStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_statistics.toJson());
      await prefs.setString('user_statistics', jsonString);
    } catch (e) {
      debugPrint('Error saving statistics: $e');
    }
  }

  // Registrar una nueva actividad de evento
  Future<void> recordEventActivity() async {
    final now = DateTime.now();
    final newActivity = [..._statistics.recentActivity, now];
    
    // Mantener solo los últimos 30 días de actividad
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final filteredActivity = newActivity
        .where((date) => date.isAfter(thirtyDaysAgo))
        .toList();

    _statistics = _statistics.copyWith(
      totalEvents: _statistics.totalEvents + 1,
      recentActivity: filteredActivity,
      totalPoints: _statistics.totalPoints + 5, // 5 puntos por evento
    );

    await _saveStatistics();
    notifyListeners();
  }

  // Registrar actividad de reto confirmado
  Future<void> recordChallengeConfirmation() async {
    final now = DateTime.now();
    
    // Calcular racha actual
    int newStreak = _calculateCurrentStreak();
    int newLongestStreak = newStreak > _statistics.longestStreak 
        ? newStreak 
        : _statistics.longestStreak;

    final newActivity = [..._statistics.recentActivity, now];
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final filteredActivity = newActivity
        .where((date) => date.isAfter(thirtyDaysAgo))
        .toList();

    // Puntos basados en la racha
    int pointsToAdd = 10 + (newStreak * 2); // Base 10 + bonus por racha

    _statistics = _statistics.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      recentActivity: filteredActivity,
      totalPoints: _statistics.totalPoints + pointsToAdd,
    );

    await _saveStatistics();
    notifyListeners();
  }

  // Calcular racha actual basada en actividad reciente
  int _calculateCurrentStreak() {
    if (_statistics.recentActivity.isEmpty) return 1;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 1;

    // Buscar hacia atrás días consecutivos con actividad
    for (int i = 1; i <= 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final hasActivity = _statistics.recentActivity.any((activity) {
        final activityDate = DateTime(activity.year, activity.month, activity.day);
        return activityDate.isAtSameMomentAs(checkDate);
      });

      if (hasActivity) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  // Actualizar contadores de retos
  Future<void> updateChallengeStats(int active, int total) async {
    _statistics = _statistics.copyWith(
      activeChallenges: active,
      totalChallenges: total,
      completedChallenges: total - active,
    );

    await _saveStatistics();
    notifyListeners();
  }

  // Obtener estadísticas de actividad semanal
  Map<String, int> getWeeklyActivity() {
    final now = DateTime.now();
    final Map<String, int> weeklyData = {
      'Lun': 0, 'Mar': 0, 'Mié': 0, 'Jue': 0, 'Vie': 0, 'Sáb': 0, 'Dom': 0,
    };

    final weekDays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    
    for (final activity in _statistics.recentActivity) {
      final daysDifference = now.difference(activity).inDays;
      if (daysDifference <= 7) {
        final weekday = activity.weekday - 1; // Ajustar para que 0 = Lunes
        weeklyData[weekDays[weekday]] = (weeklyData[weekDays[weekday]] ?? 0) + 1;
      }
    }

    return weeklyData;
  }

  // Resetear estadísticas (para desarrollo o configuración)
  Future<void> resetStatistics() async {
    _statistics = UserStatistics();
    await _saveStatistics();
    notifyListeners();
  }

  // Obtener progreso hacia el próximo logro
  Map<String, dynamic> getNextAchievementProgress() {
    if (_statistics.currentStreak < 7) {
      return {
        'title': 'Primera Semana',
        'description': 'Mantén una racha de 7 días',
        'current': _statistics.currentStreak,
        'target': 7,
        'progress': _statistics.currentStreak / 7,
      };
    } else if (_statistics.currentStreak < 30) {
      return {
        'title': 'Primer Mes',
        'description': 'Mantén una racha de 30 días',
        'current': _statistics.currentStreak,
        'target': 30,
        'progress': _statistics.currentStreak / 30,
      };
    } else if (_statistics.totalPoints < 500) {
      return {
        'title': 'Explorador',
        'description': 'Acumula 500 puntos',
        'current': _statistics.totalPoints,
        'target': 500,
        'progress': _statistics.totalPoints / 500,
      };
    } else {
      return {
        'title': 'Maestro',
        'description': '¡Has desbloqueado todos los logros básicos!',
        'current': 1,
        'target': 1,
        'progress': 1.0,
      };
    }
  }
}
