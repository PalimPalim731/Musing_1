// main.dart - Application entry point

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

void main() {
  // Initialize any required services/plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI for light mode only
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      // Status bar (top)
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Brightness.dark, // Dark icons on light background
      statusBarBrightness: Brightness.light, // For iOS

      // Navigation bar (bottom)
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.grey,
    ),
  );

  // Error handling for uncaught exceptions
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Could add logger or crash reporting here
  };

  runApp(const MyApp());
}
