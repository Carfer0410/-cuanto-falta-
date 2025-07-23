import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'add_counter_page.dart';
import 'localization_service.dart';
import 'statistics_service.dart';
import 'achievement_service.dart';
import 'individual_streak_service.dart';
import 'individual_streaks_page.dart';
import 'milestone_notification_service.dart';
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

  /// Generar ID único para un desafío basado en el índice
  String _getChallengeId(int index) {
    return 'challenge_$index';
  }

  Future<void> _loadCounters() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('counters');
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      _counters = decoded.map((e) => Counter.fromJson(e)).toList();
    }
    
    // MIGRACIÓN: Inicializar challengeStartedAt para retos existentes que no lo tienen
    bool needsSave = false;
    for (int i = 0; i < _counters.length; i++) {
      if (_counters[i].challengeStartedAt == null) {
        // Para retos existentes, usar su startDate como challengeStartedAt
        _counters[i] = Counter(
          title: _counters[i].title,
          startDate: _counters[i].startDate,
          lastConfirmedDate: _counters[i].lastConfirmedDate,
          isNegativeHabit: _counters[i].isNegativeHabit,
          challengeStartedAt: _counters[i].startDate, // Usar startDate como inicio del cronómetro
          color: _counters[i].color,
          icon: _counters[i].icon,
        );
        needsSave = true;
      }
    }
    
    // Guardar los cambios si se hizo alguna migración
    if (needsSave) {
      await _saveCounters();
      print('✅ Migración: challengeStartedAt inicializado para ${_counters.length} retos');
    }
    
    // Registrar todos los desafíos en el sistema de rachas individuales
    for (int i = 0; i < _counters.length; i++) {
      final challengeId = _getChallengeId(i);
      await IndividualStreakService.instance.registerChallenge(
        challengeId,
        _counters[i].title,
      );
    }
    
    // NOTA: No actualizar estadísticas aquí para evitar duplicación
    // Las estadísticas se actualizan solo cuando se crean/modifican retos
    // o durante la migración/sincronización manual
    
    // 🆕 NUEVO: Debug de estado de botones
    _debugButtonStates();
    
    setState(() {});
  }

  /// 🆕 DEBUG: Verifica el estado de los botones para identificar problemas
  void _debugButtonStates() {
    final now = DateTime.now();
    print('\n🔍 === DEBUG ESTADO DE BOTONES (${now.day}/${now.month} ${now.hour}:${now.minute.toString().padLeft(2, '0')}) ===');
    
    for (int i = 0; i < _counters.length; i++) {
      final counter = _counters[i];
      final challengeId = _getChallengeId(i);
      final streak = IndividualStreakService.instance.getStreak(challengeId);
      
      final shouldShow = _shouldShowConfirmationButton(counter, now);
      final buttonType = counter.challengeStartedAt == null ? 'INICIAR' : 
                        shouldShow ? 'CONFIRMAR' : 'COMPLETADO';
      
      print('📱 "${counter.title}" → $buttonType');
      print('   • Iniciado: ${counter.challengeStartedAt != null ? _formatStartDate(counter.challengeStartedAt!) : 'NO'}');
      print('   • Última confirmación: ${counter.lastConfirmedDate != null ? '${counter.lastConfirmedDate!.day}/${counter.lastConfirmedDate!.month}' : 'NUNCA'}');
      print('   • Racha actual: ${streak?.currentStreak ?? 0} días');
      print('   • Completado hoy (streak): ${streak?.isCompletedToday ?? false}');
      print('');
    }
    print('=== FIN DEBUG ===\n');
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

  void _deleteCounter(int index) async {
    // Eliminar racha individual correspondiente
    final challengeId = _getChallengeId(index);
    await IndividualStreakService.instance.removeChallenge(challengeId);
    
    setState(() {
      _counters.removeAt(index);
    });
    _saveCounters();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// 🆕 MEJORADO: Determina si debe mostrar el botón de confirmación
  /// Combina lógica del Counter y del sistema de rachas individuales
  bool _shouldShowConfirmationButton(Counter counter, DateTime now) {
    // 1. Verificar que el reto esté iniciado
    if (counter.challengeStartedAt == null) return false;
    
    // 2. Verificar que no esté confirmado hoy según Counter
    final notConfirmedTodayByCounter = counter.lastConfirmedDate == null || 
                                      !_isSameDay(counter.lastConfirmedDate!, now);
    
    // 3. Verificar que no esté confirmado hoy según sistema de rachas individuales
    final challengeId = _getChallengeId(_counters.indexOf(counter));
    final streak = IndividualStreakService.instance.getStreak(challengeId);
    final notConfirmedTodayByStreak = streak?.isCompletedToday != true;
    
    // 4. Debe cumplir AMBAS condiciones para mostrar el botón
    final shouldShow = notConfirmedTodayByCounter && notConfirmedTodayByStreak;
    
    // 5. CORREGIR INCONSISTENCIAS: Si hay desincronización, corregir
    if (notConfirmedTodayByCounter != notConfirmedTodayByStreak) {
      print('⚠️ INCONSISTENCIA detectada en "${counter.title}":');
      print('  • Counter dice no confirmado: $notConfirmedTodayByCounter');
      print('  • Streak dice no confirmado: $notConfirmedTodayByStreak');
      
      // Si el streak dice que está completado pero el counter no, sincronizar
      if (!notConfirmedTodayByStreak && notConfirmedTodayByCounter) {
        print('  → Sincronizando: Counter marca como completado hoy');
        counter.lastConfirmedDate = DateTime(now.year, now.month, now.day);
        _saveCounters(); // Guardar la corrección
      }
    }
    
    // 6. Debug logging para identificar problemas
    if (!shouldShow) {
      print('🔍 Debug - No se muestra botón para "${counter.title}":');
      print('  • Counter lastConfirmed: ${counter.lastConfirmedDate}');
      print('  • Streak completedToday: ${streak?.isCompletedToday}');
      print('  • Counter dice no confirmado: $notConfirmedTodayByCounter');
      print('  • Streak dice no confirmado: $notConfirmedTodayByStreak');
    }
    
    return shouldShow;
  }

  /// Formatea la fecha de inicio del reto de manera amigable
  String _formatStartDate(DateTime date) {
    // Mostrar fecha exacta en formato dd/mm/yyyy para mayor claridad
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    
    return 'el $day/$month/$year';
  }

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
          // 🆕 NUEVO: Botón de acceso rápido a rachas individuales
          IconButton(
            icon: const Icon(Icons.local_fire_department),
            tooltip: 'Ver todas las rachas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IndividualStreaksPage(),
                ),
              );
            },
          ),
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
                    '- Pulsa “Guardar reto” para comenzar a contar tu progreso.\n'
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
      body: Column(
        children: [
          // 📊 NUEVO: Header con estadísticas globales
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[100]!, Colors.orange[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Consumer<IndividualStreakService>(
              builder: (context, streakService, child) {
                final globalStats = streakService.getGlobalStats();
                final activeCount = globalStats['activeChallenges'] ?? 0;
                final totalPoints = globalStats['totalPoints'] ?? 0;
                final avgStreak = (globalStats['averageStreak'] ?? 0.0) as double;
                
                return Row(
                  children: [
                    // Retos activos
                    Expanded(
                      child: _buildStatCard(
                        '🎯',
                        '$activeCount',
                        'Retos activos',
                        Colors.blue[600]!,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Puntos totales
                    Expanded(
                      child: _buildStatCard(
                        '⭐',
                        '$totalPoints',
                        'Puntos',
                        Colors.amber[600]!,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Racha promedio
                    Expanded(
                      child: _buildStatCard(
                        '🔥',
                        '${avgStreak.toStringAsFixed(1)}',
                        'Promedio',
                        Colors.orange[600]!,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Lista de retos existente
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                              colors: [
                                counter.color.color.withOpacity(0.15),
                                counter.color.lightColor.withOpacity(0.08),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: counter.color.color.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: counter.color.color.withOpacity(0.2),
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
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _challengePhrase(counter, localizationService),
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey[800],
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
                                            color: counter.color.color.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: counter.color.color.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.psychology,
                                              color: counter.color.color,
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
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.red.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
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
                                      color: counter.color.color.withOpacity(0.4),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: counter.color.color.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: _IndividualStreakDisplay(
                                    challengeId: _getChallengeId(index),
                                    startDate: counter.challengeStartedAt ?? counter.startDate,
                                    lastConfirmedDate: counter.lastConfirmedDate,
                                    confirmedToday: confirmedToday,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                              
                              // Mensaje motivacional y fecha de inicio
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                child: Column(
                                  children: [
                                    // 🆕 NUEVO: Progreso semanal
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: counter.color.color.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: counter.color.color.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Consumer<IndividualStreakService>(
                                        builder: (context, streakService, child) {
                                          final streak = streakService.getStreak(_getChallengeId(index));
                                          final weeklyProgress = _calculateWeeklyProgress(streak);
                                          
                                          return Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'Esta semana',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey[700],
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${weeklyProgress['completed']}/${weeklyProgress['total']} días',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: counter.color.color,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              // Barra de progreso semanal
                                              LinearProgressIndicator(
                                                value: weeklyProgress['progress'] as double,
                                                backgroundColor: Colors.grey[300],
                                                valueColor: AlwaysStoppedAnimation<Color>(counter.color.color),
                                                minHeight: 6,
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Fecha de inicio del reto
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: counter.color.color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: counter.color.color.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: Colors.black87,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Reto iniciado: ${_formatStartDate(counter.challengeStartedAt ?? counter.startDate)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Mensaje motivacional
                                    Text(
                                      '${localizationService.t('keepGoing')} ${localizationService.t('everySecondCounts')}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
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
                                  : _shouldShowConfirmationButton(counter, now)
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
                                            final challengeId = _getChallengeId(index);
                                            await IndividualStreakService.instance.confirmChallenge(
                                              challengeId, 
                                              counter.title,
                                              isNegativeHabit: counter.isNegativeHabit,
                                            );
                                            
                                            // Obtener nueva racha individual
                                            final streak = IndividualStreakService.instance.getStreak(challengeId);
                                            final currentStreak = streak?.currentStreak ?? 1;
                                            final pointsEarned = 10 + (currentStreak * 2);
                                            
                                            // Actualizar logros basados en estadísticas globales
                                            await AchievementService.instance.checkAndUnlockAchievements(
                                              StatisticsService.instance.statistics
                                            );

                                            // Mostrar mensaje de éxito con información de racha individual
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      const Icon(Icons.emoji_events, color: Colors.white, size: 20),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          '¡Excelente! +$pointsEarned puntos | Racha: $currentStreak días',
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
                                            // Usuario no cumplió el reto - mostrar opciones de perdón
                                            final challengeId = _getChallengeId(index);
                                            final streak = IndividualStreakService.instance.getStreak(challengeId);
                                            
                                            if (streak != null && streak.canUseForgiveness && streak.currentStreak > 0) {
                                              // Mostrar diálogo de ficha de perdón
                                              final useForgiveness = await _showForgivenessDialog(
                                                context, 
                                                streak.forgivenessTokens,
                                                streak.currentStreak
                                              );
                                              
                                              final wasForgiven = await IndividualStreakService.instance.failChallenge(
                                                challengeId,
                                                counter.title,
                                                useForgiveness: useForgiveness ?? false
                                              );
                                              
                                              if (mounted) {
                                                if (wasForgiven) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Row(
                                                        children: [
                                                          const Icon(Icons.shield, color: Colors.white, size: 20),
                                                          const SizedBox(width: 8),
                                                          Expanded(
                                                            child: Text(
                                                              '🛡️ Ficha de perdón usada. Tu racha de ${streak.currentStreak} días está segura',
                                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      backgroundColor: Colors.blue,
                                                      duration: const Duration(seconds: 4),
                                                    ),
                                                  );
                                                } else {
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
                                            } else {
                                              // Fallo directo sin opciones de perdón
                                              await IndividualStreakService.instance.failChallenge(
                                                challengeId,
                                                counter.title,
                                                useForgiveness: false
                                              );
                                              
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
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.green[300]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green[600],
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '¡Completado hoy!',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.green[700],
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
          ),
        ],
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

  /// Calcula el progreso de la semana actual para un reto
  Map<String, dynamic> _calculateWeeklyProgress(ChallengeStreak? streak) {
    if (streak == null) {
      return {'completed': 0, 'total': 0, 'progress': 0.0};
    }

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final today = DateTime(now.year, now.month, now.day);
    
    int completedDays = 0;
    int totalDays = 0;

    // Contar días de esta semana
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayDate = DateTime(day.year, day.month, day.day);
      
      if (dayDate.isAfter(today)) break; // No contar días futuros
      totalDays++;

      // Verificar si se completó este día
      final wasCompleted = streak.confirmationHistory.any((confirmation) {
        final confirmDate = DateTime(confirmation.year, confirmation.month, confirmation.day);
        return confirmDate.isAtSameMomentAs(dayDate);
      });

      if (wasCompleted) {
        completedDays++;
      }
    }

    final progress = totalDays > 0 ? completedDays / totalDays : 0.0;
    
    return {
      'completed': completedDays,
      'total': totalDays,
      'progress': progress,
    };
  }
  
  /// 🔮 FUTURO: Obtener información del próximo hito (para versiones futuras)
  Future<String> _getNextMilestoneInfo(String challengeId, int currentStreak) async {
    try {
      final milestoneStats = await MilestoneNotificationService.getMilestoneStats(challengeId);
      final nextMilestone = milestoneStats['nextMilestone'] as int;
      final daysToNext = nextMilestone - currentStreak;
      
      if (daysToNext <= 0) return '';
      
      String milestoneLabel = '';
      if (nextMilestone == 7) milestoneLabel = 'una semana';
      else if (nextMilestone == 30) milestoneLabel = 'un mes';
      else if (nextMilestone == 365) milestoneLabel = 'un año';
      else milestoneLabel = '$nextMilestone días';
      
      return 'Próximo hito: $milestoneLabel (faltan $daysToNext días)';
    } catch (e) {
      return '';
    }
  }

  /// Widget para mostrar estadísticas en cards pequeñas
  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Determina el tipo de reto basado en el título para generar estrategias apropiadas
  String _getChallengeType(String title) {
    final titleLower = title.toLowerCase();
    
    // 💧 AGUA / HIDRATACIÓN
    if (titleLower.contains('agua') || titleLower.contains('water') || titleLower.contains('hidratar') || 
        titleLower.contains('tomar agua') || titleLower.contains('beber') || titleLower.contains('hidratación') ||
        titleLower.contains('litros') || titleLower.contains('vasos')) {
      return 'water';
    }
    
    // 🏃‍♂️ EJERCICIO / FITNESS
    else if (titleLower.contains('ejercicio') || titleLower.contains('gym') || titleLower.contains('correr') || 
             titleLower.contains('exercise') || titleLower.contains('workout') || titleLower.contains('fitness') ||
             titleLower.contains('deporte') || titleLower.contains('entrenar') || titleLower.contains('caminar') ||
             titleLower.contains('trotar') || titleLower.contains('cardio') || titleLower.contains('musculo') ||
             titleLower.contains('peso') || titleLower.contains('abdominales') || titleLower.contains('flexiones') ||
             titleLower.contains('yoga') || titleLower.contains('pilates') || titleLower.contains('crossfit') ||
             titleLower.contains('natación') || titleLower.contains('nadar') || titleLower.contains('ciclismo') ||
             titleLower.contains('bicicleta') || titleLower.contains('pesas') || titleLower.contains('físico')) {
      return 'exercise';
    }
    
    // 📚 LECTURA / ESTUDIO
    else if (titleLower.contains('leer') || titleLower.contains('libro') || titleLower.contains('reading') || 
             titleLower.contains('book') || titleLower.contains('lectura') || titleLower.contains('estudiar') ||
             titleLower.contains('aprender') || titleLower.contains('curso') || titleLower.contains('páginas') ||
             titleLower.contains('novela') || titleLower.contains('educación') || titleLower.contains('conocimiento') ||
             titleLower.contains('idioma') || titleLower.contains('inglés') || titleLower.contains('francés') ||
             titleLower.contains('programación') || titleLower.contains('código') || titleLower.contains('skill')) {
      return 'reading';
    }
    
    // 🧘‍♀️ MEDITACIÓN / MINDFULNESS
    else if (titleLower.contains('meditar') || titleLower.contains('meditation') || titleLower.contains('mindfulness') ||
             titleLower.contains('relajar') || titleLower.contains('respirar') || titleLower.contains('calma') ||
             titleLower.contains('paz') || titleLower.contains('zen') || titleLower.contains('tranquilo') ||
             titleLower.contains('estrés') || titleLower.contains('ansiedad') || titleLower.contains('mental') ||
             titleLower.contains('espiritual') || titleLower.contains('consciencia') || titleLower.contains('presente')) {
      return 'meditation';
    }
    
    // 🚭 DEJAR DE FUMAR
    else if (titleLower.contains('fumar') || titleLower.contains('cigarro') || titleLower.contains('smoke') ||
             titleLower.contains('tabaco') || titleLower.contains('nicotina') || titleLower.contains('cigarrillo') ||
             titleLower.contains('puro') || titleLower.contains('vaper') || titleLower.contains('vape') ||
             titleLower.contains('hookah') || titleLower.contains('shisha') || titleLower.contains('marlboro') ||
             titleLower.contains('camel') || titleLower.contains('dejar de fumar') || titleLower.contains('quit smoking')) {
      return 'quit_smoking';
    }
    
    // 💰 AHORRAR DINERO / FINANZAS
    else if (titleLower.contains('ahorrar') || titleLower.contains('dinero') || titleLower.contains('money') ||
             titleLower.contains('save') || titleLower.contains('financiero') || titleLower.contains('economia') ||
             titleLower.contains('gasto') || titleLower.contains('presupuesto') || titleLower.contains('inversión') ||
             titleLower.contains('deuda') || titleLower.contains('banco') || titleLower.contains('peso') ||
             titleLower.contains('dólar') || titleLower.contains('euro') || titleLower.contains('comprar menos') ||
             titleLower.contains('gastar menos') || titleLower.contains('economizar')) {
      return 'save_money';
    }
    
    // 🍎 ALIMENTACIÓN SALUDABLE
    else if (titleLower.contains('comer sano') || titleLower.contains('dieta') || titleLower.contains('vegetales') ||
             titleLower.contains('frutas') || titleLower.contains('verduras') || titleLower.contains('ensalada') ||
             titleLower.contains('proteína') || titleLower.contains('vitamina') || titleLower.contains('nutrición') ||
             titleLower.contains('saludable') || titleLower.contains('orgánico') || titleLower.contains('natural') ||
             titleLower.contains('fibra') || titleLower.contains('calcio') || titleLower.contains('omega') ||
             titleLower.contains('antioxidante') || titleLower.contains('superfood') || titleLower.contains('detox')) {
      return 'healthy_eating';
    }
    
    // 🍟 DEJAR COMIDA CHATARRA
    else if (titleLower.contains('chatarra') || titleLower.contains('junk food') || titleLower.contains('comida rápida') ||
             titleLower.contains('mcdonalds') || titleLower.contains('burger') || titleLower.contains('pizza') ||
             titleLower.contains('papas fritas') || titleLower.contains('refresco') || titleLower.contains('coca cola') ||
             titleLower.contains('dulces') || titleLower.contains('chocolate') || titleLower.contains('galletas') ||
             titleLower.contains('chips') || titleLower.contains('frituras') || titleLower.contains('azúcar') ||
             titleLower.contains('grasa') || titleLower.contains('procesado') || titleLower.contains('fast food') ||
             titleLower.contains('carbohidratos') || titleLower.contains('harinas') || titleLower.contains('postres')) {
      return 'quit_junk_food';
    }
    
    // 🍺 DEJAR ALCOHOL
    else if (titleLower.contains('alcohol') || titleLower.contains('beber') || titleLower.contains('cerveza') ||
             titleLower.contains('vino') || titleLower.contains('whisky') || titleLower.contains('vodka') ||
             titleLower.contains('ron') || titleLower.contains('tequila') || titleLower.contains('licor') ||
             titleLower.contains('trago') || titleLower.contains('copa') || titleLower.contains('bar') ||
             titleLower.contains('borracho') || titleLower.contains('drunk') || titleLower.contains('drinking') ||
             titleLower.contains('alcoholismo') || titleLower.contains('sobrio') || titleLower.contains('abstemio')) {
      return 'quit_alcohol';
    }
    
    // 📱 REDUCIR REDES SOCIALES / PANTALLAS
    else if (titleLower.contains('redes sociales') || titleLower.contains('facebook') || titleLower.contains('instagram') ||
             titleLower.contains('tiktok') || titleLower.contains('twitter') || titleLower.contains('youtube') ||
             titleLower.contains('whatsapp') || titleLower.contains('snapchat') || titleLower.contains('telefono') ||
             titleLower.contains('celular') || titleLower.contains('pantalla') || titleLower.contains('movil') ||
             titleLower.contains('social media') || titleLower.contains('scroll') || titleLower.contains('likes') ||
             titleLower.contains('netflix') || titleLower.contains('streaming') || titleLower.contains('series') ||
             titleLower.contains('videojuegos') || titleLower.contains('gaming') || titleLower.contains('internet') ||
             titleLower.contains('digital') || titleLower.contains('screen time') || titleLower.contains('adicción al móvil')) {
      return 'reduce_screen_time';
    }
    
    // 😴 DORMIR MEJOR
    else if (titleLower.contains('dormir') || titleLower.contains('sueño') || titleLower.contains('sleep') ||
             titleLower.contains('descanso') || titleLower.contains('insomnio') || titleLower.contains('cama') ||
             titleLower.contains('temprano') || titleLower.contains('madrugar') || titleLower.contains('rutina nocturna') ||
             titleLower.contains('horas de sueño') || titleLower.contains('despertar') || titleLower.contains('siesta') ||
             titleLower.contains('relajarse') || titleLower.contains('bed time') || titleLower.contains('acostarse')) {
      return 'better_sleep';
    }
    
    // 💊 DEJAR DROGAS
    else if (titleLower.contains('droga') || titleLower.contains('marihuana') || titleLower.contains('cannabis') ||
             titleLower.contains('cocaina') || titleLower.contains('heroina') || titleLower.contains('lsd') ||
             titleLower.contains('extasis') || titleLower.contains('anfetamina') || titleLower.contains('crack') ||
             titleLower.contains('meth') || titleLower.contains('opioides') || titleLower.contains('porro') ||
             titleLower.contains('joint') || titleLower.contains('weed') || titleLower.contains('hash') ||
             titleLower.contains('sustancia') || titleLower.contains('estupefaciente') || titleLower.contains('adicción')) {
      return 'quit_drugs';
    }
    
    // 🎮 REDUCIR VIDEOJUEGOS
    else if (titleLower.contains('videojuegos') || titleLower.contains('gaming') || titleLower.contains('ps5') ||
             titleLower.contains('xbox') || titleLower.contains('nintendo') || titleLower.contains('pc gaming') ||
             titleLower.contains('fortnite') || titleLower.contains('call of duty') || titleLower.contains('fifa') ||
             titleLower.contains('league of legends') || titleLower.contains('valorant') || titleLower.contains('minecraft') ||
             titleLower.contains('steam') || titleLower.contains('twitch') || titleLower.contains('console') ||
             titleLower.contains('online gaming') || titleLower.contains('jugar menos') || titleLower.contains('game addiction')) {
      return 'reduce_gaming';
    }
    
    // 🔞 DEJAR PORNOGRAFÍA / MASTURBACIÓN
    else if (titleLower.contains('masturbación') || titleLower.contains('masturbarse') || titleLower.contains('masturbar') ||
             titleLower.contains('masturbation') || titleLower.contains('pornografía') || titleLower.contains('porn') ||
             titleLower.contains('porno') || titleLower.contains('xxx') || titleLower.contains('contenido adulto') ||
             titleLower.contains('sexual') || titleLower.contains('nofap') || titleLower.contains('noporn') ||
             titleLower.contains('abstinencia sexual') || titleLower.contains('adicción sexual')) {
      return 'quit_sexual_habits';
    }
    
    // 🛏️ DEJAR PROCRASTINACIÓN
    else if (titleLower.contains('procrastinar') || titleLower.contains('procrastinación') || titleLower.contains('pereza') ||
             titleLower.contains('flojera') || titleLower.contains('productividad') || titleLower.contains('tareas') ||
             titleLower.contains('responsabilidades') || titleLower.contains('postponer') || titleLower.contains('delay') ||
             titleLower.contains('lazy') || titleLower.contains('motivación') || titleLower.contains('disciplina') ||
             titleLower.contains('organización') || titleLower.contains('tiempo') || titleLower.contains('eficiencia')) {
      return 'stop_procrastination';
    }
    
    // 🤬 CONTROLAR IRA / AGRESIVIDAD
    else if (titleLower.contains('ira') || titleLower.contains('enojo') || titleLower.contains('agresividad') ||
             titleLower.contains('gritar') || titleLower.contains('violencia') || titleLower.contains('anger') ||
             titleLower.contains('furioso') || titleLower.contains('berrinche') || titleLower.contains('mal genio') ||
             titleLower.contains('explotar') || titleLower.contains('pelear') || titleLower.contains('discutir') ||
             titleLower.contains('paciencia') || titleLower.contains('calma') || titleLower.contains('autocontrol')) {
      return 'anger_management';
    }
    
    // 😰 REDUCIR ANSIEDAD / ESTRÉS
    else if (titleLower.contains('ansiedad') || titleLower.contains('anxiety') || titleLower.contains('estrés') ||
             titleLower.contains('stress') || titleLower.contains('nervios') || titleLower.contains('worry') ||
             titleLower.contains('preocupación') || titleLower.contains('pánico') || titleLower.contains('tensión') ||
             titleLower.contains('agobio') || titleLower.contains('overwhelmed') || titleLower.contains('mental health') ||
             titleLower.contains('salud mental') || titleLower.contains('depresión') || titleLower.contains('tristeza')) {
      return 'reduce_anxiety';
    }
    
    // 🚗 MANEJAR MEJOR / SEGURIDAD VIAL
    else if (titleLower.contains('manejar') || titleLower.contains('conducir') || titleLower.contains('driving') ||
             titleLower.contains('carro') || titleLower.contains('auto') || titleLower.contains('velocidad') ||
             titleLower.contains('tráfico') || titleLower.contains('road rage') || titleLower.contains('seguridad vial') ||
             titleLower.contains('accidente') || titleLower.contains('multa') || titleLower.contains('licencia')) {
      return 'better_driving';
    }
    
    // 💕 RELACIONES / AMOR
    else if (titleLower.contains('relación') || titleLower.contains('pareja') || titleLower.contains('amor') ||
             titleLower.contains('novio') || titleLower.contains('novia') || titleLower.contains('esposo') ||
             titleLower.contains('esposa') || titleLower.contains('matrimonio') || titleLower.contains('comunicación') ||
             titleLower.contains('celos') || titleLower.contains('confianza') || titleLower.contains('romance') ||
             titleLower.contains('dating') || titleLower.contains('relationship') || titleLower.contains('compromiso')) {
      return 'better_relationships';
    }
    
    // 👥 HABILIDADES SOCIALES
    else if (titleLower.contains('hablar en público') || titleLower.contains('timidez') || titleLower.contains('social') ||
             titleLower.contains('amigos') || titleLower.contains('networking') || titleLower.contains('conversación') ||
             titleLower.contains('shy') || titleLower.contains('introvertido') || titleLower.contains('confianza') ||
             titleLower.contains('público') || titleLower.contains('presentación') || titleLower.contains('comunicar')) {
      return 'social_skills';
    }
    
    // 🧹 ORGANIZACIÓN / LIMPIEZA
    else if (titleLower.contains('limpiar') || titleLower.contains('organizar') || titleLower.contains('ordenar') ||
             titleLower.contains('casa') || titleLower.contains('cuarto') || titleLower.contains('cocina') ||
             titleLower.contains('baño') || titleLower.contains('closet') || titleLower.contains('limpieza') ||
             titleLower.contains('organize') || titleLower.contains('cleaning') || titleLower.contains('messy') ||
             titleLower.contains('desorden') || titleLower.contains('marie kondo') || titleLower.contains('minimalismo')) {
      return 'organization';
    }
    
    // 💼 TRABAJO / CARRERA
    else if (titleLower.contains('trabajo') || titleLower.contains('carrera') || titleLower.contains('profesional') ||
             titleLower.contains('empleo') || titleLower.contains('job') || titleLower.contains('career') ||
             titleLower.contains('oficina') || titleLower.contains('jefe') || titleLower.contains('empresa') ||
             titleLower.contains('salario') || titleLower.contains('promotion') || titleLower.contains('cv') ||
             titleLower.contains('resume') || titleLower.contains('entrevista') || titleLower.contains('networking')) {
      return 'career_development';
    }
    
    // 🎨 CREATIVIDAD / ARTE
    else if (titleLower.contains('dibujar') || titleLower.contains('pintar') || titleLower.contains('arte') ||
             titleLower.contains('creatividad') || titleLower.contains('música') || titleLower.contains('tocar') ||
             titleLower.contains('guitarra') || titleLower.contains('piano') || titleLower.contains('cantar') ||
             titleLower.contains('escribir') || titleLower.contains('poesía') || titleLower.contains('fotografía') ||
             titleLower.contains('creative') || titleLower.contains('artístico') || titleLower.contains('manualidades')) {
      return 'creativity';
    }
    
    // � APRENDER INSTRUMENTO MUSICAL
    else if (titleLower.contains('guitarra') || titleLower.contains('piano') || titleLower.contains('violin') ||
             titleLower.contains('batería') || titleLower.contains('bajo') || titleLower.contains('flauta') ||
             titleLower.contains('saxofón') || titleLower.contains('trompeta') || titleLower.contains('ukulele') ||
             titleLower.contains('armónica') || titleLower.contains('instrumento') || titleLower.contains('música') ||
             titleLower.contains('tocar') || titleLower.contains('cantar') || titleLower.contains('aprender música') ||
             titleLower.contains('clases de música') || titleLower.contains('conservatorio') || titleLower.contains('música')) {
      return 'learn_instrument';
    }
    
    // 🌍 APRENDER IDIOMAS
    else if (titleLower.contains('inglés') || titleLower.contains('francés') || titleLower.contains('alemán') ||
             titleLower.contains('japonés') || titleLower.contains('chino') || titleLower.contains('italiano') ||
             titleLower.contains('portugués') || titleLower.contains('ruso') || titleLower.contains('árabe') ||
             titleLower.contains('coreano') || titleLower.contains('idioma') || titleLower.contains('language') ||
             titleLower.contains('speaking') || titleLower.contains('grammar') || titleLower.contains('vocabulary') ||
             titleLower.contains('duolingo') || titleLower.contains('babbel') || titleLower.contains('rosetta') ||
             titleLower.contains('conversación') || titleLower.contains('pronunciación') || titleLower.contains('traducir')) {
      return 'learn_language';
    }
    
    // 🍳 APRENDER A COCINAR
    else if (titleLower.contains('cocinar') || titleLower.contains('cooking') || titleLower.contains('recetas') ||
             titleLower.contains('chef') || titleLower.contains('cocina') || titleLower.contains('hornear') ||
             titleLower.contains('repostería') || titleLower.contains('panadería') || titleLower.contains('pastelería') ||
             titleLower.contains('sartén') || titleLower.contains('horno') || titleLower.contains('ingredientes') ||
             titleLower.contains('cortar') || titleLower.contains('mezclar') || titleLower.contains('freír') ||
             titleLower.contains('hervir') || titleLower.contains('asar') || titleLower.contains('gastronomía')) {
      return 'learn_cooking';
    }
    
    // 💪 GANAR PESO/MÚSCULO
    else if (titleLower.contains('ganar peso') || titleLower.contains('ganar músculo') || titleLower.contains('masa muscular') ||
             titleLower.contains('bulking') || titleLower.contains('hipertrofia') || titleLower.contains('fuerza') ||
             titleLower.contains('proteína') || titleLower.contains('suplementos') || titleLower.contains('creatina') ||
             titleLower.contains('gym') || titleLower.contains('pesas') || titleLower.contains('entrenar') ||
             titleLower.contains('bíceps') || titleLower.contains('pectorales') || titleLower.contains('abdominales') ||
             titleLower.contains('glúteos') || titleLower.contains('piernas') || titleLower.contains('definir')) {
      return 'gain_muscle';
    }
    
    // 🧠 ESTUDIAR/EDUCACIÓN
    else if (titleLower.contains('estudiar') || titleLower.contains('examen') || titleLower.contains('university') ||
             titleLower.contains('universidad') || titleLower.contains('colegio') || titleLower.contains('school') ||
             titleLower.contains('matemáticas') || titleLower.contains('ciencias') || titleLower.contains('historia') ||
             titleLower.contains('literatura') || titleLower.contains('química') || titleLower.contains('física') ||
             titleLower.contains('biología') || titleLower.contains('filosofía') || titleLower.contains('psicología') ||
             titleLower.contains('economía') || titleLower.contains('derecho') || titleLower.contains('medicina') ||
             titleLower.contains('ingeniería') || titleLower.contains('tesis') || titleLower.contains('investigación')) {
      return 'study_education';
    }
    
    // 🤝 VOLUNTARIADO
    else if (titleLower.contains('voluntariado') || titleLower.contains('volunteer') || titleLower.contains('ayudar') ||
             titleLower.contains('caridad') || titleLower.contains('charity') || titleLower.contains('donación') ||
             titleLower.contains('comunidad') || titleLower.contains('social') || titleLower.contains('ong') ||
             titleLower.contains('fundación') || titleLower.contains('causas') || titleLower.contains('beneficencia') ||
             titleLower.contains('solidaridad') || titleLower.contains('servicio') || titleLower.contains('misión') ||
             titleLower.contains('altruismo') || titleLower.contains('humanitario')) {
      return 'volunteering';
    }
    
    // 📝 ESCRIBIR/JOURNALING
    else if (titleLower.contains('escribir') || titleLower.contains('writing') || titleLower.contains('diario') ||
             titleLower.contains('journal') || titleLower.contains('blog') || titleLower.contains('novela') ||
             titleLower.contains('cuento') || titleLower.contains('poesía') || titleLower.contains('poema') ||
             titleLower.contains('artículo') || titleLower.contains('ensayo') || titleLower.contains('redactar') ||
             titleLower.contains('autor') || titleLower.contains('escritor') || titleLower.contains('manuscrito') ||
             titleLower.contains('guión') || titleLower.contains('screenplay') || titleLower.contains('copywriting')) {
      return 'writing';
    }
    
    // 🚶‍♂️ CAMINAR DIARIAMENTE
    else if (titleLower.contains('caminar') || titleLower.contains('walking') || titleLower.contains('pasos') ||
             titleLower.contains('steps') || titleLower.contains('senderismo') || titleLower.contains('hiking') ||
             titleLower.contains('paseo') || titleLower.contains('caminata') || titleLower.contains('trotar') ||
             titleLower.contains('jogging') || titleLower.contains('correr') || titleLower.contains('running') ||
             titleLower.contains('maratón') || titleLower.contains('kilómetros') || titleLower.contains('millas') ||
             titleLower.contains('cardio') || titleLower.contains('resistencia')) {
      return 'daily_walking';
    }
    
    // 🧘‍♀️ YOGA/ESTIRAMIENTOS
    else if (titleLower.contains('yoga') || titleLower.contains('estirar') || titleLower.contains('stretching') ||
             titleLower.contains('pilates') || titleLower.contains('flexibilidad') || titleLower.contains('postura') ||
             titleLower.contains('relajación') || titleLower.contains('namaste') || titleLower.contains('asanas') ||
             titleLower.contains('vinyasa') || titleLower.contains('hatha') || titleLower.contains('ashtanga') ||
             titleLower.contains('meditación') || titleLower.contains('chakras') || titleLower.contains('equilibrio') ||
             titleLower.contains('respiración') || titleLower.contains('mindfulness')) {
      return 'yoga_stretching';
    }
    
    // 📸 FOTOGRAFÍA
    else if (titleLower.contains('fotografía') || titleLower.contains('photography') || titleLower.contains('cámara') ||
             titleLower.contains('camera') || titleLower.contains('foto') || titleLower.contains('picture') ||
             titleLower.contains('imagen') || titleLower.contains('retrato') || titleLower.contains('paisaje') ||
             titleLower.contains('macro') || titleLower.contains('selfie') || titleLower.contains('instagram') ||
             titleLower.contains('exposición') || titleLower.contains('apertura') || titleLower.contains('iso') ||
             titleLower.contains('photoshop') || titleLower.contains('lightroom') || titleLower.contains('edición')) {
      return 'photography';
    }
    
    // 🏡 JARDINERÍA
    else if (titleLower.contains('jardín') || titleLower.contains('garden') || titleLower.contains('plantas') ||
             titleLower.contains('plant') || titleLower.contains('flores') || titleLower.contains('flower') ||
             titleLower.contains('sembrar') || titleLower.contains('plantar') || titleLower.contains('cultivar') ||
             titleLower.contains('regar') || titleLower.contains('tierra') || titleLower.contains('semillas') ||
             titleLower.contains('macetas') || titleLower.contains('huerto') || titleLower.contains('vegetables') ||
             titleLower.contains('hierbas') || titleLower.contains('herbs') || titleLower.contains('compost')) {
      return 'gardening';
    }
    
    // 💻 PROGRAMACIÓN
    else if (titleLower.contains('programar') || titleLower.contains('programming') || titleLower.contains('código') ||
             titleLower.contains('code') || titleLower.contains('python') || titleLower.contains('javascript') ||
             titleLower.contains('java') || titleLower.contains('react') || titleLower.contains('flutter') ||
             titleLower.contains('html') || titleLower.contains('css') || titleLower.contains('sql') ||
             titleLower.contains('github') || titleLower.contains('developer') || titleLower.contains('app') ||
             titleLower.contains('website') || titleLower.contains('software') || titleLower.contains('algoritmo') ||
             titleLower.contains('database') || titleLower.contains('backend') || titleLower.contains('frontend')) {
      return 'programming';
    }
    
    // �🌱 MEDIO AMBIENTE
    else if (titleLower.contains('reciclar') || titleLower.contains('medio ambiente') || titleLower.contains('ecológico') ||
             titleLower.contains('sustentable') || titleLower.contains('verde') || titleLower.contains('planeta') ||
             titleLower.contains('cambio climático') || titleLower.contains('plastic') || titleLower.contains('waste') ||
             titleLower.contains('energy') || titleLower.contains('sostenible') || titleLower.contains('natura')) {
      return 'environment';
    }
    
    else {
      // Tipo genérico para retos no específicos
      return 'generic';
    }
  }

  /// Mostrar diálogo para usar ficha de perdón
  Future<bool?> _showForgivenessDialog(BuildContext context, int tokensAvailable, int currentStreak) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.shield, color: Colors.blue[600], size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '¿Usar ficha de perdón?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu racha actual es de $currentStreak días.',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
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
                        Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Fichas de perdón disponibles:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Icon(
                            index < tokensAvailable ? Icons.shield : Icons.shield_outlined,
                            color: index < tokensAvailable ? Colors.blue[600] : Colors.grey[400],
                            size: 24,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Una ficha protege tu racha por hoy\n'
                      '• Se regeneran 1 por semana (máximo 3)\n'
                      '• Solo puedes usar 1 por día',
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
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'No usar (perder racha)',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton.icon(
              onPressed: tokensAvailable > 0
                  ? () => Navigator.of(context).pop(true)
                  : null,
              icon: const Icon(Icons.shield, size: 18),
              label: Text(tokensAvailable > 0 ? 'Usar ficha' : 'Sin fichas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LiveStreakTimer extends StatefulWidget {
  final DateTime startDate;
  final DateTime? lastConfirmedDate;
  final bool confirmedToday;
  const _LiveStreakTimer({
    Key? key,
    required this.startDate,
    required this.lastConfirmedDate,
    required this.confirmedToday,
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
    const double fontSize = 15;
    
    // SIEMPRE mostrar todo el tiempo completo disponible
    if (years > 0) {
      timeWidgets.add(_buildTimeBox(years, 'a', fontSize));
      timeWidgets.add(const SizedBox(width: 2));
    }
    if (months > 0 || years > 0) {
      timeWidgets.add(_buildTimeBox(months, 'm', fontSize - 2));
      timeWidgets.add(const SizedBox(width: 2));
    }
    
    // Siempre mostrar días (usar remDays si hay más de 30 días total, sino days normal)
    final displayDays = days >= 30 ? remDays : days;
    timeWidgets.add(_buildTimeBox(displayDays, 'd', fontSize - 4));
    timeWidgets.add(const SizedBox(width: 2));
    
    // SIEMPRE mostrar horas, minutos y segundos sin importar cuántos días/meses/años hayan pasado
    timeWidgets.add(_buildTimeBox(hours, 'h', fontSize - 2));
    timeWidgets.add(const SizedBox(width: 2));
    timeWidgets.add(_buildTimeBox(minutes, 'm', fontSize - 4));
    timeWidgets.add(const SizedBox(width: 2));
    timeWidgets.add(_buildTimeBox(seconds, 's', fontSize - 6));
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

class _IndividualStreakDisplay extends StatefulWidget {
  final String challengeId;
  final DateTime startDate;
  final DateTime? lastConfirmedDate;
  final bool confirmedToday;
  final double? fontSize;
  
  const _IndividualStreakDisplay({
    Key? key,
    required this.challengeId,
    required this.startDate,
    required this.lastConfirmedDate,
    required this.confirmedToday,
    this.fontSize,
  }) : super(key: key);

  @override
  State<_IndividualStreakDisplay> createState() => _IndividualStreakDisplayState();
}

class _IndividualStreakDisplayState extends State<_IndividualStreakDisplay> {
  late Duration _duration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateDuration();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => _updateDuration(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Muestra explicación sobre la diferencia entre racha y cronómetro
  void _showStreakExplanation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.help_outline, color: Colors.blue[600]),
              const SizedBox(width: 12),
              const Text('Racha vs Cronómetro'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.orange[600], size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Racha (días cumplidos)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Cuenta cuántos días calendario has cumplido tu reto.\n\n📅 Ejemplo: Si empezaste el 19/07 y cumpliste:\n• 19/07 ✅ (día 1)\n• 20/07 ✅ (día 2)\n• 21/07 ✅ (día 3)\n• 22/07 ✅ (día 4)\n\nResultado: 4 días cumplidos',
                style: TextStyle(height: 1.4),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.green[600], size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Cronómetro (tiempo corrido)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Muestra el tiempo exacto transcurrido desde que iniciaste.\n\n⏰ Ejemplo: Del 19/07 (8:00 AM) al 22/07 (4:50 AM):\nResultado: 3 días, 20 horas, 50 minutos\n\n(Depende de la hora exacta de inicio)',
                style: TextStyle(height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Text(
                  '💡 Ambos números son correctos, solo miden cosas diferentes. La racha te motiva día a día, el cronómetro muestra tu persistencia total.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
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

  void _updateDuration() {
    final now = DateTime.now();
    
    // CORREGIDO: El cronómetro debe contar desde que empezó ESTE reto específico
    // No desde la última confirmación (eso sería para resetear el cronómetro cada día)
    setState(() {
      _duration = now.difference(widget.startDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtener información de racha individual
    final streak = IndividualStreakService.instance.getStreak(widget.challengeId);
    final currentStreak = streak?.currentStreak ?? 0;
    final forgivenessTokens = streak?.forgivenessTokens ?? 2;
    
    final days = _duration.inDays;
    final hours = _duration.inHours.remainder(24);
    final minutes = _duration.inMinutes.remainder(60);
    final seconds = _duration.inSeconds.remainder(60);
    
    // Calcular años, meses y días remanentes para mostrar tiempo completo
    int years = 0;
    int months = 0;
    int remDays = days;
    
    if (days >= 30) {
      // Calcular meses y años aproximados igual que el otro cronómetro
      final start = widget.startDate;
      final end = DateTime.now();
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
    
    final fontSize = widget.fontSize ?? 22;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Información de racha principal con tooltip explicativo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department,
              color: currentStreak > 0 ? Colors.orange[600] : Colors.grey[400],
              size: fontSize - 2,
            ),
            const SizedBox(width: 6),
            Text(
              '$currentStreak días cumplidos',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: currentStreak > 0 ? Colors.orange[700] : Colors.grey[500],
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _showStreakExplanation(context),
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Etiqueta para el cronómetro
        Text(
          'Tiempo corrido:',
          style: TextStyle(
            fontSize: fontSize - 8,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        
        // Tiempo transcurrido completo (SIEMPRE muestra años, meses, días, horas, minutos y segundos cuando aplique)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostrar años si existen
            if (years > 0) ...[
              _buildTimeUnit(years, 'a', fontSize - 6),
              const SizedBox(width: 4),
            ],
            // Mostrar meses si existen (o si hay años)
            if (months > 0 || years > 0) ...[
              _buildTimeUnit(months, 'm', fontSize - 5),
              const SizedBox(width: 4),
            ],
            // Siempre mostrar días (usar remDays si calculamos meses/años, sino days normal)
            if (days >= 30) ...[
              _buildTimeUnit(remDays, 'd', fontSize - 4),
              const SizedBox(width: 4),
            ] else if (days > 0) ...[
              _buildTimeUnit(days, 'd', fontSize - 4),
              const SizedBox(width: 4),
            ],
            // SIEMPRE mostrar horas, minutos y segundos
            _buildTimeUnit(hours, 'h', fontSize - 4),
            const SizedBox(width: 4),
            _buildTimeUnit(minutes, 'm', fontSize - 4),
            const SizedBox(width: 4),
            _buildTimeUnit(seconds, 's', fontSize - 4),
          ],
        ),
        
        // Fichas de perdón (solo si tiene alguna)
        if (forgivenessTokens > 0) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(forgivenessTokens.clamp(0, 3), (index) {
                return Container(
                  margin: const EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.shield,
                    color: Colors.blue[400],
                    size: 14,
                  ),
                );
              }),
              if (forgivenessTokens > 0)
                Text(
                  ' $forgivenessTokens',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTimeUnit(int value, String label, double fontSize) {
    return RichText(
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
            text: label,
            style: TextStyle(
              fontSize: fontSize - 3,
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
