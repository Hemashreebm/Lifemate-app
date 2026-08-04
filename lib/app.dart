import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_screen.dart';
import 'screens/welcome_auth_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

/// Root widget of the Lifemate application.
/// Sets up MaterialApp with the original Lifemate white theme and Auto-Login router.
class LifemateApp extends StatelessWidget {
  const LifemateApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      themeMode: ThemeMode.light,
      home: FutureBuilder<void>(
        future: AuthService.instance.init(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFFF8FAFC),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('💖', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 16),
                    CircularProgressIndicator(color: Color(0xFF7C3AED)),
                  ],
                ),
              ),
            );
          }

          if (AuthService.instance.isLoggedIn) {
            return const MainScreen();
          } else {
            return const WelcomeAuthScreen();
          }
        },
      ),
    );
  }
}
