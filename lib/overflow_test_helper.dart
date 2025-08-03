// 🧪 ARCHIVO DE PRUEBA TEMPORAL - Overflow Test
// Este archivo ayuda a reproducir y solucionar el problema de overflow

import 'package:flutter/material.dart';
import 'notification_service.dart';

class OverflowTestHelper {
  
  /// Función para generar una notificación con texto largo similar al problema reportado
  static Future<void> generateLongNotificationTest() async {
    const longTitle = '🛡️ Ficha de perdón usada';
    const longBody = 'No confirmaste "Mi Reto de Prueba Muy Largo Para Generar Overflow" ayer (31/7), pero se usó una ficha de perdón. Tu racha siguió creciendo automáticamente.';
    
    // Simular notificación del sistema
    await NotificationService.instance.showImmediateNotification(
      id: 99991,
      title: longTitle,
      body: longBody,
    );
    
    print('🧪 Notificación de prueba con texto largo generada');
  }
  
  /// Función para generar múltiples notificaciones y probar el overflow
  static Future<void> generateMultipleOverflowTests() async {
    final longNotifications = [
      {
        'title': '🛡️ Ficha de perdón usada',
        'body': 'Ficha usada para "Hacer ejercicio todos los días sin excepción durante todo el año" (31/7). Racha preservada automáticamente.',
      },
      {
        'title': '💔 Racha perdida',
        'body': 'No confirmaste "Estudiar programación avanzada en Flutter durante 2 horas diarias" ayer (31/7). Racha reseteada completamente.',
      },
      {
        'title': '🎉 ¡Logro desbloqueado!',
        'body': 'Has completado "Meditar por 30 minutos cada mañana antes del desayuno" durante 7 días consecutivos. ¡Sigue así para mantener tu racha!',
      },
    ];
    
    for (int i = 0; i < longNotifications.length; i++) {
      final notification = longNotifications[i];
      
      await NotificationService.instance.showImmediateNotification(
        id: 99992 + i,
        title: notification['title']!,
        body: notification['body']!,
      );
      
      // Esperar un momento entre notificaciones
      await Future.delayed(Duration(seconds: 1));
    }
    
    print('🧪 ${longNotifications.length} notificaciones de prueba generadas');
  }
  
  /// Widget de prueba para verificar el layout del NotificationBanner directamente
  static Widget buildTestNotificationBanner() {
    return Column(
      children: [
        Text('🧪 Test de NotificationBanner con textos largos:'),
        SizedBox(height: 16),
        
        // Simular NotificationCard con texto largo
        Card(
          margin: EdgeInsets.all(16),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange.withOpacity(0.2),
                  radius: 20,
                  child: Icon(
                    Icons.warning,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🛡️ Ficha de perdón usada',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'No confirmaste "Mi Reto de Prueba Super Ultra Mega Largo Para Generar Overflow En La Interfaz De Usuario" ayer (31/7), pero se usó una ficha de perdón. Tu racha siguió creciendo automáticamente sin problemas.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: IconButton(
                    onPressed: () {
                      print('🧪 Test: Botón cerrar presionado');
                    },
                    icon: Icon(Icons.close, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: generateLongNotificationTest,
          child: Text('Generar Notificación de Prueba'),
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: generateMultipleOverflowTests,
          child: Text('Generar Múltiples Pruebas'),
        ),
      ],
    );
  }
}

/// Página de prueba para overflow
class OverflowTestPage extends StatelessWidget {
  const OverflowTestPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🧪 Test de Overflow'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: OverflowTestHelper.buildTestNotificationBanner(),
      ),
    );
  }
}
