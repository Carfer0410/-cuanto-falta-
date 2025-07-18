import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'event.dart';
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

  final Map<String, String> _categoryMessages = {
    'Navidad':
        '🎄 Ve preparando los regalos y el arbolito. ¡La magia está cerca!',
    'Año Nuevo': '🎉 ¡Ya casi comienza el año! Haz tu lista de propósitos.',
    'Cumpleaños': '🎂 ¡No se te olvide el pastel y la sorpresa!',
    'Vacaciones': '🧳 ¡A empacar maletas desde ya! El descanso se acerca.',
    'Examen': '📚 ¡Estudia y confía en ti, vas a lograrlo!',
    'Viaje': '✈️ ¡Prepara tu itinerario y disfruta la aventura!',
    'Boda': '💍 ¡El gran día se acerca, que viva el amor!',
    'Graduación': '🎓 ¡Un logro más cerca, sigue así!',
    'Concierto': '🎵 ¡Pronto a cantar y disfrutar tu música favorita!',
    'Reunión': '🤝 ¡Ya casi es hora de ver a todos!',
    'Entrega de proyecto': '📝 ¡Últimos detalles, tú puedes!',
    'Mudanza': '🏡 ¡Un nuevo hogar te espera!',
    'Entrevista': '💼 ¡Confía en ti, el éxito está cerca!',
    'Día de la Madre': '🌷 ¡Prepara un detalle especial para mamá!',
    'Día del Padre': '👔 ¡Haz sentir especial a papá!',
    'San Valentín': '💌 ¡El amor está en el aire!',
    'Black Friday': '🛍️ ¡Prepara tu lista de compras!',
    'Vacuna': '💉 ¡Cuida tu salud, ya casi es el día!',
    'Otro': '⏳ Cada día estás más cerca de tu meta.',
  };

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
      final event = Event(
        title: _titleController.text,
        targetDate: _selectedDate!,
        message:
            _categoryMessages[_selectedCategory!] ??
            '⏳ Cada día estás más cerca.',
      );
      await DatabaseHelper.instance.insertEvent(event);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Añadir Evento'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Nombre del evento',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Ingrese un nombre'
                            : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    _categoryMessages.keys
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator:
                    (value) =>
                        value == null ? 'Seleccione una categoría' : null,
              ),
              const SizedBox(height: 16),
              if (_selectedCategory != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _categoryMessages[_selectedCategory!] ?? '',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'Seleccione una fecha'
                          : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Elegir fecha'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _saveEvent,
                child: const Text('Guardar', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
