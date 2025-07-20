import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'localization_service.dart';

class OptimalUsageGuide extends StatelessWidget {
  const OptimalUsageGuide({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('💡 ${localization.t('optimal_usage')}'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade100, Colors.orange.shade50],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Icon(Icons.lightbulb, size: 60, color: Colors.orange.shade700),
                  const SizedBox(height: 12),
                  Text(
                    localization.t('get_best_experience'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localization.t('follow_simple_steps'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Paso 1: Minimizar vs Cerrar
            _buildStep(
              context,
              '1',
              Icons.smartphone,
              Colors.green,
              localization.t('minimize_dont_close'),
              localization.t('minimize_dont_close_desc'),
              '✅ ${localization.t('correct')}: ${localization.t('press_home_button')}',
              '❌ ${localization.t('incorrect')}: ${localization.t('swipe_up_close')}',
            ),
            
            const SizedBox(height: 20),
            
            // Paso 2: Configuración de batería
            _buildStep(
              context,
              '2',
              Icons.battery_charging_full,
              Colors.blue,
              localization.t('battery_optimization'),
              localization.t('battery_optimization_desc'),
              '📱 ${localization.t('go_to_settings')}',
              '🔋 ${localization.t('disable_battery_opt')}',
            ),
            
            const SizedBox(height: 20),
            
            // Paso 3: Notificaciones
            _buildStep(
              context,
              '3',
              Icons.notifications,
              Colors.purple,
              localization.t('notifications_enabled'),
              localization.t('notifications_enabled_desc'),
              '🔔 ${localization.t('allow_notifications')}',
              '📢 ${localization.t('enable_sound_vibration')}',
            ),
            
            const SizedBox(height: 24),
            
            // Tarjeta de garantía
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Icon(Icons.verified, size: 50, color: Colors.green.shade600),
                  const SizedBox(height: 12),
                  Text(
                    localization.t('guarantee_title'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localization.t('guarantee_desc'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Botón de entendido
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: Text(
                  localization.t('got_it'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context,
    String stepNumber,
    IconData icon,
    Color color,
    String title,
    String description,
    String tip1,
    String tip2,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Número del paso
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tip1,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip2,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
