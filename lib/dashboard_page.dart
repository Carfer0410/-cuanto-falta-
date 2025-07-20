import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'localization_service.dart';
import 'statistics_service.dart';
import 'achievement_service.dart';
import 'data_migration_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await StatisticsService.instance.loadStatistics();
    await AchievementService.instance.loadAchievements();
    
    // Verificar logros basados en estadísticas actuales
    await AchievementService.instance.checkAndUnlockAchievements(
      StatisticsService.instance.statistics
    );
  }

  // Función específica para pull-to-refresh que incluye sincronización
  Future<void> _onRefresh() async {
    print('🔄 DashboardPage: Pull-to-refresh iniciado');
    try {
      // Primero, sincronizar datos automáticamente (sin resetear)
      await DataMigrationService.forceSyncAllData();
      
      // Luego, recargar todos los datos
      await _loadData();
      
      print('✅ DashboardPage: Pull-to-refresh completado exitosamente');
      
      // Mostrar mensaje discreto de sincronización exitosa
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.refresh, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Dashboard sincronizado'),
              ],
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ DashboardPage: Error en pull-to-refresh: $e');
      // En caso de error, solo cargar datos normalmente
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text('Datos cargados (sync falló: $e)'),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _resetAndRemigrate() async {
    try {
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Reseteando y re-migrando datos...'),
              ],
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Ejecutar reset y migración
      await DataMigrationService.resetAndRemigrate();
      
      // Recargar datos
      await _loadData();

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 16),
                Text('¡Datos reseteados y migrados correctamente!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 16),
                Text('Error: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _forceSyncData() async {
    try {
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Resincronizando datos...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Ejecutar sincronización forzada
      await DataMigrationService.forceSyncAllData();
      
      // Recargar datos
      await _loadData();

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 16),
                Text('¡Datos sincronizados correctamente!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 16),
                Text('Error: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LocalizationService>(
          builder: (context, localization, child) {
            return Text(localization.t('dashboard'));
          },
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Icono de información
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Información del Dashboard',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.dashboard, color: Colors.orange, size: 24),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Dashboard de Estadísticas',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '📊 ¿Qué puedes ver aquí?',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '• Resumen de puntos y nivel actual\n'
                            '• Estadísticas de eventos y retos\n'
                            '• Racha de actividad diaria\n'
                            '• Gráfico de actividad semanal\n'
                            '• Sistema de logros y medallas\n'
                            '• Progreso de desbloqueo de insignias',
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '🔄 ¿Cómo sincronizar datos?',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '1. Desliza hacia abajo (Pull-to-refresh)\n'
                            '   → Sincronización rápida y automática\n\n'
                            '2. Menú de opciones (⋮) → "Resincronizar"\n'
                            '   → Sincronización manual completa\n\n'
                            '3. Menú de opciones (⋮) → "Reset y re-migrar"\n'
                            '   → Reinicia estadísticas completamente',
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '🎯 ¿Por qué sincronizar?',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '• Actualiza contadores de eventos y retos\n'
                            '• Corrige estadísticas incorrectas\n'
                            '• Recalcula puntos y logros\n'
                            '• Mantiene datos consistentes\n'
                            '• Refleja cambios recientes en tiempo real',
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '💡 Tip: El dashboard se actualiza automáticamente cuando creas o modificas eventos y retos.',
                              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Entendido', style: TextStyle(color: Colors.orange)),
                    ),
                  ],
                ),
              );
            },
          ),
          // Menú de opciones
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'sync') {
                await _forceSyncData();
              } else if (value == 'reset') {
                await _resetAndRemigrate();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Resincronizar datos'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restart_alt, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Reset y re-migrar', style: TextStyle(color: Colors.orange)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer3<LocalizationService, StatisticsService, AchievementService>(
        builder: (context, localization, statsService, achievementService, child) {
          final stats = statsService.statistics;
          
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen de puntos y nivel
                  _buildPointsCard(localization, stats),
                  const SizedBox(height: 16),
                  
                  // Tarjetas de estadísticas principales
                  _buildStatsGrid(localization, stats),
                  const SizedBox(height: 16),
                  
                  // Racha actual
                  _buildStreakCard(localization, stats),
                  const SizedBox(height: 16),
                  
                  // Gráfico de actividad semanal
                  _buildWeeklyActivityChart(localization, statsService),
                  const SizedBox(height: 16),
                  
                  // Próximo logro
                  _buildNextAchievementCard(localization, achievementService),
                  const SizedBox(height: 16),
                  
                  // Logros recientes
                  _buildRecentAchievements(localization, achievementService),
                  
                  const SizedBox(height: 80), // Espacio para el FAB
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAchievementsBottomSheet(context),
        icon: const Icon(Icons.emoji_events),
        label: Consumer<LocalizationService>(
          builder: (context, localization, child) {
            return Text(localization.t('achievements'));
          },
        ),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildPointsCard(LocalizationService localization, UserStatistics stats) {
    final level = (stats.totalPoints / 100).floor() + 1;
    final pointsInCurrentLevel = stats.totalPoints % 100;
    final progressToNextLevel = pointsInCurrentLevel / 100;

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.orange.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${localization.t('level')} $level',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${stats.totalPoints} ${localization.t('points')}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.stars,
                  color: Colors.white,
                  size: 40,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${localization.t('progress')} ${localization.t('level')} ${level + 1}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressToNextLevel,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '$pointsInCurrentLevel / 100',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(LocalizationService localization, UserStatistics stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          localization.t('total_events'),
          stats.totalEvents.toString(),
          Icons.event,
          Colors.blue,
        ),
        _buildStatCard(
          localization.t('total_challenges'),
          stats.totalChallenges.toString(),
          Icons.psychology,
          Colors.green,
        ),
        _buildStatCard(
          localization.t('current_streak'),
          '${stats.currentStreak} días',
          Icons.local_fire_department,
          Colors.red,
        ),
        _buildStatCard(
          localization.t('longest_streak'),
          '${stats.longestStreak} días',
          Icons.military_tech,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(LocalizationService localization, UserStatistics stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_fire_department,
                color: Colors.red.shade600,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.t('current_streak'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${stats.currentStreak} días consecutivos',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (stats.currentStreak > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '¡Sigue así! 🔥',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyActivityChart(LocalizationService localization, StatisticsService statsService) {
    final weeklyData = statsService.getWeeklyActivity();
    final maxActivity = weeklyData.values.isEmpty ? 1 : weeklyData.values.reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.t('weekly_activity'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Gráfico simple con barras nativas
            SizedBox(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: weeklyData.entries.map((entry) {
                  final height = maxActivity > 0 ? (entry.value / maxActivity) * 80 : 0.0;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 30,
                        height: height,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.key,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextAchievementCard(LocalizationService localization, AchievementService achievementService) {
    final nextAchievement = achievementService.nextAchievement;
    final progress = StatisticsService.instance.getNextAchievementProgress();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.t('next_achievement'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (nextAchievement != null) ...[
              Row(
                children: [
                  Icon(
                    nextAchievement.icon,
                    color: nextAchievement.color,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.t(nextAchievement.titleKey),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          localization.t(nextAchievement.descriptionKey),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress['progress'],
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(nextAchievement.color),
              ),
              const SizedBox(height: 4),
              Text(
                '${progress['current']} / ${progress['target']}',
                style: const TextStyle(fontSize: 12),
              ),
            ] else ...[
              const Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¡Has desbloqueado todos los logros disponibles!',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAchievements(LocalizationService localization, AchievementService achievementService) {
    final recentAchievements = achievementService.unlockedAchievements
        .where((a) => a.unlockedAt != null)
        .toList()
      ..sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));

    final recent = recentAchievements.take(3).toList();

    if (recent.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Logros Recientes',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _showAchievementsBottomSheet(context),
                  child: Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recent.map((achievement) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Icon(
                    achievement.icon,
                    color: achievement.color,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.t(achievement.titleKey),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          localization.formatDate(achievement.unlockedAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+${achievement.points}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showAchievementsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Logros',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Expanded(
                  child: Consumer2<LocalizationService, AchievementService>(
                    builder: (context, localization, achievementService, child) {
                      final categories = achievementService.getAchievementsByCategory();
                      
                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories.keys.elementAt(index);
                          final achievements = categories[category]!;
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ...achievements.map((achievement) => Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: Icon(
                                    achievement.icon,
                                    color: achievement.isUnlocked 
                                        ? achievement.color 
                                        : Colors.grey,
                                    size: 32,
                                  ),
                                  title: Text(
                                    localization.t(achievement.titleKey),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: achievement.isUnlocked 
                                          ? null 
                                          : Colors.grey,
                                    ),
                                  ),
                                  subtitle: Text(
                                    localization.t(achievement.descriptionKey),
                                    style: TextStyle(
                                      color: achievement.isUnlocked 
                                          ? null 
                                          : Colors.grey,
                                    ),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (achievement.isUnlocked) ...[
                                        const Icon(Icons.check_circle, color: Colors.green),
                                        Text(
                                          '+${achievement.points}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ] else ...[
                                        const Icon(Icons.lock, color: Colors.grey),
                                        Text(
                                          '${achievement.points}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              )),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
