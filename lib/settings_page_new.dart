import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'notification_service.dart';
import 'simple_event_checker.dart';
import 'challenge_notification_service.dart';
import 'planning_style_service.dart';
import 'planning_style_selection_page.dart';
import 'theme_service.dart';
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
            Text('• 30 días, 15 días, 7 días, 3 días, 1 día antes y el día del evento'),
            SizedBox(height: 12),
            Text('🎯 Notificaciones Motivacionales:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Día 1, día 3, semana 1, 2 semanas, mes 1, cada mes adicional, año 1+'),
            SizedBox(height: 12),
            Text('⚙️ Configuración:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Puedes ajustar la frecuencia de verificación'),
            Text('• Activar/desactivar sonido y vibración'),
            Text('• Controlar cada tipo por separado'),
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: context.orangeVariant,
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
                      Icon(Icons.palette, color: context.orangeVariant),
                      const SizedBox(width: 8),
                      Text(
                        'Apariencia',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: context.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: context.dividerColor),
                  SwitchListTile(
                    title: Text(
                      'Modo claro o oscuro',
                      style: TextStyle(color: context.primaryTextColor),
                    ),
                    subtitle: Text(
                      'Cambia entre tema claro y oscuro',
                      style: TextStyle(color: context.secondaryTextColor),
                    ),
                    value: widget.themeMode == ThemeMode.dark,
                    onChanged: (val) {
                      final newMode = val ? ThemeMode.dark : ThemeMode.light;
                      widget.onThemeChanged(newMode);
                      _showSnackBar(val ? '🌙 Modo oscuro activado' : '☀️ Modo claro activado');
                    },
                    secondary: Icon(
                      widget.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                      color: context.orangeVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sección de Personalización
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: context.orangeVariant),
                      const SizedBox(width: 8),
                      Text(
                        'Personalización',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: context.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: context.dividerColor),
                  Consumer<PlanningStyleService>(
                    builder: (context, planningService, child) {
                      final currentStyle = planningService.currentStyle;
                      final styleInfo = planningService.styleInfo[currentStyle]!;
                      
                      return ListTile(
                        leading: Text(
                          styleInfo['emoji'],
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          'Estilo de Planificación',
                          style: TextStyle(color: context.primaryTextColor),
                        ),
                        subtitle: Text(
                          '${styleInfo['name']} - ${styleInfo['description']}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: context.secondaryTextColor),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'x${styleInfo['multiplier']}',
                              style: TextStyle(
                                color: context.orangeVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: context.iconColor,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PlanningStyleSelectionPage(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sección de Idioma
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.language, color: context.orangeVariant),
                      const SizedBox(width: 8),
                      Consumer<LocalizationService>(
                        builder: (context, localizationService, child) {
                          return Text(
                            localizationService.t('language'),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: context.primaryTextColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Divider(color: context.dividerColor),
                  Consumer<LocalizationService>(
                    builder: (context, localizationService, child) {
                      return ListTile(
                        leading: Icon(
                          Icons.translate,
                          color: context.iconColor,
                        ),
                        title: Text(
                          localizationService.t('selectLanguage'),
                          style: TextStyle(color: context.primaryTextColor),
                        ),
                        subtitle: Text(
                          LocalizationService.supportedLanguages[localizationService.currentLanguage] ?? 'Español',
                          style: TextStyle(color: context.secondaryTextColor),
                        ),
                        trailing: DropdownButton<String>(
                          value: localizationService.currentLanguage,
                          dropdownColor: context.cardColor,
                          items: LocalizationService.supportedLanguages.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(
                                entry.value,
                                style: TextStyle(color: context.primaryTextColor),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newLanguage) async {
                            if (newLanguage != null) {
                              await localizationService.setLanguage(newLanguage);
                              final languageName = LocalizationService.supportedLanguages[newLanguage] ?? newLanguage;
                              _showSnackBar('🌍 Idioma cambiado a $languageName');
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sección de Notificaciones
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications, color: context.orangeVariant),
                      const SizedBox(width: 8),
                      Text(
                        'Notificaciones',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: context.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: context.dividerColor),
                  
                  // Notificaciones de Eventos
                  SwitchListTile(
                    title: Text(
                      'Recordatorios de Eventos',
                      style: TextStyle(color: context.primaryTextColor),
                    ),
                    subtitle: Text(
                      _eventNotificationsEnabled 
                        ? 'Recibirás notificaciones cada $_eventFrequency minutos'
                        : 'No recibirás recordatorios de eventos',
                      style: TextStyle(color: context.secondaryTextColor),
                    ),
                    value: _eventNotificationsEnabled,
                    onChanged: _toggleEventNotifications,
                    secondary: const Icon(Icons.event),
                  ),
                  
                  // Notificaciones de Retos
                  SwitchListTile(
                    title: const Text('Notificaciones Motivacionales'),
                    subtitle: Text(_challengeNotificationsEnabled 
                      ? 'Recibirás motivación de tus retos cada $_challengeFrequency horas'
                      : 'No recibirás notificaciones motivacionales'),
                    value: _challengeNotificationsEnabled,
                    onChanged: _toggleChallengeNotifications,
                    secondary: const Icon(Icons.fitness_center),
                  ),
                  
                  // Configuraciones de sonido
                  SwitchListTile(
                    title: const Text('Sonido'),
                    subtitle: const Text('Reproducir sonido con las notificaciones'),
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
                    title: const Text('Vibración'),
                    subtitle: const Text('Vibrar el dispositivo con las notificaciones'),
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
                      Icon(Icons.tune, color: context.orangeVariant),
                      SizedBox(width: 8),
                      Text(
                        'Configuración Avanzada',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: context.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  
                  // Frecuencia de eventos
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: const Text('Frecuencia de verificación de eventos'),
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
                    title: const Text('Frecuencia de verificación de retos'),
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
                      Icon(Icons.info, color: context.orangeVariant),
                      SizedBox(width: 8),
                      Text(
                        'Información',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: context.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Acerca de las notificaciones'),
                    subtitle: const Text('Cómo funcionan los recordatorios'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showNotificationInfoDialog(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: const Text('Estado del sistema'),
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
  }
}
