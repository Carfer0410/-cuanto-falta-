import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'add_counter_page.dart';

class Counter {
  final String title;
  final DateTime startDate;
  DateTime? lastConfirmedDate;
  final bool isNegativeHabit;
  DateTime? challengeStartedAt; // Nuevo campo

  Counter({
    required this.title,
    required this.startDate,
    this.lastConfirmedDate,
    this.isNegativeHabit = false,
    this.challengeStartedAt,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'startDate': startDate.toIso8601String(),
    'lastConfirmedDate': lastConfirmedDate?.toIso8601String(),
    'isNegativeHabit': isNegativeHabit,
    'challengeStartedAt': challengeStartedAt?.toIso8601String(),
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

  String _challengePhrase(Counter counter) {
    final basePhrase = counter.title.toLowerCase();
    if (counter.isNegativeHabit) {
      if (basePhrase.startsWith('dejar de ')) {
        return 'sin ${basePhrase.replaceFirst('dejar de ', '')}';
      } else {
        return 'sin $basePhrase';
      }
    } else {
      if (basePhrase.startsWith('empezar a ')) {
        return 'haciendo ${basePhrase.replaceFirst('empezar a ', '')}';
      } else {
        return 'haciendo $basePhrase';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                          'No hay retos. ¡Agrega uno!',
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
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 8,
                          color: const Color(0xFFFFF3E0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  color: Colors.orange,
                                  size: 56,
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '¡Llevas',
                                        style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Center(
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            maxWidth: 340,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.orangeAccent,
                                              width: 1.2,
                                            ),
                                          ),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (counter.challengeStartedAt != null)
                                                  _LiveStreakTimer(
                                                    startDate: counter.challengeStartedAt!,
                                                    lastConfirmedDate: counter.lastConfirmedDate,
                                                    confirmedToday: confirmedToday,
                                                    fontSize: 20,
                                                  )
                                                else
                                                  Text(
                                                    '0d 0h 0m 0s',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.green[800],
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _challengePhrase(counter),
                                        style: TextStyle(
                                          fontSize: 26,
                                          color: Colors.orange[900],
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '¡Sigue así! Cada segundo cuenta.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      if (counter.challengeStartedAt == null)
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 18,
                                                  ),
                                              textStyle: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
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
                                            child: const Text('Iniciar reto'),
                                          ),
                                        )
                                      else if (!_isSameDay(
                                        counter.lastConfirmedDate!,
                                        now,
                                      ))
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 18,
                                                  ),
                                              textStyle: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                counter.lastConfirmedDate =
                                                    DateTime(
                                                      now.year,
                                                      now.month,
                                                      now.day,
                                                    );
                                              });
                                              _saveCounters();
                                            },
                                            child: const Text(
                                              '¿Cumpliste hoy?',
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text('Eliminar reto'),
                                            content: const Text(
                                              '¿Seguro que deseas eliminar este reto? Esta acción no se puede deshacer.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.of(
                                                      context,
                                                    ).pop(false),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.of(
                                                      context,
                                                    ).pop(true),
                                                child: const Text(
                                                  'Eliminar',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
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
                              ],
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
  // ... otras funciones auxiliares si las hubiera.
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
