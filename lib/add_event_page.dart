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

  List<String> _validateFields() {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    List<String> missingFields = [];

    // Validar título
    if (_titleController.text.trim().isEmpty) {
      missingFields.add('• ${localizationService.t('eventTitle')}');
    }

    // Validar fecha
    if (_selectedDate == null) {
      missingFields.add('• ${localizationService.t('targetDate')}');
    }

    // Validar categoría
    if (_selectedCategory == null) {
      missingFields.add('• ${localizationService.t('eventCategory')}');
    }

    return missingFields;
  }

  void _showValidationDialog(List<String> missingFields) {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: context.cardColor,
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  localizationService.t('requiredFields'),
                  style: TextStyle(
                    color: context.primaryTextColor,
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
              Text(
                localizationService.t('completeFieldsMessage'),
                style: TextStyle(
                  color: context.secondaryTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.isDark 
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: missingFields.map((field) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      field,
                      style: TextStyle(
                        color: context.primaryTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: context.orangeVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                localizationService.t('understood'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveEvent() async {
    // Primero validar campos requeridos
    final missingFields = _validateFields();
    
    if (missingFields.isNotEmpty) {
      _showValidationDialog(missingFields);
      return;
    }

    // Validar formulario (validaciones adicionales como longitud de texto, etc.)
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
            backgroundColor: context.successColor,
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
                        Icon(Icons.event, color: context.orangeVariant, size: 54),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: localizationService.t('eventTitle'),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: context.orangeVariant,
                              fontSize: 18,
                            ),
                            filled: true,
                            fillColor: context.cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: context.orangeVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: context.isDark 
                                  ? context.orangeVariant.withOpacity(0.5)
                                  : context.orangeVariant.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: context.orangeVariant,
                                width: 2,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 20,
                            color: context.primaryTextColor,
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
                              color: context.orangeVariant,
                              fontSize: 18,
                            ),
                            filled: true,
                            fillColor: context.cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: context.orangeVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: context.isDark 
                                  ? context.orangeVariant.withOpacity(0.5)
                                  : context.orangeVariant.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: context.orangeVariant,
                                width: 2,
                              ),
                            ),
                          ),
                          dropdownColor: context.cardColor,
                          style: TextStyle(
                            fontSize: 16,
                            color: context.primaryTextColor,
                          ),
                          items: localizationService.getCategories()
                                  .map(
                                    (categoryEntry) => DropdownMenuItem(
                                      value: categoryEntry.key, // Usar el ID como value
                                      child: Text(
                                        categoryEntry.value,
                                        style: TextStyle(color: context.primaryTextColor),
                                      ), // Mostrar el nombre traducido
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
                                  color: context.orangeVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _pickDate,
                              icon: Icon(
                                Icons.calendar_today,
                                color: context.orangeVariant,
                                size: 18,
                              ),
                              label: Text(
                                localizationService.t('selectDate'),
                                style: TextStyle(
                                  color: context.orangeVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: context.orangeVariant,
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
                              backgroundColor: context.orangeVariant,
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
