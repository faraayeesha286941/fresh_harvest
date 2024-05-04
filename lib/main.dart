import 'package:flutter/material.dart';
import 'package:fresh_harvest/screen/splashscreen.dart';
import 'package:fresh_harvest/screen/persistent_bottom_nav.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/persistentBottomNav': (context) => const PersistentBottomNav(),
      },
    );
  }
}
