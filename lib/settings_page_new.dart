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
import 'notification_center_widgets.dart';

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
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    String eventStatus = SimpleEventChecker.isActive ? localizationService.t('systemActive') : localizationService.t('systemInactive');
    String challengeStatus = ChallengeNotificationService.isActive ? localizationService.t('systemActive') : localizationService.t('systemInactive');
    return "${localizationService.t('events')}: $eventStatus | ${localizationService.t('challenges')}: $challengeStatus";
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
              Navigator.pop(context);
              _showSnackBar(localizationService.t('testNotificationSent'));
            },
            child: Text(localizationService.t('test')),
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
        title: Consumer<LocalizationService>(
          builder: (context, localizationService, child) {
            return Text(localizationService.t('settings'));
          },
        ),
        backgroundColor: context.orangeVariant,
        foregroundColor: Colors.white,
        actions: [
          // 🔔 NUEVO: Centro de notificaciones
          const NotificationCenterButton(),
        ],
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
                      Consumer<LocalizationService>(
                        builder: (context, localizationService, child) {
                          return Text(
                            localizationService.t('appearance'),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: context.primaryTextColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Divider(color: context.dividerColor),
                  SwitchListTile(
                    title: Consumer<LocalizationService>(
                      builder: (context, localizationService, child) {
                        return Text(
                          localizationService.t('darkTheme'),
                          style: TextStyle(color: context.primaryTextColor),
                        );
                      },
                    ),
                    subtitle: Consumer<LocalizationService>(
                      builder: (context, localizationService, child) {
                        return Text(
                          localizationService.t('themeDescription'),
                          style: TextStyle(color: context.secondaryTextColor),
                        );
                      },
                    ),
                    value: widget.themeMode == ThemeMode.dark,
                    onChanged: (val) {
                      final newMode = val ? ThemeMode.dark : ThemeMode.light;
                      widget.onThemeChanged(newMode);
                      // Usar textos traducidos
                      final localizationService = Provider.of<LocalizationService>(context, listen: false);
                      _showSnackBar(val ? localizationService.t('darkThemeActivated') : localizationService.t('lightThemeActivated'));
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
                      Consumer<LocalizationService>(
                        builder: (context, localizationService, child) {
                          return Text(
                            localizationService.t('customization'),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: context.primaryTextColor,
                            ),
                          );
                        },
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
                        title: Consumer<LocalizationService>(
                          builder: (context, localizationService, child) {
                            return Text(
                              localizationService.t('planningStyle'),
                              style: TextStyle(color: context.primaryTextColor),
                            );
                          },
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
                      Consumer<LocalizationService>(
                        builder: (context, localizationService, child) {
                          return Text(
                            localizationService.t('notifications'),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: context.primaryTextColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Divider(color: context.dividerColor),
                  
                  // Notificaciones de Eventos
                  SwitchListTile(
                    title: Consumer<LocalizationService>(
                      builder: (context, localizationService, child) {
                        return Text(
                          localizationService.t('eventNotifications'),
                          style: TextStyle(color: context.primaryTextColor),
                        );
                      },
                    ),
                    subtitle: Consumer<LocalizationService>(
                      builder: (context, localizationService, child) {
                        return Text(
                          _eventNotificationsEnabled 
                            ? localizationService.t('eventNotificationSubtitleEnabled').replaceAll('{frequency}', _eventFrequency)
                            : localizationService.t('eventNotificationSubtitleDisabled'),
                          style: TextStyle(color: context.secondaryTextColor),
                        );
                      },
                    ),
                    value: _eventNotificationsEnabled,
                    onChanged: _toggleEventNotifications,
                    secondary: const Icon(Icons.event),
                  ),
                  
                  // Notificaciones de Retos
                  SwitchListTile(
                    title: Consumer<LocalizationService>(
                      builder: (context, localizationService, child) {
                        return Text(
                          localizationService.t('challengeNotifications'),
                          style: TextStyle(color: context.primaryTextColor),
                        );
                      },
                    ),
                    subtitle: Consumer<LocalizationService>(
                      builder: (context, localizationService, child) {
                        return Text(
                          _challengeNotificationsEnabled 
                            ? localizationService.t('challengeNotificationSubtitleEnabled').replaceAll('{frequency}', _challengeFrequency)
                            : localizationService.t('challengeNotificationSubtitleDisabled'),
                          style: TextStyle(color: context.secondaryTextColor),
                        );
                      },
                    ),
                    value: _challengeNotificationsEnabled,
                    onChanged: _toggleChallengeNotifications,
                    secondary: const Icon(Icons.fitness_center),
                  ),
                  
                  // Configuraciones de sonido
                  SwitchListTile(
                    title: Consumer<LocalizationService>(
                      builder: (context, localizationService, child) {
                        return Text(
                          localizationService.t('sound'),
                          style: TextStyle(color: context.primaryTextColor),
                        );
                      },
                    ),
                    subtitle: Consumer<LocalizationService>(
                      builder: (context, localizationService, child) {
                        return Text(
                          localizationService.t('soundEnabled'),
                          style: TextStyle(color: context.secondaryTextColor),
                        );
                      },
                    ),
                    value: _soundEnabled,
                    onChanged: (val) {
                      setState(() {
                        _soundEnabled = val;
                      });
                      _saveNotificationSetting('sound_enabled', val);
                      final localizationService = Provider.of<LocalizationService>(context, listen: false);
                      _showSnackBar(val ? localizationService.t('soundActivated') : localizationService.t('soundDeactivated'));
                    },
                    secondary: Icon(_soundEnabled ? Icons.volume_up : Icons.volume_off),
                  ),
                  
                  // Configuraciones de vibración
                  SwitchListTile(
                    title: Consumer<LocalizationService>(
                      builder: (context, localizationService, child) {
                        return Text(
                          localizationService.t('vibration'),
                          style: TextStyle(color: context.primaryTextColor),
                        );
                      },
                    ),
                    subtitle: Consumer<LocalizationService>(
                      builder: (context, localizationService, child) {
                        return Text(
                          localizationService.t('vibrationEnabled'),
                          style: TextStyle(color: context.secondaryTextColor),
                        );
                      },
                    ),
                    value: _vibrationEnabled,
                    onChanged: (val) {
                      setState(() {
                        _vibrationEnabled = val;
                      });
                      _saveNotificationSetting('vibration_enabled', val);
                      final localizationService = Provider.of<LocalizationService>(context, listen: false);
                      _showSnackBar(val ? localizationService.t('vibrationActivated') : localizationService.t('vibrationDeactivated'));
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
                      Consumer<LocalizationService>(
                        builder: (context, localizationService, child) {
                          return Text(
                            localizationService.t('advancedSettings'),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: context.primaryTextColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Divider(),
                  
                  // Frecuencia de eventos
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: Consumer<LocalizationService>(
                      builder: (context, localizationService, child) {
                        return Text(
                          localizationService.t('eventFrequency'),
                          style: TextStyle(color: context.primaryTextColor),
                        );
                      },
                    ),
                    subtitle: Consumer<LocalizationService>(
                      builder: (context, localizationService, child) {
                        return Text(
                          '${localizationService.t('frequencyEvery').replaceAll('{frequency}', _eventFrequency)} ${localizationService.t('minutesUnit')}',
                          style: TextStyle(color: context.secondaryTextColor),
                        );
                      },
                    ),
                    trailing: DropdownButton<String>(
                      value: _eventFrequency,
                      items: ['1', '3', '5', '10', '15'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Consumer<LocalizationService>(
                            builder: (context, localizationService, child) {
                              return Text('$value ${localizationService.t('minutesShort')}');
                            },
                          ),
                        );
                      }).toList(),
                      onChanged: _eventNotificationsEnabled ? (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _eventFrequency = newValue;
                          });
                          _saveNotificationSetting('event_frequency', newValue);
                          final localizationService = Provider.of<LocalizationService>(context, listen: false);
                          _showSnackBar(localizationService.t('eventFrequencyChanged').replaceAll('{frequency}', newValue));
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
                    title: Consumer<LocalizationService>(
                      builder: (context, localizationService, child) {
                        return Text(
                          localizationService.t('challengeFrequency'),
                          style: TextStyle(color: context.primaryTextColor),
                        );
                      },
                    ),
                    subtitle: Consumer<LocalizationService>(
                      builder: (context, localizationService, child) {
                        return Text(
                          '${localizationService.t('frequencyEvery').replaceAll('{frequency}', _challengeFrequency)} ${localizationService.t('hoursUnit')}',
                          style: TextStyle(color: context.secondaryTextColor),
                        );
                      },
                    ),
                    trailing: DropdownButton<String>(
                      value: _challengeFrequency,
                      items: ['3', '6', '12', '24'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Consumer<LocalizationService>(
                            builder: (context, localizationService, child) {
                              return Text('$value${localizationService.t('hoursShort')}');
                            },
                          ),
                        );
                      }).toList(),
                      onChanged: _challengeNotificationsEnabled ? (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _challengeFrequency = newValue;
                          });
                          _saveNotificationSetting('challenge_frequency', newValue);
                          final localizationService = Provider.of<LocalizationService>(context, listen: false);
                          _showSnackBar(localizationService.t('challengeFrequencyChanged').replaceAll('{frequency}', newValue));
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
                      Consumer<LocalizationService>(
                        builder: (context, localizationService, child) {
                          return Text(
                            localizationService.t('about'),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: context.primaryTextColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Divider(),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: Consumer<LocalizationService>(
                      builder: (context, localizationService, child) {
                        return Text(
                          localizationService.t('notificationInfo'),
                          style: TextStyle(color: context.primaryTextColor),
                        );
                      },
                    ),
                    subtitle: Consumer<LocalizationService>(
                      builder: (context, localizationService, child) {
                        return Text(
                          localizationService.t('howNotificationsWork'),
                          style: TextStyle(color: context.secondaryTextColor),
                        );
                      },
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showNotificationInfoDialog(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: Consumer<LocalizationService>(
                      builder: (context, localizationService, child) {
                        return Text(
                          localizationService.t('systemStatus'),
                          style: TextStyle(color: context.primaryTextColor),
                        );
                      },
                    ),
                    subtitle: Text(
                      _getSystemStatus(),
                      style: TextStyle(color: context.secondaryTextColor),
                    ),
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
