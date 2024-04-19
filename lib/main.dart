import 'package:flutter/material.dart';
import 'package:fresh_harvest/screen/splashscreen.dart';
import 'package:fresh_harvest/screen/mainscreen.dart';
import 'package:fresh_harvest/screen/persistent_bottom_nav.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/persistentBottomNav': (context) => PersistentBottomNav(),
      },
    );
  }
}
