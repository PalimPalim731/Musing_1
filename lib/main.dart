// main.dart - Application entry point

import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  // Initialize any required services/plugins
  WidgetsFlutterBinding.ensureInitialized();
  
  // Error handling for uncaught exceptions
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Could add logger or crash reporting here
  };
  
  runApp(const MyApp());
}