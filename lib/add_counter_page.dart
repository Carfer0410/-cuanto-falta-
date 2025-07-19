import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'counters_page.dart';

class AddCounterPage extends StatefulWidget {
  const AddCounterPage({Key? key}) : super(key: key);

  @override
  State<AddCounterPage> createState() => _AddCounterPageState();
}

class _AddCounterPageState extends State<AddCounterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'dejar de'; // Default value

  final List<String> _types = [
    'dejar de',
    'empezar a',
  ]; // Options for the dropdown

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

  Future<void> _saveCounter() async {
    if (_formKey.currentState?.validate() != true) return;
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('counters');
    List<dynamic> list = [];
    if (jsonString != null) {
      list = jsonDecode(jsonString);
    }
    final newCounter = Counter(
      title: _titleController.text.trim(), // Solo el texto ingresado
      startDate: _selectedDate,
      isNegativeHabit: _selectedType == 'dejar de', // Marca hábito negativo según tipo
    );
    list.add(newCounter.toJson());
    await prefs.setString('counters', jsonEncode(list));
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nuevo reto'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Consejo',
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Consejo para el título'),
                      content: const Text(
                        'Usa una o dos palabras clave para tu reto. Ejemplo: "Cigarro", "Alcohol", "Ejercicio". Así la pantalla se verá limpia y profesional.',
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 12,
                color: const Color(0xFFFFF3E0),
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
                            labelText: '¿Qúe quieres dejar o iniciar a realizar?',
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              fontSize: 18,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(18),
                              ),
                              borderSide: BorderSide(color: Colors.orange),
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
                              borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                            helperText:
                                'Ejemplo: Dejar de fumar, Hacer ejercicio, Aprender inglés, Meditar... ',
                            helperStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.orange,
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Ingrese un reto o hábito'
                                      : null,
                          textInputAction: TextInputAction.done,
                          autofocus: true,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: InputDecoration(
                            labelText: 'Tipo de reto',
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              fontSize: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: Colors.orange.shade100,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
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
                                'Fecha de inicio:',
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
                        const SizedBox(height: 36),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saveCounter,
                            icon: const Icon(Icons.save, size: 26),
                            label: const Text(
                              'Guardar reto',
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
