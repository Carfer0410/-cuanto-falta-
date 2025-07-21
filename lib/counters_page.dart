import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'add_counter_page.dart';
import 'localization_service.dart';
import 'statistics_service.dart';
import 'achievement_service.dart';
import 'data_migration_service.dart';
import 'event.dart'; // Para usar EventColor y EventIcon
import 'challenge_strategies_page.dart';

class Counter {
  final String title;
  final DateTime startDate;
  DateTime? lastConfirmedDate;
  final bool isNegativeHabit;
  DateTime? challengeStartedAt; // Nuevo campo
  final EventColor color;
  final EventIcon icon;

  Counter({
    required this.title,
    required this.startDate,
    this.lastConfirmedDate,
    this.isNegativeHabit = false,
    this.challengeStartedAt,
    this.color = EventColor.orange,
    this.icon = EventIcon.fitness,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'startDate': startDate.toIso8601String(),
    'lastConfirmedDate': lastConfirmedDate?.toIso8601String(),
    'isNegativeHabit': isNegativeHabit,
    'challengeStartedAt': challengeStartedAt?.toIso8601String(),
    'color': color.name,
    'icon': icon.name,
  };

  static Counter fromJson(Map<String, dynamic> json) => Counter(
    title: json['title'],
    startDate: DateTime.parse(json['startDate']),
    lastConfirmedDate:
        json['lastConfirmedDate'] != null
            ? DateTime.parse(json['lastConfirmedDate'])
            : null,
    isNegativeHabit:
        json['isNegativeHabit'] == true,
    challengeStartedAt: json['challengeStartedAt'] != null
        ? DateTime.parse(json['challengeStartedAt'])
        : null,
    color: EventColor.values.firstWhere(
      (c) => c.name == json['color'], 
      orElse: () => EventColor.orange,
    ),
    icon: EventIcon.values.firstWhere(
      (i) => i.name == json['icon'], 
      orElse: () => EventIcon.fitness,
    ),
  );
}

class CountersPage extends StatefulWidget {
  const CountersPage({Key? key}) : super(key: key);

  @override
  State<CountersPage> createState() => _CountersPageState();
}

class _CountersPageState extends State<CountersPage> {
  List<Counter> _counters = [];

  @override
  void initState() {
    super.initState();
    _loadCounters();
  }

  Future<void> _loadCounters() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('counters');
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      _counters = decoded.map((e) => Counter.fromJson(e)).toList();
    }
    
    // NOTA: No actualizar estadísticas aquí para evitar duplicación
    // Las estadísticas se actualizan solo cuando se crean/modifican retos
    // o durante la migración/sincronización manual
    
    setState(() {});
  }

  // Función específica para pull-to-refresh que incluye sincronización
  Future<void> _onRefresh() async {
    print('🔄 CountersPage: Pull-to-refresh iniciado');
    try {
      // Sincronizar estadísticas de retos con datos reales
      await DataMigrationService.forceSyncAllData();
      
      // Cargar retos
      await _loadCounters();
      
      print('✅ CountersPage: Pull-to-refresh completado exitosamente');
      
      // Mostrar mensaje discreto de actualización exitosa
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.refresh, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Retos sincronizados'),
              ],
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ CountersPage: Error en pull-to-refresh: $e');
      // En caso de error, solo cargar retos normalmente
      await _loadCounters();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text('Retos cargados (sync falló: $e)'),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _saveCounters() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _counters.map((e) => e.toJson()).toList();
    await prefs.setString('counters', jsonEncode(list));
  }

  void _navigateToAddCounter() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCounterPage()),
    );
    if (result == true) {
      _loadCounters();
    }
  }

  void _deleteCounter(int index) {
    setState(() {
      _counters.removeAt(index);
    });
    _saveCounters();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _challengePhrase(Counter counter, LocalizationService localizationService) {
    final basePhrase = counter.title.toLowerCase();
    // Lógica especial para "año nuevo"
    if (basePhrase.contains('año nuevo')) {
      final now = DateTime.now();
      final nextYear = DateTime(now.year + 1, 1, 1);
      final dias = nextYear.difference(now).inDays;
      if (dias > 60) {
        return '🎉 Faltan $dias días para el próximo año';
      } else if (dias > 30) {
        return '🎉 El año nuevo se acerca, ¡prepárate!';
      } else if (dias > 7) {
        return '🎉 ¡Ya falta poco para el año nuevo!';
      } else {
        return '🎉 ¡Ya casi comienza el año!';
      }
    }
    if (counter.isNegativeHabit) {
      final stopPrefix = localizationService.t('stopPrefix');
      if (basePhrase.startsWith('${stopPrefix.toLowerCase()} ')) {
        final cleanPhrase = basePhrase.replaceFirst('${stopPrefix.toLowerCase()} ', '');
        return '${localizationService.t('without')} $cleanPhrase';
      } else {
        return '${localizationService.t('without')} $basePhrase';
      }
    } else {
      final startPrefix = localizationService.t('startPrefix');
      if (basePhrase.startsWith('${startPrefix.toLowerCase()} ')) {
        final cleanPhrase = basePhrase.replaceFirst('${startPrefix.toLowerCase()} ', '');
        return '${localizationService.t('doing')} $cleanPhrase';
      } else {
        return '${localizationService.t('doing')} $basePhrase';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Retos'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Información',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Qué puedes hacer aquí?'),
                  content: const Text(
                    'En esta pantalla puedes llevar el control de tus retos o hábitos, como dejar de fumar o empezar a hacer ejercicio.\n\n'
                    '- Agrega un reto con el botón naranja (+) abajo a la derecha.\n'
                    '- Cada tarjeta muestra el nombre del reto, el tiempo que llevas cumpliéndolo y una frase motivacional.\n'
                    '- Pulsa “Iniciar reto” para comenzar a contar tu progreso.\n'
                    '- Cada día, confirma si cumpliste tu reto pulsando “¿Cumpliste hoy?”.\n'
                    '- Desliza un reto hacia la izquierda para eliminarlo.\n\n'
                    '¡Haz seguimiento a tus logros y mantente motivado para cumplir tus objetivos!'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child:
              _counters.isEmpty
                  ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 150),
                      Center(
                        child: Text(
                          'No hay retos. ¡Agrega uno!',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  )
                  : ListView.builder(
                      itemCount: _counters.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _counters.length) {
                          // Espacio extra al final para el FAB (más alto para asegurar separación)
                          return const SizedBox(height: 80);
                        }
                        final counter = _counters[index];
                        final now = DateTime.now();
                        // ...existing code...
                        // final streakStart = counter.startDate; // eliminada variable no usada
                        final confirmedToday =
                            counter.lastConfirmedDate != null &&
                            _isSameDay(counter.lastConfirmedDate!, now);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [counter.color.color, counter.color.lightColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: counter.color.color.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Header con ícono y acciones
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 12,
                                  top: 16,
                                  bottom: 8,
                                ),
                                child: Row(
                                  children: [
                                    // Ícono del reto
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.95),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        counter.icon.icon,
                                        color: counter.color.color,
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Título expandido
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            localizationService.t('youHave'),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _challengePhrase(counter, localizationService),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              height: 1.2,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Botones de acción en column
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Botón de estrategias
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.psychology,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            tooltip: 'Ver estrategias',
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ChallengeStrategiesPage(
                                                    challengeId: index,
                                                    challengeTitle: counter.title,
                                                    challengeType: _getChallengeType(counter.title),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Botón de eliminar
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            tooltip: 'Eliminar reto',
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Eliminar reto'),
                                                  content: const Text(
                                                    '¿Seguro que deseas eliminar este reto? Esta acción no se puede deshacer.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(false),
                                                      child: const Text('Cancelar'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(true),
                                                      child: const Text(
                                                        'Eliminar',
                                                        style: TextStyle(color: Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                _deleteCounter(index);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Contador de tiempo
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: counter.color.color.withOpacity(0.3),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: counter.challengeStartedAt != null
                                    ? _LiveStreakTimer(
                                        startDate: counter.challengeStartedAt!,
                                        lastConfirmedDate: counter.lastConfirmedDate,
                                        confirmedToday: confirmedToday,
                                        fontSize: 22,
                                      )
                                    : Text(
                                        '0d 0h 0m 0s',
                                        style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.green[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                ),
                              ),
                              
                              // Mensaje motivacional
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                child: Text(
                                  '${localizationService.t('keepGoing')} ${localizationService.t('everySecondCounts')}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              
                              // Botón de acción principal
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  bottom: 20,
                                ),
                                child: counter.challengeStartedAt == null
                                  ? SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: counter.color.color,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          textStyle: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          elevation: 2,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            counter.challengeStartedAt = DateTime.now();
                                            counter.lastConfirmedDate = DateTime(
                                              now.year,
                                              now.month,
                                              now.day,
                                            );
                                          });
                                          _saveCounters();
                                        },
                                        icon: const Icon(Icons.play_arrow, size: 24),
                                        label: const Text('Iniciar reto'),
                                      ),
                                    )
                                  : !_isSameDay(counter.lastConfirmedDate!, now)
                                    ? SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: counter.color.color,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            textStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            elevation: 2,
                                          ),
                                      onPressed: () async {
                                        // Mostrar diálogo de confirmación
                                        final result = await showDialog<bool>(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Row(
                                                children: [
                                                  Icon(
                                                    counter.isNegativeHabit ? Icons.block : Icons.fitness_center,
                                                    color: Colors.orange,
                                                    size: 28,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  const Expanded(
                                                    child: Text(
                                                      '¿Cumpliste tu reto hoy?',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          counter.isNegativeHabit ? Icons.sentiment_satisfied : Icons.emoji_events,
                                                          color: Colors.orange,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            counter.isNegativeHabit 
                                                              ? '${_challengePhrase(counter, localizationService)}'
                                                              : '${_challengePhrase(counter, localizationService)}',
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  const Text(
                                                    'Selecciona tu progreso de hoy:',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actionsPadding: const EdgeInsets.all(16),
                                              actions: [
                                                // Botón "No cumplí"
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton.icon(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.red,
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    onPressed: () => Navigator.of(context).pop(false),
                                                    icon: const Icon(Icons.close, size: 20),
                                                    label: const Text(
                                                      'No cumplí hoy',
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                // Botón "¡Sí cumplí!"
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton.icon(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.green,
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    onPressed: () => Navigator.of(context).pop(true),
                                                    icon: const Icon(Icons.check_circle, size: 20),
                                                    label: const Text(
                                                      '¡Sí cumplí!',
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        // Procesar resultado
                                        if (result != null) {
                                          setState(() {
                                            counter.lastConfirmedDate = DateTime(
                                              now.year,
                                              now.month,
                                              now.day,
                                            );
                                          });
                                          await _saveCounters();

                                          if (result) {
                                            // Usuario cumplió el reto
                                            await StatisticsService.instance.recordChallengeConfirmation();
                                            await AchievementService.instance.checkAndUnlockAchievements(
                                              StatisticsService.instance.statistics
                                            );

                                            // Mostrar mensaje de éxito
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      const Icon(Icons.emoji_events, color: Colors.white, size: 20),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          '¡Excelente! +${10 + (StatisticsService.instance.statistics.currentStreak * 2)} puntos',
                                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(seconds: 3),
                                                ),
                                              );
                                            }
                                          } else {
                                            // Usuario no cumplió el reto
                                            await StatisticsService.instance.recordChallengeFailure();

                                            // Mostrar mensaje motivacional
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Icon(Icons.sentiment_neutral, color: Colors.white, size: 20),
                                                      SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          'No te preocupes, mañana es un nuevo día. ¡Tú puedes!',
                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor: Colors.orange,
                                                  duration: Duration(seconds: 4),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.check_circle, size: 24),
                                      label: const Text('¿Cumpliste hoy?'),
                                    ),
                                  )
                                : // Reto completado para hoy
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '¡Completado hoy!',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'countersFab',
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        onPressed: _navigateToAddCounter,
        child: const Icon(Icons.add),
      ),
    );
      },
    );
  }

  /// Determina el tipo de reto basado en el título para generar estrategias apropiadas
  String _getChallengeType(String title) {
    final titleLower = title.toLowerCase();
    
    // Detectar tipo de reto por palabras clave
    if (titleLower.contains('agua') || titleLower.contains('water') || titleLower.contains('hidratar')) {
      return 'water';
    } else if (titleLower.contains('ejercicio') || titleLower.contains('gym') || titleLower.contains('correr') || 
               titleLower.contains('exercise') || titleLower.contains('workout') || titleLower.contains('fitness')) {
      return 'exercise';
    } else if (titleLower.contains('leer') || titleLower.contains('libro') || titleLower.contains('reading') || 
               titleLower.contains('book') || titleLower.contains('lectura')) {
      return 'reading';
    } else if (titleLower.contains('meditar') || titleLower.contains('meditation') || titleLower.contains('mindfulness') ||
               titleLower.contains('relajar') || titleLower.contains('respirar')) {
      return 'meditation';
    } else if (titleLower.contains('fumar') || titleLower.contains('cigarro') || titleLower.contains('smoke') ||
               titleLower.contains('tabaco') || titleLower.contains('nicotina')) {
      return 'quit_smoking';
    } else if (titleLower.contains('ahorrar') || titleLower.contains('dinero') || titleLower.contains('money') ||
               titleLower.contains('save') || titleLower.contains('financiero')) {
      return 'save_money';
    } else {
      // Tipo genérico para retos no específicos
      return 'generic';
    }
  }
}

class _LiveStreakTimer extends StatefulWidget {
  final DateTime startDate;
  final DateTime? lastConfirmedDate;
  final bool confirmedToday;
  final double? fontSize;
  const _LiveStreakTimer({
    Key? key,
    required this.startDate,
    required this.lastConfirmedDate,
    required this.confirmedToday,
    this.fontSize,
  }) : super(key: key);
  @override
  State<_LiveStreakTimer> createState() => _LiveStreakTimerState();
}

class _LiveStreakTimerState extends State<_LiveStreakTimer> {
  late Duration _duration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateDuration();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateDuration(),
    );
  }

  void _updateDuration() {
    setState(() {
      final now = DateTime.now();
      _duration = now.difference(widget.startDate);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _duration.inDays;
    final hours = _duration.inHours.remainder(24);
    final minutes = _duration.inMinutes.remainder(60);
    final seconds = _duration.inSeconds.remainder(60);

    int years = 0;
    int months = 0;
    int remDays = days;
    if (days >= 30) {
      // Calcular meses y años aproximados
      final start =
          widget.lastConfirmedDate == null ? DateTime.now() : widget.startDate;
      final end =
          (widget.lastConfirmedDate != null &&
                  widget.lastConfirmedDate!.isAfter(widget.startDate))
              ? (widget.confirmedToday
                  ? DateTime.now()
                  : widget.lastConfirmedDate!)
              : DateTime.now();
      years = end.year - start.year;
      months = end.month - start.month;
      remDays = end.day - start.day;
      if (remDays < 0) {
        final prevMonth = DateTime(end.year, end.month, 0).day;
        remDays += prevMonth;
        months--;
      }
      if (months < 0) {
        months += 12;
        years--;
      }
    }

    List<Widget> timeWidgets = [];
    final fontSize = widget.fontSize ?? 15;
    if (years > 0) {
      timeWidgets.add(_buildTimeBox(years, 'a', fontSize));
      timeWidgets.add(const SizedBox(width: 2));
    }
    if (months > 0 || years > 0) {
      timeWidgets.add(_buildTimeBox(months, 'm', fontSize - 2));
      timeWidgets.add(const SizedBox(width: 2));
    }
    if (days >= 30) {
      timeWidgets.add(_buildTimeBox(remDays, 'd', fontSize - 4));
    } else {
      timeWidgets.add(_buildTimeBox(days, 'd', fontSize));
      timeWidgets.add(const SizedBox(width: 2));
      timeWidgets.add(_buildTimeBox(hours, 'h', fontSize - 2));
      timeWidgets.add(const SizedBox(width: 2));
      timeWidgets.add(_buildTimeBox(minutes, 'm', fontSize - 4));
      timeWidgets.add(const SizedBox(width: 2));
      timeWidgets.add(_buildTimeBox(seconds, 's', fontSize - 6));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: timeWidgets,
    );
  }

  Widget _buildTimeBox(int value, String label, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$value',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            TextSpan(
              text: ' $label',
              style: TextStyle(
                fontSize: fontSize - 3,
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
