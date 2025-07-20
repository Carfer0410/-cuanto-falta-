import 'package:flutter/foundation.dart';
import 'database_helper.dart';
import 'localization_service.dart';

void main() async {
  debugPrint('🔍 Revisando estado de la base de datos...');
  
  // Cargar el idioma guardado
  await LocalizationService.instance.loadLanguage();
  
  // Obtener todos los eventos
  final dbHelper = DatabaseHelper.instance;
  final events = await dbHelper.getEvents();
  
  debugPrint('📋 Eventos encontrados: ${events.length}');
  
  for (var event in events) {
    debugPrint('---');
    debugPrint('Evento: ${event.title}');
    debugPrint('Categoría: ${event.category}');
    debugPrint('Fecha: ${event.targetDate}');
    
    // Probar obtener el mensaje de categoría
    final message = LocalizationService.instance.getCategoryMessage(event.category);
    debugPrint('Mensaje de categoría: $message');
    debugPrint('---');
  }
  
  // También revisar las categorías disponibles
  debugPrint('\n🏷️ Categorías disponibles:');
  final categories = LocalizationService.instance.getCategories();
  for (var category in categories) {
    debugPrint('${category.key}: ${category.value}');
  }
  
  debugPrint('\n✅ Revisión completada');
}
