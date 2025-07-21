import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'individual_streak_service.dart';

class IndividualStreaksPage extends StatelessWidget {
  const IndividualStreaksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rachas Individuales'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showStreakInfoDialog(context),
          ),
        ],
      ),
      body: Consumer<IndividualStreakService>(
        builder: (context, streakService, child) {
          final streaks = streakService.streaks;
          final globalStats = streakService.getGlobalStats();
          
          if (streaks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_fire_department_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes desafíos activos',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea un desafío para comenzar tu racha',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Estadísticas globales
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[100]!, Colors.orange[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: Colors.orange[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Resumen Global',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'Desafíos',
                          '${globalStats['totalChallenges']}',
                          Icons.assignment,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Activos',
                          '${globalStats['activeChallenges']}',
                          Icons.local_fire_department,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Puntos',
                          '${globalStats['totalPoints']}',
                          Icons.stars,
                          Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'Promedio',
                          '${globalStats['averageStreak'].toStringAsFixed(1)}d',
                          Icons.trending_up,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Récord',
                          '${globalStats['longestOverallStreak']}d',
                          Icons.emoji_events,
                          Colors.amber,
                        ),
                        const SizedBox(width: 60), // Espaciador
                      ],
                    ),
                  ],
                ),
              ),
              
              // Lista de rachas individuales
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: streaks.length,
                  itemBuilder: (context, index) {
                    final streak = streaks.values.elementAt(index);
                    return _buildStreakCard(context, streak);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(BuildContext context, ChallengeStreak streak) {
    final streakColor = streak.currentStreak > 0 ? Colors.orange : Colors.grey;
    final hasTokens = streak.forgivenessTokens > 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: streakColor.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: streakColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título y racha principal
            Row(
              children: [
                Expanded(
                  child: Text(
                    streak.challengeTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: streakColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: streakColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${streak.currentStreak}d',
                        style: TextStyle(
                          color: streakColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Información adicional
            Row(
              children: [
                // Récord personal
                _buildInfoChip(
                  Icons.emoji_events,
                  'Récord: ${streak.longestStreak}d',
                  Colors.amber,
                ),
                const SizedBox(width: 12),
                
                // Puntos
                _buildInfoChip(
                  Icons.stars,
                  '${streak.totalPoints}pts',
                  Colors.purple,
                ),
                
                const Spacer(),
                
                // Fichas de perdón
                if (hasTokens)
                  Row(
                    children: [
                      ...List.generate(
                        streak.forgivenessTokens.clamp(0, 3),
                        (index) => Container(
                          margin: const EdgeInsets.only(right: 2),
                          child: Icon(
                            Icons.shield,
                            color: Colors.blue[400],
                            size: 16,
                          ),
                        ),
                      ),
                      Text(
                        ' ${streak.forgivenessTokens}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            
            // Estado actual
            if (streak.isCompletedToday) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Completado hoy',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showStreakInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600]),
              const SizedBox(width: 12),
              const Text('Sistema de Rachas'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nuevo Sistema Individual',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '✅ Cada desafío tiene su propia racha independiente\n'
                '🛡️ Fichas de perdón para proteger tus rachas\n'
                '⭐ Puntos individuales por cada desafío\n'
                '📊 Estadísticas detalladas por desafío',
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield, color: Colors.blue[600], size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          'Fichas de perdón:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• Protegen tu racha cuando fallas\n'
                      '• Empiezas con 2 fichas por desafío\n'
                      '• Se regenera 1 ficha por semana\n'
                      '• Máximo 3 fichas por desafío',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
}
