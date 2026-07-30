import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

/// Root widget of the Lifemate application.
/// Sets up MaterialApp with the Lifemate theme and navigation.
class LifemateApp extends StatelessWidget {
  const LifemateApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Keep status bar icons dark on light background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Lifemate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}
