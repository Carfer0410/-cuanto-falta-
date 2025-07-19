import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'counters_page.dart';
import 'settings_page.dart';
import 'localization_service.dart';

class RootPage extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const RootPage({
    Key? key,
    required this.themeMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _selectedIndex = 0;

  void _handleThemeChange(ThemeMode mode) {
    widget.onThemeChanged(mode);
    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        themeMode: widget.themeMode,
        onThemeChanged: _handleThemeChange,
      ),
      const CountersPage(),
      SettingsPage(
        themeMode: widget.themeMode,
        onThemeChanged: _handleThemeChange,
      ),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Consumer<LocalizationService>(
        builder: (context, localizationService, child) {
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home), 
                label: localizationService.t('homeTab')
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timer), 
                label: localizationService.t('challengesTab')
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings), 
                label: localizationService.t('settingsTab')
              ),
            ],
          );
        },
      ),
    );
  }
}
