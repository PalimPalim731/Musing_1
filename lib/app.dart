// app.dart - App configuration with theme management

import 'package:flutter/material.dart';
import 'screens/note_entry_screen.dart';
import 'config/theme/app_theme.dart';
import 'services/theme_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    // Listen to theme changes
    _themeService.themeStream.listen((_) {
      setState(() {
        // Rebuild app when theme changes
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeService.currentThemeMode,
      home: const NoteEntryScreen(),
    );
  }
}
