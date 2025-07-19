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
  static const List<String> _bannedWords = ['mierda', 'puta', 'idiota'];
  static final DateTime _minDate = DateTime.now().subtract(Duration(days: 3650)); // hace 10 años
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
        title: Text('Fecha inválida'),
        content: Text('Seleccione una fecha dentro de los últimos 10 años y sin pasar hoy.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
      ));
      return;
    }
    // Validar duplicados
    if (list.any((e) => (e['title'] as String) == sanitized)) {
      if (!mounted) return;
      showDialog(context: context, builder: (_) => AlertDialog(
        title: Text('Reto duplicado'),
        content: Text('Ya existe un reto con este título.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
      ));
      return;
    }
    final newCounter = Counter(
      title: sanitized,
      startDate: _selectedDate,
      isNegativeHabit: _selectedType == 'dejar de', // Marca hábito negativo según tipo
    );
    list.add(newCounter.toJson());
    await prefs.setString('counters', jsonEncode(list));
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Nuevo reto'),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? (isDark ? Colors.black : Colors.orange),
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
                            labelText: '¿Qúe quieres dejar o iniciar a realizar?',
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
                            helperText:
                                'Ejemplo: Dejar de fumar, Hacer ejercicio, Aprender inglés, Meditar... ',
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
                              return 'Ingrese un reto o hábito';
                            }
                            final sanitized = _sanitizeTitle(value);
                            if (sanitized.isEmpty) {
                              return 'Título inválido después de limpieza';
                            }
                            if (sanitized.length < 3) {
                              return 'Título muy corto (mín. 3 caracteres)';
                            }
                            final words = sanitized.split(RegExp(r'\s+'));
                            if (words.length > 2) {
                              return 'Use máximo dos palabras clave';
                            }
                            if (sanitized.length > 20) {
                              return 'Título muy largo (máx. 20 caracteres)';
                            }
                            if (RegExp(r'^[0-9]+$').hasMatch(sanitized)) {
                              return 'Título no puede ser solo números';
                            }
                            if (words.any((w) => _bannedWords.contains(w))) {
                              return 'Palabra no permitida';
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
                            labelText: 'Tipo de reto',
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
