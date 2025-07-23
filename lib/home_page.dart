import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:async';
import 'database_helper.dart';
import 'event.dart';
import 'add_event_page.dart';
import 'localization_service.dart';
import 'data_migration_service.dart';
import 'optimal_usage_guide.dart';
import 'event_customization_widget.dart';
import 'event_preparations_page.dart';
import 'preparation_service.dart';

/// Widget de cuenta regresiva en vivo mostrando días, horas, minutos y segundos.
class _CountdownTimer extends StatefulWidget {
  final DateTime targetDate;
  final EventColor eventColor;
  const _CountdownTimer({
    Key? key, 
    required this.targetDate,
    required this.eventColor,
  }) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  // Inicializar _duration para evitar valor no asignado
  Duration _duration = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Inicializa la duración antes de la primera build
    final now = DateTime.now();
    _duration = widget.targetDate.difference(now);
    if (_duration.isNegative) {
      _duration = Duration.zero;
    }
    // Actualiza cada segundo
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateDuration(),
    );
  }

  void _updateDuration() {
    final now = DateTime.now();
    setState(() {
      _duration = widget.targetDate.difference(now);
      if (_duration.isNegative) {
        _duration = Duration.zero;
        _timer?.cancel();
      }
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
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Text(
          localizationService.timeRemaining(days, hours, minutes, seconds),
          style: TextStyle(
            fontSize: 24,
            color: widget.eventColor.color,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}

/// Pantalla principal HomePage
/// Al iniciar, carga los eventos desde la base de datos.
/// Muestra cada evento en una Card con:
/// - Nombre del evento (title)
/// - Días restantes (calculados desde hoy hasta targetDate)
/// - Mensaje alusivo (message)
/// Agrega botón flotante para ir a AddEventPage.
/// Usa diseño limpio con ListView, Padding, Cards y colores suaves.

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.themeMode,
    required this.onThemeChanged,
  }) : super(key: key);
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await DatabaseHelper.instance.getEvents();
    // Ordenar eventos: los más cercanos primero
    events.sort((a, b) => a.targetDate.compareTo(b.targetDate));
    setState(() {
      _events = events;
    });
  }

  // Función específica para pull-to-refresh que incluye sincronización
  Future<void> _onRefresh() async {
    print('🔄 HomePage: Pull-to-refresh iniciado');
    try {
      // Sincronizar estadísticas de eventos con datos reales
      await DataMigrationService.forceSyncAllData();
      
      // Cargar eventos
      await _loadEvents();
      
      print('✅ HomePage: Pull-to-refresh completado exitosamente');
      
      // Mostrar mensaje discreto de actualización exitosa
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.refresh, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Eventos sincronizados'),
              ],
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ HomePage: Error en pull-to-refresh: $e');
      // En caso de error, solo cargar eventos normalmente
      await _loadEvents();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text('Eventos cargados (sync falló: $e)'),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _navigateToAddEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEventPage()),
    );
    if (result == true) {
      _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(localizationService.t('events')),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? (isDark ? Colors.black : Colors.orange),
            foregroundColor: Theme.of(context).appBarTheme.foregroundColor ?? (isDark ? Colors.white : Colors.white),
            elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: localizationService.t('optimal_usage'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OptimalUsageGuide()),
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
                    'En esta pantalla puedes ver todos tus eventos importantes con su cuenta regresiva personalizada.\n\n'
                    '- Agrega un evento con el botón naranja (+) abajo a la derecha.\n'
                    '- Desliza un evento hacia la izquierda para eliminarlo.\n'
                    '- Toca el ícono de ajustes en la pantalla de configuración para cambiar el tema de la app.\n\n'
                    'Cada tarjeta muestra el nombre, mensaje motivacional, fecha objetivo y un temporizador en tiempo real. ¡Organiza y visualiza tus próximos eventos de forma moderna y sencilla!'
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
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child:
                _events.isEmpty
                    ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 150),
                        Center(
                          child: Text(
                            'Aún no hay eventos. ¡Agrega uno!',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                    : ListView.builder(
                        itemCount: _events.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _events.length) {
                            // Espacio extra al final para el FAB (más alto para asegurar separación)
                            return const SizedBox(height: 80);
                          }
                          final event = _events[index];
                          return Dismissible(
                            key: ValueKey(event.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) async {
                              final deleted = event;
                              // Eliminar preparativos del evento también
                              await PreparationService.instance.deleteEventPreparations(deleted.id!);
                              await DatabaseHelper.instance.deleteEvent(
                                deleted.id!,
                              );
                              _loadEvents();
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Evento y preparativos eliminados'),
                                  action: SnackBarAction(
                                    label: 'Deshacer',
                                    onPressed: () async {
                                      final newEventId = await DatabaseHelper.instance.insertEvent(
                                        deleted,
                                      );
                                      // Recrear preparativos automáticos
                                      if (newEventId > 0) {
                                        await PreparationService.instance.createAutomaticPreparations(
                                          newEventId, 
                                          deleted.category,
                                        );
                                      }
                                      _loadEvents();
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Card(
                                shape:
                                    isDark
                                        ? RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            side: const BorderSide(
                                              color: Colors.orange,
                                              width: 2,
                                            ),
                                          )
                                        : RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                elevation: 6,
                                color: Theme.of(context).cardColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          EventStyleIndicator(
                                            color: event.color,
                                            icon: event.icon,
                                            size: 32,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              event.title,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).textTheme.titleLarge?.color,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  localizationService.getCategoryMessage(event.category),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${localizationService.t('targetDate')}: '
                                                  '${localizationService.formatDate(event.targetDate)}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context).hintColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      _CountdownTimer(
                                        targetDate: event.targetDate,
                                        eventColor: event.color,
                                      ),
                                      const SizedBox(height: 12),
                                      // 🆕 NUEVO: Progress de preparativos
                                      _buildPreparationProgress(event),
                                      const SizedBox(height: 12),
                                      // Botón de preparativos mejorado
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => EventPreparationsPage(
                                                      event: event,
                                                    ),
                                                  ),
                                                ).then((_) => _loadEvents()); // Refrescar al volver
                                              },
                                              icon: Icon(Icons.checklist, size: 18),
                                              label: Text('Ver Preparativos'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: event.color.color,
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                textStyle: TextStyle(fontSize: 13),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'homeFab',
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: _navigateToAddEvent,
      ),
    );
      },
    );
  }

  /// 🆕 NUEVO: Construye el widget de progreso de preparativos
  Widget _buildPreparationProgress(Event event) {
    return FutureBuilder<Map<String, int>>(
      future: PreparationService.instance.getEventPreparationStats(event.id!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink(); // No mostrar nada mientras carga
        }
        
        final stats = snapshot.data!;
        final total = stats['total'] ?? 0;
        final active = stats['active'] ?? 0; // Solo los que deberían estar activos
        final completed = stats['completed'] ?? 0; // Solo activos completados
        final future = stats['future'] ?? 0; // Preparativos futuros
        
        // Si no hay preparativos, mostrar mensaje sugerente
        if (total == 0) {
          return Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '📋 Toca "Ver Preparativos" para crear tu lista automática',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        // Si no hay preparativos activos todavía (faltan muchos días)
        if (active == 0 && future > 0) {
          return Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: Colors.grey, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⏳ ${total} preparativos creados - Se activarán cuando sea el momento',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        // Calcular progreso solo basado en preparativos activos
        final progress = active > 0 ? completed / active : 0.0;
        
        // Determinar color del progreso según el porcentaje
        Color progressColor;
        IconData statusIcon;
        String statusText;
        
        if (progress >= 0.8) {
          progressColor = Colors.green;
          statusIcon = Icons.check_circle;
          statusText = '¡Bien preparado!';
        } else if (progress >= 0.5) {
          progressColor = Colors.orange;
          statusIcon = Icons.schedule;
          statusText = 'En progreso';
        } else if (progress >= 0.2) {
          progressColor = Colors.amber;
          statusIcon = Icons.warning;
          statusText = 'Necesita atención';
        } else {
          progressColor = Colors.red;
          statusIcon = Icons.priority_high;
          statusText = 'Urgente';
        }
        
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: progressColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: progressColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Header con ícono y estado
              Row(
                children: [
                  Icon(
                    statusIcon,
                    color: progressColor,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '$completed/$active completados',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Barra de progreso
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Theme.of(context).dividerColor.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 6,
                ),
              ),
              SizedBox(height: 6),
              // Detalles adicionales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    future > 0 ? '📋 $active activos, $future pendientes' : '📋 Preparativos activos',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}% completado',
                    style: TextStyle(
                      fontSize: 11,
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
