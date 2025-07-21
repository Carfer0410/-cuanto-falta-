import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'counters_page.dart';
import 'localization_service.dart';
import 'statistics_service.dart';
import 'achievement_service.dart';
import 'individual_streak_service.dart';
import 'event.dart';
import 'challenge_customization_widget.dart';

class AddCounterPage extends StatefulWidget {
  const AddCounterPage({Key? key}) : super(key: key);

  @override
  State<AddCounterPage> createState() => _AddCounterPageState();
}

class _AddCounterPageState extends State<AddCounterPage> {
  static const List<String> _bannedWords = ['mierda', 'puta', 'idiota'];
  static final DateTime _minDate = DateTime.now().subtract(Duration(days: 3650)); // hace 10 años
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'dejar de'; // Default value
  late LocalizationService localizationService;
  EventColor _selectedColor = EventColor.orange;
  EventIcon _selectedIcon = EventIcon.star;

  List<String> get _types => [
    localizationService.t('stopHabit'),
    localizationService.t('startHabit'),
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Elimina prefijos duplicados y caracteres innecesarios, y normaliza el título.
  String _sanitizeTitle(String input) {
    var title = input.trim().toLowerCase();
    // Eliminar todos los caracteres de puntuación
    title = title.replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), '').trim();
    // Prefijos comunes a eliminar, incluyendo sinónimos
    const prefixes = ['dejar de ', 'parar de ', 'comenzar a ', 'empezar a ', 'cesar ', 'detener ', 'iniciar ', 'abandonar ', 'suprimir '];
    bool removed;
    do {
      removed = false;
      for (var p in prefixes) {
        if (title.startsWith(p)) {
          title = title.substring(p.length).trim();
          removed = true;
        }
      }
    } while (removed);
    return title;
  }

  /// Sistema inteligente de rachas para retos registrados con fecha atrasada
  Future<void> _handleBackdatedChallenge(String challengeTitle, DateTime startDate) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final daysPassed = today.difference(start).inDays;
    
    // Solo activar si el reto empezó al menos 1 día antes
    if (daysPassed < 1) return;
    
    if (!mounted) return;
    
    // Generar ID único para el reto
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('counters');
    final list = jsonString != null ? jsonDecode(jsonString) : [];
    final challengeId = 'challenge_${list.length - 1}'; // Último elemento agregado
    
    // Mostrar diálogo de cortesía para retos atrasados
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.help_outline, color: Colors.orange[600], size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '🎯 Reto Atrasado',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Registraste un reto que empezó hace $daysPassed ${daysPassed == 1 ? 'día' : 'días'}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Realmente cumpliste tu reto todos esos días anteriores?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Esto afectará tu racha de constancia. Solo di "Sí" si realmente lo cumpliste.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('no'),
              child: Text(
                'No, empiezo hoy',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('partial'),
              child: const Text(
                'Solo algunos días',
                style: TextStyle(color: Colors.orange),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop('yes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Sí, todos los días'),
            ),
          ],
        );
      },
    );
    
    if (!mounted) return;
    
    // Procesar respuesta del usuario
    switch (result) {
      case 'yes':
        // Usuario confirma que cumplió todos los días
        await _grantBackdatedStreak(challengeId, challengeTitle, startDate, daysPassed);
        break;
      case 'partial':
        // Usuario cumplió solo algunos días - mostrar selector
        await _showPartialStreakDialog(challengeId, challengeTitle, startDate, daysPassed);
        break;
      case 'no':
      default:
        // Usuario no cumplió - empezar racha desde 0 (comportamiento normal)
        await IndividualStreakService.instance.registerChallenge(challengeId, challengeTitle);
        break;
    }
  }

  /// Otorga racha completa para retos cumplidos retroactivamente
  Future<void> _grantBackdatedStreak(String challengeId, String challengeTitle, DateTime startDate, int daysPassed) async {
    await IndividualStreakService.instance.registerChallenge(challengeId, challengeTitle);
    
    // Usar método público para registrar múltiples confirmaciones
    for (int i = 0; i < daysPassed; i++) {
      // Simular confirmación para cada día (construye la racha gradualmente)
      await IndividualStreakService.instance.confirmChallenge(challengeId, challengeTitle);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.military_tech, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '🎉 ¡Racha de $daysPassed días otorgada! Excelente constancia.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// Permite al usuario seleccionar cuántos días realmente cumplió
  Future<void> _showPartialStreakDialog(String challengeId, String challengeTitle, DateTime startDate, int totalDays) async {
    int selectedDays = 0;
    
    final result = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('🎯 Días Cumplidos'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '¿Cuántos de los $totalDays días realmente cumpliste tu reto?',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: selectedDays > 0 ? () => setState(() => selectedDays--) : null,
                        icon: const Icon(Icons.remove_circle),
                        color: Colors.orange,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$selectedDays días',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: selectedDays < totalDays ? () => setState(() => selectedDays++) : null,
                        icon: const Icon(Icons.add_circle),
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(0),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(selectedDays),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
    
    if (result != null && result > 0) {
      await _grantBackdatedStreak(challengeId, challengeTitle, startDate, result);
    } else {
      // Si cancela o selecciona 0, empezar desde 0
      await IndividualStreakService.instance.registerChallenge(challengeId, challengeTitle);
    }
  }

  Future<void> _saveCounter() async {
    if (_formKey.currentState?.validate() != true) return;
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('counters');
    List<dynamic> list = [];
    if (jsonString != null) {
      list = jsonDecode(jsonString);
    }
    final text = _titleController.text;
    final sanitized = _sanitizeTitle(text);
    // Validar fecha
    if (_selectedDate.isAfter(DateTime.now()) || _selectedDate.isBefore(_minDate)) {
      if (!mounted) return;
      showDialog(context: context, builder: (_) => AlertDialog(
        title: Text(localizationService.t('invalidDate')),
        content: Text(localizationService.t('invalidDateMessage')),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(localizationService.t('ok')))],
      ));
      return;
    }
    // Validar duplicados
    if (list.any((e) => (e['title'] as String) == sanitized)) {
      if (!mounted) return;
      showDialog(context: context, builder: (_) => AlertDialog(
        title: Text(localizationService.t('duplicateChallenge')),
        content: Text(localizationService.t('duplicateChallengeMessage')),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(localizationService.t('ok')))],
      ));
      return;
    }
    final newCounter = Counter(
      title: sanitized,
      startDate: _selectedDate,
      isNegativeHabit: _selectedType == localizationService.t('stopHabit'), // Marca hábito negativo según tipo
      challengeStartedAt: _selectedDate, // CORREGIDO: Usar la fecha que eligió el usuario, no cuando se registra en la app
      color: _selectedColor,
      icon: _selectedIcon,
    );
    list.add(newCounter.toJson());
    await prefs.setString('counters', jsonEncode(list));
    
    // NUEVO: Sistema inteligente de rachas para retos atrasados
    await _handleBackdatedChallenge(sanitized, _selectedDate);
    
    // Registrar estadísticas y verificar logros
    await StatisticsService.instance.recordChallengeConfirmation();
    await AchievementService.instance.checkAndUnlockAchievements(
      StatisticsService.instance.statistics
    );
    
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    localizationService = Provider.of<LocalizationService>(context);
    
    // Asegurar que _selectedType tenga un valor válido en el idioma actual
    if (_selectedType == 'dejar de' || _selectedType == 'stop' || _selectedType == 'parar de' || 
        _selectedType == 'arrêter de' || _selectedType == 'aufhören' || _selectedType == 'smettere di' ||
        _selectedType == 'やめる' || _selectedType == '그만두기' || _selectedType == '停止' ||
        _selectedType == 'التوقف عن' || _selectedType == 'перестать' || _selectedType == 'बंद करना') {
      _selectedType = localizationService.t('stopHabit');
    } else {
      _selectedType = localizationService.t('startHabit');
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(localizationService.t('newChallenge')),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? (isDark ? Colors.black : Colors.orange),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: localizationService.t('titleTip'),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text(localizationService.t('titleTip')),
                      content: Text(localizationService.t('titleTipContent')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(localizationService.t('ok')),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                shape: isDark
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: const BorderSide(color: Colors.orange, width: 2),
                      )
                    : RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                elevation: 12,
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 36,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.orange,
                          size: 54,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: localizationService.t('challengePrompt'),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              fontSize: 18,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(18),
                              ),
                              borderSide: const BorderSide(color: Colors.orange),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(18),
                              ),
                              borderSide: BorderSide(
                                color: Colors.orange.shade100,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(18),
                              ),
                              borderSide: const BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                            helperText: localizationService.t('challengeExample'),
                            helperStyle: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return localizationService.t('enterChallenge');
                            }
                            final sanitized = _sanitizeTitle(value);
                            if (sanitized.isEmpty) {
                              return localizationService.t('invalidTitleAfterClean');
                            }
                            if (sanitized.length < 3) {
                              return localizationService.t('titleTooShort');
                            }
                            final words = sanitized.split(RegExp(r'\s+'));
                            if (words.length > 2) {
                              return localizationService.t('maxTwoWords');
                            }
                            if (sanitized.length > 20) {
                              return localizationService.t('titleTooLong');
                            }
                            if (RegExp(r'^[0-9]+$').hasMatch(sanitized)) {
                              return localizationService.t('titleOnlyNumbers');
                            }
                            if (words.any((w) => _bannedWords.contains(w))) {
                              return localizationService.t('bannedWord');
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          autofocus: true,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: InputDecoration(
                            labelText: localizationService.t('challengeType'),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              fontSize: 18,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: Colors.orange),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: Colors.orange.shade100,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                          ),
                          items:
                              _types
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${localizationService.t('startDate')}:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[900],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.orange,
                              ),
                              label: Text(
                                '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                  fontSize: 16,
                                ),
                              ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.orange,
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Widget de personalización visual para retos
                        ChallengeCustomizationWidget(
                          selectedColor: _selectedColor,
                          selectedIcon: _selectedIcon,
                          isNegativeHabit: _selectedType == localizationService.t('stopHabit'),
                          onColorChanged: (color) {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          onIconChanged: (icon) {
                            setState(() {
                              _selectedIcon = icon;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 36),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saveCounter,
                            icon: const Icon(Icons.save, size: 26),
                            label: Text(
                              localizationService.t('saveChallenge'),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
