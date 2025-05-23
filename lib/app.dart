// app.dart - App configuration

import 'package:flutter/material.dart';
import 'screens/note_entry_screen.dart';
import 'config/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme, 
      themeMode: ThemeMode.system, // Respects system theme
      home: const NoteEntryScreen(),
    );
  }
}