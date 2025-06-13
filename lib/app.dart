// app.dart - App configuration with light theme only

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
      // Only light theme - no dark theme or theme mode switching
      theme: AppTheme.lightTheme,
      home: const NoteEntryScreen(),
    );
  }
}
