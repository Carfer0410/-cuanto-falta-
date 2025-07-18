import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'add_counter_page.dart';

class Counter {
  final String title;
  final DateTime startDate;
  DateTime? lastConfirmedDate;

  Counter({
    required this.title,
    required this.startDate,
    this.lastConfirmedDate,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'startDate': startDate.toIso8601String(),
    'lastConfirmedDate': lastConfirmedDate?.toIso8601String(),
  };

  static Counter fromJson(Map<String, dynamic> json) => Counter(
    title: json['title'],
    startDate: DateTime.parse(json['startDate']),
    lastConfirmedDate:
        json['lastConfirmedDate'] != null
            ? DateTime.parse(json['lastConfirmedDate'])
            : null,
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
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Contadores'),
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
                builder:
                    (context) => AlertDialog(
                      title: const Text('Consejo para tu reto'),
                      content: const Text(
                        'Te recomendamos elegir una hora fija cada día (por ejemplo, en la noche antes de dormir) para abrir la app y confirmar si cumpliste tu reto. Así tendrás un hábito claro y evitarás confusiones.',
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
          onRefresh: _loadCounters,
          child:
              _counters.isEmpty
                  ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 150),
                      Center(
                        child: Text(
                          'No hay contadores. ¡Agrega uno!',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  )
                  : ListView.builder(
                    itemCount: _counters.length,
                    itemBuilder: (context, index) {
                      final counter = _counters[index];
                      final now = DateTime.now();
                      final streakStart =
                          counter.lastConfirmedDate ?? counter.startDate;
                      return Dismissible(
                        key: ValueKey(
                          '${counter.startDate.toIso8601String()}_${counter.title}',
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteCounter(index),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                            color: const Color(0xFFFFF3E0),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    color: Colors.orange,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '¡Llevas',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _LiveStreakTimer(from: streakStart),
                                  const SizedBox(height: 4),
                                  Text(
                                    'sin ${counter.title.toLowerCase()}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '¡Sigue así! Cada segundo cuenta.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  if (counter.lastConfirmedDate == null ||
                                      !_isSameDay(
                                        counter.lastConfirmedDate!,
                                        now,
                                      ))
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          counter.lastConfirmedDate = DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                          );
                                        });
                                        _saveCounters();
                                      },
                                      child: const Text('¿Cumpliste hoy?'),
                                    ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                    onPressed: () => _deleteCounter(index),
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'countersFab',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: _navigateToAddCounter,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _LiveStreakTimer extends StatefulWidget {
  final DateTime from;
  const _LiveStreakTimer({Key? key, required this.from}) : super(key: key);
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
      _duration = DateTime.now().difference(widget.from);
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
      '$days días  $hours h  $minutes m  $seconds s',
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
      textAlign: TextAlign.center,
    );
  }
}
