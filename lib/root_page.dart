import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'counters_page.dart';
import 'settings_page_new.dart';
import 'dashboard_page.dart';
import 'localization_service.dart';
import 'notification_navigation_service.dart';

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

  @override
  void initState() {
    super.initState();
    // 🆕 NUEVO: Verificar si hay navegación pendiente desde notificaciones
    _checkPendingNavigation();
  }

  /// Verifica si hay navegación pendiente desde notificaciones
  Future<void> _checkPendingNavigation() async {
    final pendingTab = await NotificationNavigationService.getAndClearPendingTabNavigation();
    if (pendingTab != null && mounted) {
      setState(() {
        _selectedIndex = pendingTab;
      });
      print('📱 Navegación desde notificación: Pestaña $pendingTab activada');
    }
  }

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
      const DashboardPage(),
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
                icon: Icon(Icons.dashboard), 
                label: localizationService.t('dashboard')
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings), 
                label: localizationService.t('settingsTab')
              ),
            ],
            type: BottomNavigationBarType.fixed,
          );
        },
      ),
    );
  }
}
