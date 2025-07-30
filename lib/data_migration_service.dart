import 'database_helper.dart';
import 'statistics_service.dart';
import 'achievement_service.dart';
import 'individual_streak_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DataMigrationService {
  static bool _hasRunMigration = false;

  /// Ejecuta la migración de datos existentes solo una vez
  static Future<void> runInitialDataMigration() async {
    if (_hasRunMigration) return;

    final prefs = await SharedPreferences.getInstance();
    final hasRunBefore = prefs.getBool('has_run_data_migration') ?? false;
    
    if (hasRunBefore) {
      _hasRunMigration = true;
      return;
    }

    print('🔄 Ejecutando migración inicial de datos...');

    try {
      // Contar eventos existentes
      final events = await DatabaseHelper.instance.getEvents();
      final eventCount = events.length;

      // Contar retos existentes
      final countersJson = prefs.getString('counters');
      int challengeCount = 0;
      if (countersJson != null) {
        final List decoded = jsonDecode(countersJson);
        challengeCount = decoded.length;
      }

      // Si hay datos existentes, crear estadísticas base (SOLO establecer, no sumar)
      if (eventCount > 0 || challengeCount > 0) {
        final currentStats = StatisticsService.instance.statistics;
        
        // Establecer estadísticas correctas (NO sumar)
        final updatedStats = currentStats.copyWith(
          totalEvents: eventCount, // Establecer, no sumar
          totalChallenges: challengeCount, // Establecer, no sumar
          activeChallenges: challengeCount,
          // Solo dar puntos si no tenía puntos antes (evitar duplicación)
          totalPoints: currentStats.totalPoints == 0 
            ? (eventCount * 5) + (challengeCount * 10)
            : currentStats.totalPoints,
        );

        // Actualizar el servicio con las nuevas estadísticas
        await StatisticsService.instance.setStatisticsFromMigration(updatedStats);

        // Verificar si se pueden desbloquear logros
        await AchievementService.instance.checkAndUnlockAchievements(updatedStats);

        print('✅ Migración completada: $eventCount eventos, $challengeCount retos');
      }

      // Marcar que la migración ya se ejecutó
      await prefs.setBool('has_run_data_migration', true);
      _hasRunMigration = true;

    } catch (e) {
      print('❌ Error en la migración de datos: $e');
    }
  }

  /// Permite resetear la migración para testing
  static Future<void> resetMigration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_run_data_migration');
    _hasRunMigration = false;
  }

  /// Resetea completamente las estadísticas y re-ejecuta la migración
  static Future<void> resetAndRemigrate() async {
    print('🔄 Reseteando estadísticas y re-ejecutando migración...');
    
    try {
      // Resetear estadísticas a cero
      await StatisticsService.instance.resetStatistics();
      
      // Resetear migración
      await resetMigration();
      
      // Re-ejecutar migración
      await runInitialDataMigration();
      
      print('✅ Reset y migración completados');
    } catch (e) {
      print('❌ Error en reset y migración: $e');
    }
  }

  /// Fuerza una resincronización completa de datos
  static Future<void> forceSyncAllData() async {
    print('🔄 DataMigrationService: Forzando sincronización completa...');

    try {
      // Obtener todos los eventos de la base de datos
      final events = await DatabaseHelper.instance.getEvents();
      print('📊 DataMigrationService: Encontrados ${events.length} eventos');
      
      // Obtener todos los retos de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final countersJson = prefs.getString('counters');
      int challengeCount = 0;
      if (countersJson != null) {
        final List decoded = jsonDecode(countersJson);
        challengeCount = decoded.length;
      }
      print('📊 DataMigrationService: Encontrados $challengeCount retos');

      // Reconstruir estadísticas desde cero basándose en datos reales
      final currentStats = StatisticsService.instance.statistics;
      final basePoints = (events.length * 5) + (challengeCount * 10);
      
      final syncedStats = currentStats.copyWith(
        totalEvents: events.length,
        totalChallenges: challengeCount,
        activeChallenges: challengeCount,
        completedChallenges: 0, // Por ahora no tenemos manera de saber cuáles están completos
        // Mantener la racha y actividad reciente, solo corregir contadores
        totalPoints: currentStats.currentStreak > 0 
          ? basePoints + (currentStats.currentStreak * 2) // Mantener bonus de racha
          : basePoints,
      );

      print('📊 DataMigrationService: Actualizando estadísticas a: eventos=${syncedStats.totalEvents}, retos=${syncedStats.totalChallenges}');

      // Actualizar el servicio
      await StatisticsService.instance.setStatisticsFromMigration(syncedStats);

      // Verificar logros
      await AchievementService.instance.checkAndUnlockAchievements(syncedStats);

      print('✅ DataMigrationService: Sincronización forzada completada: ${events.length} eventos, $challengeCount retos');

    } catch (e) {
      print('❌ DataMigrationService: Error en la sincronización forzada: $e');
      rethrow; // Re-lanzar el error para que las páginas puedan manejarlo
    }
  }

  /// Migrar desde el sistema global de rachas al sistema individual
  static Future<void> migrateToIndividualStreaks() async {
    print('🔄 Migrando desde racha global a rachas individuales...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasMigrated = prefs.getBool('has_migrated_individual_streaks') ?? false;
      
      if (hasMigrated) {
        print('✅ Migración de rachas individuales ya completada');
        return;
      }

      // Obtener la racha global actual
      final globalStats = StatisticsService.instance.statistics;
      final globalStreak = globalStats.currentStreak;
      
      // 🔧 CORRECCIÓN DEL BUG: Solo migrar si realmente hay racha global significativa
      if (globalStreak <= 0) {
        print('📊 No hay racha global significativa, omitir migración automática');
        await prefs.setBool('has_migrated_individual_streaks', true);
        return;
      }
      
      // Obtener todos los desafíos actuales
      final countersJson = prefs.getString('counters');
      if (countersJson != null) {
        final List decoded = jsonDecode(countersJson);
        final Map<String, String> challengeIdToTitle = {};
        
        // 🔧 CORRECCIÓN: Solo migrar retos que realmente merecen la racha global
        // Verificar cuáles tienen challengeStartedAt establecido (retos activos antiguos)
        for (int i = 0; i < decoded.length; i++) {
          final counter = decoded[i];
          final challengeId = 'challenge_$i';
          final challengeTitle = counter['title'] ?? 'Desafío $i';
          
          // 🎯 NUEVA LÓGICA: Solo migrar retos que tenían actividad previa
          final challengeStartedAt = counter['challengeStartedAt'];
          final hasStartDate = challengeStartedAt != null;
          
          // Solo incluir retos que ya estaban activos en el sistema anterior
          if (hasStartDate) {
            challengeIdToTitle[challengeId] = challengeTitle;
            print('✅ Reto "$challengeTitle" marcado para migración (tenía actividad previa)');
          } else {
            print('⚠️ Reto "$challengeTitle" omitido de migración (sin actividad previa)');
          }
        }
        
        if (challengeIdToTitle.isNotEmpty) {
          // Ejecutar migración solo en retos con actividad previa
          await IndividualStreakService.instance.migrateFromGlobalStreak(
            challengeIdToTitle, 
            globalStreak
          );
          
          print('✅ Migrado $globalStreak días de racha global a ${challengeIdToTitle.length} desafíos individuales con actividad previa');
        } else {
          print('📊 No hay retos con actividad previa para migrar');
        }
      }
      
      // Marcar como migrado
      await prefs.setBool('has_migrated_individual_streaks', true);
      print('✅ Migración de rachas individuales completada');
      
    } catch (e) {
      print('❌ Error en migración de rachas individuales: $e');
    }
  }
}
