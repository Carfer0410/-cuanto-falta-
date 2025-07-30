// 🔄 SCRIPT PARA RESETEAR COMPLETAMENTE LA APP
// Archivo: reset_app_data.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  print('🔄 RESETEANDO DATOS DE LA APP...');
  
  final prefs = await SharedPreferences.getInstance();
  
  // Listar todas las keys antes de borrar
  final keys = prefs.getKeys();
  print('🔍 Datos existentes (${keys.length} keys):');
  for (final key in keys) {
    final value = prefs.get(key);
    print('  • $key: ${value.toString().length > 100 ? '${value.toString().substring(0, 100)}...' : value}');
  }
  
  // Borrar TODOS los datos
  await prefs.clear();
  
  print('\n✅ TODOS LOS DATOS BORRADOS');
  print('🔄 La app ahora empezará completamente desde cero');
  print('🧪 Perfecto para testing del bug');
}
