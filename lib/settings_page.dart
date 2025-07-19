import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const SettingsPage({
    Key? key,
    required this.themeMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Modo oscuro'),
            value: themeMode == ThemeMode.dark,
            onChanged: (val) {
              onThemeChanged(val ? ThemeMode.dark : ThemeMode.light);
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          SwitchListTile(
            title: const Text('Notificaciones'),
            value: true,
            onChanged: (val) {},
            secondary: const Icon(Icons.notifications),
          ),
          SwitchListTile(
            title: const Text('Recordatorios por ubicación'),
            value: false,
            onChanged: (val) {},
            secondary: const Icon(Icons.location_on),
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Importar/Exportar eventos'),
            onTap: () {
              // TODO: implementar funcionalidad
            },
          ),
        ],
      ),
    );
  }
}
