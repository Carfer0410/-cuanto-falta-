import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'database_helper.dart';
import 'event.dart';
import 'add_event_page.dart';

/// Genera un mensaje alusivo automático según el evento y los días restantes.

String generarMensajeAlusivo(String titulo, int dias) {
  final lower = titulo.toLowerCase();
  if (lower.contains('navidad')) {
    return '🎄 Ve preparando los regalos';
  } else if (lower.contains('año nuevo')) {
    // Mostrar conteo dinámico si falta mucho, o mensaje de cercanía si estamos en el último mes
    if (dias > 30) {
      return '🎉 Faltan $dias días para el próximo año';
    } else {
      return '🎉 ¡Ya casi comienza el año!';
    }
  } else if (lower.contains('cumple')) {
    return '🎂 ¡No se te olvide el pastel!';
  } else if (lower.contains('vacaciones')) {
    return '🧳 ¡A empacar maletas desde ya!';
  } else if (dias == 0) {
    return '🚨 ¡Hoy es el gran día!';
  } else if (dias <= 3) {
    return '⏰ ¡Ya casi llega!';
  } else {
    return '⏳ Cada día estás más cerca.';
  }
}

/// Widget de cuenta regresiva en vivo mostrando días, horas, minutos y segundos.
class _CountdownTimer extends StatefulWidget {
  final DateTime targetDate;
  const _CountdownTimer({Key? key, required this.targetDate}) : super(key: key);

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
    return Text(
      "Falta ${days}d ${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s",
      style: const TextStyle(
        fontSize: 24,
        color: Colors.orange,
        fontWeight: FontWeight.bold,
      ),
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

  void _navigateToAddEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEventPage()),
    );
    if (result == true) {
      _loadEvents();
    }
  }

  int _diasRestantes(DateTime targetDate) {
    final now = DateTime.now();
    return targetDate.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SettingsPage(
              themeMode: widget.themeMode,
              onThemeChanged: widget.onThemeChanged,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Eventos'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Container(
        decoration:
            isDark
                ? BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                )
                : const BoxDecoration(
                  // Degradado sutil de blanco a naranja pastel para mejor legibilidad
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: RefreshIndicator(
            onRefresh: _loadEvents,
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
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
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
                            await DatabaseHelper.instance.deleteEvent(
                              deleted.id!,
                            );
                            _loadEvents();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Evento eliminado'),
                                action: SnackBarAction(
                                  label: 'Deshacer',
                                  onPressed: () async {
                                    await DatabaseHelper.instance.insertEvent(
                                      deleted,
                                    );
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 6,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 18,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.event,
                                          color: Colors.orange,
                                          size: 32,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            event.title,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            await DatabaseHelper.instance
                                                .deleteEvent(event.id!);
                                            _loadEvents();
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'El evento es el día ${DateFormat('dd/MM/yyyy').format(event.targetDate)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.timer,
                                          color: Colors.orange,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _CountdownTimer(
                                            targetDate: event.targetDate,
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
                                          child: Text(
                                            generarMensajeAlusivo(
                                              event.title,
                                              _diasRestantes(event.targetDate),
                                            ),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700],
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
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: _navigateToAddEvent,
      ),
    );
  }
}
