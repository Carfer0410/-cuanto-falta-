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
      _showLocalizedSnackBar('eventsActivated');
    } else {
      SimpleEventChecker.stopChecking();
      _showLocalizedSnackBar('eventsDeactivated');
    }
  }

  void _toggleChallengeNotifications(bool enabled) {
    setState(() {
      _challengeNotificationsEnabled = enabled;
    });
    _saveNotificationSetting('challenge_notifications_enabled', enabled);
    
    if (enabled) {
      ChallengeNotificationService.startChecking();
      _showLocalizedSnackBar('challengesActivated');
    } else {
      ChallengeNotificationService.stopChecking();
      _showLocalizedSnackBar('challengesDeactivated');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  void _showLocalizedSnackBar(String key, [Map<String, String>? params]) {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    String message = localizationService.t(key);
    if (params != null) {
      params.forEach((placeholder, value) {
        message = message.replaceAll('{$placeholder}', value);
      });
    }
    _showSnackBar(message);
  }

  String _getSystemStatus() {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    String eventStatus = SimpleEventChecker.isActive ? localizationService.t('active') : localizationService.t('inactive');
    String challengeStatus = ChallengeNotificationService.isActive ? localizationService.t('active') : localizationService.t('inactive');
    return "${localizationService.t('eventsStatus')}: $eventStatus | ${localizationService.t('challengesStatus')}: $challengeStatus";
  }

  void _showNotificationInfoDialog(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizationService.t('notificationInfoTitle')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizationService.t('eventRemindersTitle'), style: TextStyle(fontWeight: FontWeight.bold)),
            Text(localizationService.t('eventRemindersDescription')),
            SizedBox(height: 12),
            Text(localizationService.t('motivationalNotificationsTitle'), style: TextStyle(fontWeight: FontWeight.bold)),
            Text(localizationService.t('motivationalNotificationsDescription')),
            SizedBox(height: 12),
            Text(localizationService.t('verificationFrequencyTitle'), style: TextStyle(fontWeight: FontWeight.bold)),
            Text(localizationService.t('verificationFrequencyDescription')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizationService.t('understood')),
          ),
        ],
      ),
    );
  }

  void _showSystemStatusDialog(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizationService.t('systemStatusTitle')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizationService.t('eventSystemTitle'), style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${localizationService.t('systemStatus')}: ${SimpleEventChecker.isActive ? localizationService.t('systemActive') : localizationService.t('systemInactive')}'),
            Text('${localizationService.t('frequencyEvery').replaceAll('{frequency}', _eventFrequency)} ${localizationService.t('minutesUnit')}'),
            SizedBox(height: 12),
            Text(localizationService.t('challengeSystemTitle'), style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${localizationService.t('systemStatus')}: ${ChallengeNotificationService.isActive ? localizationService.t('systemActive') : localizationService.t('systemInactive')}'),
            Text('${localizationService.t('frequencyEvery').replaceAll('{frequency}', _challengeFrequency)} ${localizationService.t('hoursUnit')}'),
            SizedBox(height: 12),
            Text(localizationService.t('audioConfigTitle'), style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${localizationService.t('sound')}: ${_soundEnabled ? localizationService.t('soundEnabledStatus') : localizationService.t('soundDisabledStatus')}'),
            Text('${localizationService.t('vibration')}: ${_vibrationEnabled ? localizationService.t('vibrationEnabledStatus') : localizationService.t('vibrationDisabledStatus')}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizationService.t('close')),
          ),
          TextButton(
            onPressed: () async {
              // Enviar notificación de prueba
              await NotificationService.instance.showImmediateNotification(
                id: 999,
                title: localizationService.t('testNotificationTitle'),
                body: localizationService.t('testNotificationBody'),
              );
              if (!mounted) return;
              Navigator.pop(context);
              _showLocalizedSnackBar('testNotificationSent');
            },
            child: Text(localizationService.t('test')),
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
                          _showLocalizedSnackBar('languageChanged', {'language': LocalizationService.supportedLanguages[newLanguage] ?? newLanguage});
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
                      ? localizationService.t('eventNotificationSubtitleEnabled').replaceAll('{frequency}', _eventFrequency)
                      : localizationService.t('eventNotificationSubtitleDisabled')),
                    value: _eventNotificationsEnabled,
                    onChanged: _toggleEventNotifications,
                    secondary: const Icon(Icons.event),
                  ),
                  
                  // Notificaciones de Retos
                  SwitchListTile(
                    title: Text(localizationService.t('challengeNotifications')),
                    subtitle: Text(_challengeNotificationsEnabled 
                      ? localizationService.t('challengeNotificationSubtitleEnabled').replaceAll('{frequency}', _challengeFrequency)
                      : localizationService.t('challengeNotificationSubtitleDisabled')),
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
                      _showLocalizedSnackBar(val ? 'soundActivated' : 'soundDeactivated');
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
                      _showLocalizedSnackBar(val ? 'vibrationActivated' : 'vibrationDeactivated');
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
                    subtitle: Text('${localizationService.t('frequencyEvery').replaceAll('{frequency}', _eventFrequency)} ${localizationService.t('minutesUnit')}'),
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
                          _showLocalizedSnackBar('eventFrequencyChanged', {'frequency': newValue});
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
                    subtitle: Text('${localizationService.t('frequencyEvery').replaceAll('{frequency}', _challengeFrequency)} ${localizationService.t('hoursUnit')}'),
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
                          _showLocalizedSnackBar('challengeFrequencyChanged', {'frequency': newValue});
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
                    subtitle: Text(localizationService.t('howNotificationsWork')),
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
