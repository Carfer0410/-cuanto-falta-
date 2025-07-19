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
      // Si hay categoría seleccionada, usa el mensaje de la categoría; si no, usa la función generarMensajeAlusivo
      String mensaje;
      if (_categoryMessages.containsKey(_selectedCategory!)) {
        mensaje = _categoryMessages[_selectedCategory!]!;
      } else {
        // Fallback: usa la función de home_page.dart si existe, si no, usa el mensaje por defecto
        mensaje = '⏳ Cada día estás más cerca.';
      }
      final event = Event(
        title: _titleController.text,
        targetDate: _selectedDate!,
        message: mensaje,
      );
      await DatabaseHelper.instance.insertEvent(event);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Nuevo evento'),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? (isDark ? Colors.black : Colors.orange),
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
        elevation: 2,
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
                        const Icon(Icons.event, color: Colors.orange, size: 54),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Nombre del evento',
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
                                      ? 'Ingrese un nombre'
                                      : null,
                          textInputAction: TextInputAction.done,
                          autofocus: true,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Categoría',
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
                              _categoryMessages.keys
                                  .map(
                                    (cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Text(cat),
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
                                      ? 'Seleccione una categoría'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        if (_selectedCategory != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              _categoryMessages[_selectedCategory!] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.greenAccent : Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedDate == null
                                    ? 'Seleccione una fecha'
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
                              label: const Text(
                                'Elegir fecha',
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
                        const SizedBox(height: 36),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saveEvent,
                            icon: const Icon(Icons.save, size: 26),
                            label: const Text(
                              'Guardar evento',
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
