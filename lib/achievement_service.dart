import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'statistics_service.dart';
import 'notification_service.dart';

class Achievement {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final Color color;
  final int points;
  final bool Function(UserStatistics stats) checkCondition;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
    required this.points,
    required this.checkCondition,
    this.unlockedAt,
  });

  Achievement copyWith({DateTime? unlockedAt}) => Achievement(
    id: id,
    titleKey: titleKey,
    descriptionKey: descriptionKey,
    icon: icon,
    color: color,
    points: points,
    checkCondition: checkCondition,
    unlockedAt: unlockedAt ?? this.unlockedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };

  bool get isUnlocked => unlockedAt != null;
}

class AchievementService extends ChangeNotifier {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal() {
    _initializeAchievements();
  }

  static AchievementService get instance => _instance;

  List<Achievement> _achievements = [];
  List<Achievement> get achievements => _achievements;

  List<Achievement> get unlockedAchievements => 
      _achievements.where((a) => a.isUnlocked).toList();

  List<Achievement> get lockedAchievements => 
      _achievements.where((a) => !a.isUnlocked).toList();

  void _initializeAchievements() {
    _achievements = [
      // Logros de Racha
      Achievement(
        id: 'first_day',
        titleKey: 'achievement_first_day_title',
        descriptionKey: 'achievement_first_day_desc',
        icon: Icons.star,
        color: Colors.orange,
        points: 10,
        checkCondition: (stats) => stats.currentStreak >= 1,
      ),
      Achievement(
        id: 'week_warrior',
        titleKey: 'achievement_week_warrior_title',
        descriptionKey: 'achievement_week_warrior_desc',
        icon: Icons.local_fire_department,
        color: Colors.red,
        points: 50,
        checkCondition: (stats) => stats.currentStreak >= 7,
      ),
      Achievement(
        id: 'month_master',
        titleKey: 'achievement_month_master_title',
        descriptionKey: 'achievement_month_master_desc',
        icon: Icons.emoji_events,
        color: Colors.amber,
        points: 200,
        checkCondition: (stats) => stats.currentStreak >= 30,
      ),
      Achievement(
        id: 'streak_legend',
        titleKey: 'achievement_streak_legend_title',
        descriptionKey: 'achievement_streak_legend_desc',
        icon: Icons.diamond,
        color: Colors.purple,
        points: 500,
        checkCondition: (stats) => stats.longestStreak >= 100,
      ),

      // Logros de Puntos
      Achievement(
        id: 'explorer',
        titleKey: 'achievement_explorer_title',
        descriptionKey: 'achievement_explorer_desc',
        icon: Icons.explore,
        color: Colors.blue,
        points: 25,
        checkCondition: (stats) => stats.totalPoints >= 100,
      ),
      Achievement(
        id: 'collector',
        titleKey: 'achievement_collector_title',
        descriptionKey: 'achievement_collector_desc',
        icon: Icons.collections,
        color: Colors.green,
        points: 100,
        checkCondition: (stats) => stats.totalPoints >= 500,
      ),
      Achievement(
        id: 'point_master',
        titleKey: 'achievement_point_master_title',
        descriptionKey: 'achievement_point_master_desc',
        icon: Icons.workspace_premium,
        color: Colors.deepPurple,
        points: 300,
        checkCondition: (stats) => stats.totalPoints >= 1000,
      ),

      // Logros de Actividad
      Achievement(
        id: 'event_starter',
        titleKey: 'achievement_event_starter_title',
        descriptionKey: 'achievement_event_starter_desc',
        icon: Icons.event,
        color: Colors.teal,
        points: 15,
        checkCondition: (stats) => stats.totalEvents >= 5,
      ),
      Achievement(
        id: 'challenge_creator',
        titleKey: 'achievement_challenge_creator_title',
        descriptionKey: 'achievement_challenge_creator_desc',
        icon: Icons.psychology,
        color: Colors.indigo,
        points: 30,
        checkCondition: (stats) => stats.totalChallenges >= 3,
      ),
      Achievement(
        id: 'completion_king',
        titleKey: 'achievement_completion_king_title',
        descriptionKey: 'achievement_completion_king_desc',
        icon: Icons.check_circle,
        color: Colors.green,
        points: 150,
        checkCondition: (stats) => stats.completedChallenges >= 10,
      ),

      // Logros Especiales
      Achievement(
        id: 'early_bird',
        titleKey: 'achievement_early_bird_title',
        descriptionKey: 'achievement_early_bird_desc',
        icon: Icons.wb_sunny,
        color: Colors.amber,
        points: 20,
        checkCondition: (stats) => _hasEarlyMorningActivity(stats),
      ),
      Achievement(
        id: 'night_owl',
        titleKey: 'achievement_night_owl_title',
        descriptionKey: 'achievement_night_owl_desc',
        icon: Icons.nights_stay,
        color: Colors.indigo,
        points: 20,
        checkCondition: (stats) => _hasLateNightActivity(stats),
      ),
    ];
  }

  bool _hasEarlyMorningActivity(UserStatistics stats) {
    return stats.recentActivity.any((activity) => 
        activity.hour >= 5 && activity.hour <= 8);
  }

  bool _hasLateNightActivity(UserStatistics stats) {
    return stats.recentActivity.any((activity) => 
        activity.hour >= 22 || activity.hour <= 2);
  }

  // Cargar logros desbloqueados desde SharedPreferences
  Future<void> loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('user_achievements');
      
      if (jsonString != null) {
        final List<dynamic> achievementData = jsonDecode(jsonString);
        
        for (final data in achievementData) {
          final id = data['id'] as String;
          final unlockedAtString = data['unlockedAt'] as String?;
          
          final index = _achievements.indexWhere((a) => a.id == id);
          if (index != -1 && unlockedAtString != null) {
            _achievements[index] = _achievements[index].copyWith(
              unlockedAt: DateTime.parse(unlockedAtString),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading achievements: $e');
    }
    notifyListeners();
  }

  // Guardar logros en SharedPreferences
  Future<void> _saveAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final unlockedAchievements = _achievements
          .where((a) => a.isUnlocked)
          .map((a) => a.toJson())
          .toList();
      
      final jsonString = jsonEncode(unlockedAchievements);
      await prefs.setString('user_achievements', jsonString);
    } catch (e) {
      debugPrint('Error saving achievements: $e');
    }
  }

  // Verificar y desbloquear logros basados en estadísticas actuales
  Future<List<Achievement>> checkAndUnlockAchievements(UserStatistics stats) async {
    final newlyUnlocked = <Achievement>[];

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      
      if (!achievement.isUnlocked && achievement.checkCondition(stats)) {
        final unlockedAchievement = achievement.copyWith(unlockedAt: DateTime.now());
        _achievements[i] = unlockedAchievement;
        newlyUnlocked.add(unlockedAchievement);
        
        // Mostrar notificación de logro desbloqueado
        await _showAchievementNotification(unlockedAchievement);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      await _saveAchievements();
      notifyListeners();
    }

    return newlyUnlocked;
  }

  Future<void> _showAchievementNotification(Achievement achievement) async {
    await NotificationService.instance.scheduleNotification(
      id: achievement.id.hashCode,
      title: '🏆 ¡Logro Desbloqueado!',
      body: 'Has obtenido: ${achievement.titleKey}',
      scheduledDate: DateTime.now().add(const Duration(seconds: 1)),
    );
  }

  // Obtener progreso total (porcentaje de logros desbloqueados)
  double get totalProgress {
    if (_achievements.isEmpty) return 0.0;
    return unlockedAchievements.length / _achievements.length;
  }

  // Obtener puntos totales de logros
  int get totalAchievementPoints {
    return unlockedAchievements.fold(0, (sum, achievement) => sum + achievement.points);
  }

  // Obtener el siguiente logro por desbloquear
  Achievement? get nextAchievement {
    final locked = lockedAchievements;
    if (locked.isEmpty) return null;
    
    // Ordenar por puntos (más fáciles primero)
    locked.sort((a, b) => a.points.compareTo(b.points));
    return locked.first;
  }

  // Resetear logros (para desarrollo)
  Future<void> resetAchievements() async {
    _initializeAchievements();
    await _saveAchievements();
    notifyListeners();
  }

  // Obtener logros por categoría
  Map<String, List<Achievement>> getAchievementsByCategory() {
    return {
      'Racha': _achievements.where((a) => 
          ['first_day', 'week_warrior', 'month_master', 'streak_legend'].contains(a.id)
      ).toList(),
      'Puntos': _achievements.where((a) => 
          ['explorer', 'collector', 'point_master'].contains(a.id)
      ).toList(),
      'Actividad': _achievements.where((a) => 
          ['event_starter', 'challenge_creator', 'completion_king'].contains(a.id)
      ).toList(),
      'Especiales': _achievements.where((a) => 
          ['early_bird', 'night_owl'].contains(a.id)
      ).toList(),
    };
  }
}
