import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'localization_service.dart';
import 'statistics_service.dart';
import 'achievement_service.dart';
import 'data_migration_service.dart';
import 'individual_streak_service.dart';
import 'individual_streaks_page.dart';
import 'notification_center_widgets.dart';

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
    
    // 🔧 NUEVO: Sincronizar estadísticas del dashboard con datos reales de retos
    await _syncRealStatistics();
    
    // Verificar logros basados en estadísticas actuales
    await AchievementService.instance.checkAndUnlockAchievements(
      StatisticsService.instance.statistics
    );
  }

  /// 🔧 NUEVO: Sincronizar estadísticas con datos reales de retos individuales
  Future<void> _syncRealStatistics() async {
    try {
      // Obtener estadísticas reales de IndividualStreakService
      final streakService = IndividualStreakService.instance;
      final allStreaks = streakService.streaks;
      
      if (allStreaks.isEmpty) {
        print('📊 No hay retos registrados para sincronizar estadísticas');
        return;
      }
      
      // Calcular estadísticas reales
      int activeChallenges = 0; // Retos con racha actual > 0
      int totalChallenges = allStreaks.length; // Total de retos existentes
      int totalPoints = 0;
      int currentStreak = 0;
      int longestStreak = 0;
      
      for (final streak in allStreaks.values) {
        // 🔧 CORREGIDO: Un reto está "activo" si tiene racha actual > 0
        if (streak.currentStreak > 0) {
          activeChallenges++;
        }
        
        // Sumar puntos reales (convertir a int)
        totalPoints += streak.totalPoints.round();
        
        // Calcular racha más larga
        if (streak.longestStreak > longestStreak) {
          longestStreak = streak.longestStreak;
        }
        
        // Para la racha actual del dashboard, usar la racha más alta
        if (streak.currentStreak > currentStreak) {
          currentStreak = streak.currentStreak;
        }
      }
      
      // Actualizar StatisticsService con datos reales
      final statsService = StatisticsService.instance;
      await statsService.updateChallengeStats(activeChallenges, totalChallenges);
      
      // Actualizar puntos totales si es diferente
      final currentStats = statsService.statistics;
      if (currentStats.totalPoints != totalPoints) {
        // Crear estadísticas actualizadas
        final updatedStats = currentStats.copyWith(
          totalPoints: totalPoints,
          currentStreak: currentStreak,
          longestStreak: longestStreak,
        );
        
        // Actualizar estadísticas usando el método disponible
        await statsService.setStatisticsFromMigration(updatedStats);
      }
      
      print('✅ Estadísticas sincronizadas:');
      print('  • Retos activos: $activeChallenges');
      print('  • Total retos: $totalChallenges');
      print('  • Puntos totales: $totalPoints');
      print('  • Racha actual: $currentStreak');
      print('  • Racha más larga: $longestStreak');
      
    } catch (e) {
      print('❌ Error sincronizando estadísticas: $e');
    }
  }

  /// 🔧 NUEVO: Calcular actividad específica de esta semana
  int _getThisWeekActivity(UserStatistics stats) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfThisWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return stats.recentActivity.where((activity) {
      return activity.isAfter(startOfThisWeek) || 
             activity.isAtSameMomentAs(startOfThisWeek);
    }).length;
  }

  // Función específica para pull-to-refresh que incluye sincronización
  Future<void> _onRefresh() async {
    print('🔄 DashboardPage: Pull-to-refresh iniciado');
    try {
      // Primero, sincronizar datos automáticamente (sin resetear)
      await DataMigrationService.forceSyncAllData();
      
      // Luego, recargar todos los datos (incluyendo sincronización de estadísticas)
      await _loadData();
      
      print('✅ DashboardPage: Pull-to-refresh completado exitosamente');
      
      // Mostrar mensaje discreto de sincronización exitosa
      if (mounted) {
        final localization = Provider.of<LocalizationService>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.refresh, color: Colors.white, size: 16),
                SizedBox(width: 12),
                Text(localization.t('data_synced')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ DashboardPage: Error en pull-to-refresh: $e');
      
      // Mostrar mensaje de error si falla la sincronización
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text('Error al sincronizar: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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
        actions: [
          const NotificationCenterButton(),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
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
                  // Mensaje especial si todos los retos están completados
                  if (stats.activeChallenges == 0 && stats.totalChallenges > 0) ...[
                    _buildAllChallengesCompletedCard(localization, stats),
                    const SizedBox(height: 16),
                  ],
                  
                  // Resumen de puntos y nivel
                  _buildPointsCard(localization, stats),
                  const SizedBox(height: 16),
                  
                  // Tarjetas de estadísticas principales
                  _buildStatsGrid(localization, stats),
                  const SizedBox(height: 16),
                  
                  // Racha actual
                  _buildStreakCard(localization, stats),
                  const SizedBox(height: 16),
                  
                  // Botón para ver rachas individuales
                  _buildIndividualStreaksButton(context),
                  const SizedBox(height: 16),
                  
                  // Gráfico de actividad semanal
                  _buildWeeklyActivityChart(localization, statsService),
                  const SizedBox(height: 16),
                  
                  // Próximo logro o sugerencias especiales
                  if (stats.activeChallenges == 0 && stats.totalChallenges > 0)
                    _buildSuggestionsCard(localization, stats)
                  else
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
      ),
    );
  }

  // Tarjeta especial cuando todos los retos están completados
  Widget _buildAllChallengesCompletedCard(LocalizationService localization, UserStatistics stats) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.celebration,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      localization.t('congratulations'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                localization.t('all_challenges_completed'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCompletionStat(localization.t('challenges_completed'), '${stats.completedChallenges}', Icons.task_alt),
                        _buildCompletionStat(localization.t('points_accumulated'), '${stats.totalPoints}', Icons.stars),
                        _buildCompletionStat(localization.t('current_streak_short'), '${stats.currentStreak} días', Icons.local_fire_department),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // Tarjeta de sugerencias cuando todos los retos están completados
  Widget _buildSuggestionsCard(LocalizationService localization, UserStatistics stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  localization.t('what_next'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSuggestionItem(
              Icons.add_task,
              localization.t('create_new_challenges'),
              localization.t('create_new_challenges_desc'),
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildSuggestionItem(
              Icons.trending_up,
              localization.t('increase_difficulty'),
              localization.t('increase_difficulty_desc'),
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildSuggestionItem(
              Icons.share,
              localization.t('share_success'),
              localization.t('share_success_desc'),
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildSuggestionItem(
              Icons.analytics,
              localization.t('analyze_progress'),
              localization.t('analyze_progress_desc'),
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(IconData icon, String title, String description, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Resto de los métodos existentes continúan aquí...
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              SizedBox(width: 8),
              Text('Dashboard'),
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
                    'El Dashboard muestra información completa sobre tu progreso:\n',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    '📊 Funciones principales:\n'
                    '• Puntos totales y nivel actual\n'
                    '• Estadísticas de eventos y retos\n'
                    '• Racha actual y mejor racha\n'
                    '• Gráfico de actividad semanal\n'
                    '• Próximos logros por desbloquear\n'
                    '• Logros recientes obtenidos\n',
                    style: TextStyle(fontSize: 12),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '🔄 Sincronización:\n'
                      '• Desliza hacia abajo para actualizar\n'
                      '• Actualiza contadores de eventos y retos\n'
                      '• Recalcula estadísticas automáticamente\n'
                      '• Verifica nuevos logros desbloqueados',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '💡 Tip: El dashboard se actualiza automáticamente cuando creas o modificas eventos y retos.',
                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPointsCard(LocalizationService localization, UserStatistics stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.t('total_points'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${stats.totalPoints} puntos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                  Text(
                    'Nivel: ${(stats.totalPoints / 100).floor() + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Icon(Icons.trending_up, color: Colors.green),
                Text(
                  '+${_getThisWeekActivity(stats)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'esta semana',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(LocalizationService localization, UserStatistics stats) {
    // Si todos los retos están completados, mostrar estadísticas especiales
    if (stats.activeChallenges == 0 && stats.totalChallenges > 0) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          _buildStatCard(
            'Retos Completados',
            '${stats.completedChallenges}/${stats.totalChallenges}',
            Icons.task_alt,
            Colors.green,
          ),
          _buildStatCard(
            'Puntos Totales',
            '${stats.totalPoints}',
            Icons.stars,
            Colors.amber,
          ),
          _buildStatCard(
            'Racha Actual',
            '${stats.currentStreak} días',
            Icons.local_fire_department,
            Colors.red,
          ),
          _buildStatCard(
            'Mejor Racha',
            '${stats.longestStreak} días',
            Icons.military_tech,
            Colors.purple,
          ),
        ],
      );
    }
    
    // Estadísticas normales cuando hay retos activos
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: stats.currentStreak > 0 ? Colors.red : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  localization.t('current_streak'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stats.currentStreak}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: stats.currentStreak > 0 ? Colors.red : Colors.grey,
                        ),
                      ),
                      Text(
                        'días consecutivos',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (stats.currentStreak > 0) ...[
                  Column(
                    children: [
                      Text(
                        '🔥',
                        style: TextStyle(fontSize: 24),
                      ),
                      Text(
                        '¡Sigue así!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
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
                      Text(
                        '${entry.value}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
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
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        progress['description'],
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
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
            const SizedBox(height: 4),
            Text(
              '${progress['current']} / ${progress['target']}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAchievements(LocalizationService localization, AchievementService achievementService) {
    // Por ahora mostramos un mensaje genérico sobre logros
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
                  localization.t('recent_achievements'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _showAchievementsBottomSheet(context),
                  child: Text(localization.t('view_all')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  Icon(Icons.emoji_events_outlined, size: 48, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  Text(
                    localization.t('continue_completing_challenges'),
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _showAchievementsBottomSheet(context),
                    child: Text(localization.t('view_all_achievements_button')),
                  ),
                ],
              ),
            ),
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

  /// Botón para navegar a las rachas individuales
  Widget _buildIndividualStreaksButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const IndividualStreaksPage(),
            ),
          );
        },
        icon: Icon(
          Icons.local_fire_department,
          color: Colors.orange[700],
        ),
        label: const Text(
          'Ver Rachas Individuales',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[50],
          foregroundColor: Colors.orange[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.orange[200]!,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
