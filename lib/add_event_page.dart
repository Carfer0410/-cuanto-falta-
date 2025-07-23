import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database_helper.dart';
import 'event.dart';
import 'localization_service.dart';
import 'statistics_service.dart';
import 'achievement_service.dart';
import 'preparation_service.dart';
import 'event_customization_widget.dart';
import 'theme_service.dart';
// import 'package:intl/intl.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({Key? key}) : super(key: key);

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;
  EventColor _selectedColor = EventColor.orange;
  EventIcon _selectedIcon = EventIcon.celebration;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedCategory != null) {
      final localizationService = Provider.of<LocalizationService>(context, listen: false);
      String mensaje;
      
      // Obtener mensaje traducido usando el ID de categoría (que ahora es _selectedCategory)
      mensaje = localizationService.getCategoryMessage(_selectedCategory!);
      
      final event = Event(
        title: _titleController.text,
        targetDate: _selectedDate!,
        message: mensaje,
        category: _selectedCategory!, // Guardar el ID único
        color: _selectedColor,
        icon: _selectedIcon,
      );
      
      // Guardar evento en la base de datos
      final eventId = await DatabaseHelper.instance.insertEvent(event);
      
      // 🆕 NUEVO: Crear preparativos automáticos para el evento
      if (eventId > 0) {
        await PreparationService.instance.createAutomaticPreparations(eventId, _selectedCategory!);
      }
      
      // Registrar estadísticas y verificar logros
      await StatisticsService.instance.recordEventActivity();
      await AchievementService.instance.checkAndUnlockAchievements(
        StatisticsService.instance.statistics
      );
      
      // Mensaje informativo sobre notificaciones Y preparativos
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Evento guardado exitosamente.\n'
              '� Lista de preparativos creada automáticamente.\n'
              '�🔔 Recibirás recordatorios:\n'
              '📅 30 días, 15 días, 7 días, 3 días, 1 día antes y el día del evento.\n'
              '💡 Sistema inteligente activo.',
            ),
            duration: Duration(seconds: 6),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(localizationService.t('newEvent')),
            centerTitle: true,
            backgroundColor: context.orangeVariant,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                shape: context.isDark
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: BorderSide(color: context.orangeVariant, width: 2),
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
                        const Icon(Icons.event, color: Colors.orange, size: 54),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: localizationService.t('eventTitle'),
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
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? localizationService.t('addEventTitleError')
                                      : null,
                          textInputAction: TextInputAction.done,
                          autofocus: true,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: localizationService.t('eventCategory'),
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
                          items: localizationService.getCategories()
                                  .map(
                                    (categoryEntry) => DropdownMenuItem(
                                      value: categoryEntry.key, // Usar el ID como value
                                      child: Text(categoryEntry.value), // Mostrar el nombre traducido
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          validator:
                              (value) =>
                                  value == null
                                      ? localizationService.t('addEventCategoryError')
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        if (_selectedCategory != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              _selectedCategory != null
                                ? localizationService.getCategoryMessage(_selectedCategory!)
                                : '',
                              style: TextStyle(
                                fontSize: 16,
                                color: context.successColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedDate == null
                                    ? localizationService.t('selectDate')
                                    : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(
                                Icons.calendar_today,
                                color: Colors.orange,
                                size: 18,
                              ),
                              label: Text(
                                localizationService.t('selectDate'),
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
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
                        
                        // Widget de personalización visual
                        EventCustomizationWidget(
                          selectedColor: _selectedColor,
                          selectedIcon: _selectedIcon,
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
                            onPressed: _saveEvent,
                            icon: const Icon(Icons.save, size: 26),
                            label: Text(
                              localizationService.t('saveEvent'),
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
      },
    );
  }
}
