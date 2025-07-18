import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _onThemeChanged(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '¿Cuánto Falta?',
      theme: ThemeData(primarySwatch: Colors.orange),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: HomePage(themeMode: _themeMode, onThemeChanged: _onThemeChanged),
      debugShowCheckedModeBanner: false,
    );
  }
}
