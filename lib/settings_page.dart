import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'simple_event_checker.dart';
import 'challenge_notification_service.dart';
import 'localization_service.dart';

class SettingsPage extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const SettingsPage({
    Key? key,
    required this.themeMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _eventNotificationsEnabled = true;
  bool _challengeNotificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _eventFrequency = '5'; // minutos
  String _challengeFrequency = '6'; // horas

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _eventNotificationsEnabled = prefs.getBool('event_notifications_enabled') ?? true;
      _challengeNotificationsEnabled = prefs.getBool('challenge_notifications_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _eventFrequency = prefs.getString('event_frequency') ?? '5';
      _challengeFrequency = prefs.getString('challenge_frequency') ?? '6';
    });
  }

  Future<void> _saveNotificationSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  void _toggleEventNotifications(bool enabled) {
    setState(() {
      _eventNotificationsEnabled = enabled;
    });
    _saveNotificationSetting('event_notifications_enabled', enabled);
    
    if (enabled) {
      SimpleEventChecker.startChecking();
      _showSnackBar('✅ Notificaciones de eventos activadas');
    } else {
      SimpleEventChecker.stopChecking();
      _showSnackBar('🔕 Notificaciones de eventos desactivadas');
    }
  }

  void _toggleChallengeNotifications(bool enabled) {
    setState(() {
      _challengeNotificationsEnabled = enabled;
    });
    _saveNotificationSetting('challenge_notifications_enabled', enabled);
    
    if (enabled) {
      ChallengeNotificationService.startChecking();
      _showSnackBar('✅ Notificaciones de retos activadas');
    } else {
      ChallengeNotificationService.stopChecking();
      _showSnackBar('🔕 Notificaciones de retos desactivadas');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  String _getSystemStatus() {
    String eventStatus = SimpleEventChecker.isActive ? "✅ Activo" : "❌ Inactivo";
    String challengeStatus = ChallengeNotificationService.isActive ? "✅ Activo" : "❌ Inactivo";
    return "Eventos: $eventStatus | Retos: $challengeStatus";
  }

  void _showNotificationInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📱 Información de Notificaciones'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📅 Recordatorios de Eventos:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Solo recibes notificaciones en momentos clave: 30d, 15d, 7d, 3d, 1d antes y el día del evento'),
            Text('• El sistema verifica periódicamente pero NO envía spam'),
            SizedBox(height: 12),
            Text('🎯 Notificaciones Motivacionales:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Solo cuando alcanzas hitos: día 1, día 3, semana 1, 2 semanas, mes 1, etc.'),
            Text('• Sistema anti-spam: cada logro se notifica solo UNA vez'),
            SizedBox(height: 12),
            Text('⚙️ Frecuencia de Verificación:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Controla qué tan seguido el sistema busca nuevos recordatorios'),
            Text('• NO controla la frecuencia de notificaciones recibidas'),
            Text('• Más frecuente = detección más rápida de eventos próximos'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showSystemStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔧 Estado del Sistema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📅 Sistema de Eventos:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Estado: ${SimpleEventChecker.isActive ? "✅ Funcionando" : "❌ Detenido"}'),
            Text('Frecuencia: Cada $_eventFrequency minutos'),
            SizedBox(height: 12),
            Text('🎯 Sistema de Retos:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Estado: ${ChallengeNotificationService.isActive ? "✅ Funcionando" : "❌ Detenido"}'),
            Text('Frecuencia: Cada $_challengeFrequency horas'),
            SizedBox(height: 12),
            Text('🔊 Configuración de Audio:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Sonido: ${_soundEnabled ? "✅ Habilitado" : "❌ Deshabilitado"}'),
            Text('Vibración: ${_vibrationEnabled ? "✅ Habilitada" : "❌ Deshabilitada"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () async {
              // Enviar notificación de prueba
              await NotificationService.instance.showImmediateNotification(
                id: 999,
                title: '🧪 Prueba del Sistema',
                body: 'El sistema de notificaciones está funcionando correctamente.',
              );
              if (!mounted) return;
              Navigator.pop(context);
              _showSnackBar('🔔 Notificación de prueba enviada');
            },
            child: const Text('Probar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(localizationService.t('settings')),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de Tema
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        localizationService.t('appearance'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  Divider(),
                  SwitchListTile(
                    title: Text(localizationService.t('darkTheme')),
                    subtitle: Text(localizationService.t('themeDescription')),
                    value: widget.themeMode == ThemeMode.dark,
                    onChanged: (val) {
                      widget.onThemeChanged(val ? ThemeMode.dark : ThemeMode.light);
                    },
                    secondary: const Icon(Icons.dark_mode),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Sección de Idioma
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.language, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        LocalizationService.instance.t('language'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  Divider(),
                  ListTile(
                    leading: const Icon(Icons.translate),
                    title: Text(LocalizationService.instance.t('language')),
                    subtitle: Text(LocalizationService.supportedLanguages[LocalizationService.instance.currentLanguage] ?? 'Español'),
                    trailing: DropdownButton<String>(
                      value: LocalizationService.instance.currentLanguage,
                      items: LocalizationService.supportedLanguages.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (String? newLanguage) async {
                        if (newLanguage != null) {
                          await LocalizationService.instance.setLanguage(newLanguage);
                          // El Consumer se actualiza automáticamente, no necesitamos setState
                          _showSnackBar('🌍 Idioma cambiado: ${LocalizationService.supportedLanguages[newLanguage]}');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Sección de Notificaciones
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        localizationService.t('notifications'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  Divider(),
                  
                  // Notificaciones de Eventos
                  SwitchListTile(
                    title: Text(localizationService.t('eventNotifications')),
                    subtitle: Text(_eventNotificationsEnabled 
                      ? 'Sistema verifica eventos cada $_eventFrequency minutos para enviar recordatorios oportunos'
                      : 'No recibirás recordatorios de eventos'),
                    value: _eventNotificationsEnabled,
                    onChanged: _toggleEventNotifications,
                    secondary: const Icon(Icons.event),
                  ),
                  
                  // Notificaciones de Retos
                  SwitchListTile(
                    title: Text(localizationService.t('challengeNotifications')),
                    subtitle: Text(_challengeNotificationsEnabled 
                      ? 'Sistema verifica logros cada $_challengeFrequency horas para enviarte motivación'
                      : 'No recibirás notificaciones motivacionales'),
                    value: _challengeNotificationsEnabled,
                    onChanged: _toggleChallengeNotifications,
                    secondary: const Icon(Icons.fitness_center),
                  ),
                  
                  // Configuraciones de sonido
                  SwitchListTile(
                    title: Text(localizationService.t('sound')),
                    subtitle: Text(localizationService.t('soundEnabled')),
                    value: _soundEnabled,
                    onChanged: (val) {
                      setState(() {
                        _soundEnabled = val;
                      });
                      _saveNotificationSetting('sound_enabled', val);
                      _showSnackBar(val ? '🔊 Sonido activado' : '🔇 Sonido desactivado');
                    },
                    secondary: Icon(_soundEnabled ? Icons.volume_up : Icons.volume_off),
                  ),
                  
                  // Configuraciones de vibración
                  SwitchListTile(
                    title: Text(localizationService.t('vibration')),
                    subtitle: Text(localizationService.t('vibrationEnabled')),
                    value: _vibrationEnabled,
                    onChanged: (val) {
                      setState(() {
                        _vibrationEnabled = val;
                      });
                      _saveNotificationSetting('vibration_enabled', val);
                      _showSnackBar(val ? '📳 Vibración activada' : '📴 Vibración desactivada');
                    },
                    secondary: Icon(_vibrationEnabled ? Icons.vibration : Icons.phone_android),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Sección de Configuración Avanzada
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        localizationService.t('advancedSettings'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  Divider(),
                  
                  // Frecuencia de eventos
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: Text(localizationService.t('eventFrequency')),
                    subtitle: Text('Cada $_eventFrequency minutos'),
                    trailing: DropdownButton<String>(
                      value: _eventFrequency,
                      items: ['1', '3', '5', '10', '15'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text('$value min'),
                        );
                      }).toList(),
                      onChanged: _eventNotificationsEnabled ? (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _eventFrequency = newValue;
                          });
                          _saveNotificationSetting('event_frequency', newValue);
                          _showSnackBar('⏱️ Frecuencia de eventos: cada $newValue minutos');
                          // Reiniciar el servicio con nueva frecuencia
                          SimpleEventChecker.stopChecking();
                          SimpleEventChecker.startChecking();
                        }
                      } : null,
                    ),
                  ),
                  
                  // Frecuencia de retos
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(localizationService.t('challengeFrequency')),
                    subtitle: Text('Cada $_challengeFrequency horas'),
                    trailing: DropdownButton<String>(
                      value: _challengeFrequency,
                      items: ['3', '6', '12', '24'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text('${value}h'),
                        );
                      }).toList(),
                      onChanged: _challengeNotificationsEnabled ? (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _challengeFrequency = newValue;
                          });
                          _saveNotificationSetting('challenge_frequency', newValue);
                          _showSnackBar('🎯 Frecuencia de retos: cada $newValue horas');
                          // Reiniciar el servicio con nueva frecuencia
                          ChallengeNotificationService.stopChecking();
                          ChallengeNotificationService.startChecking();
                        }
                      } : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Sección de Información
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        localizationService.t('about'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  Divider(),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: Text(localizationService.t('notificationInfo')),
                    subtitle: const Text('Cómo funcionan los recordatorios'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showNotificationInfoDialog(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: Text(localizationService.t('systemStatus')),
                    subtitle: Text(_getSystemStatus()),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showSystemStatusDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}
