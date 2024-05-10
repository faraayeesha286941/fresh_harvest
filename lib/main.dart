import 'package:flutter/material.dart';
import 'package:fresh_harvest/screen/persistent_bottom_nav.dart';
import 'package:fresh_harvest/screen/splashscreen.dart';
import 'package:fresh_harvest/screen/middlescreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(), // Set SplashScreen as home
      routes: {
        '/middleScreen': (context) => MiddleScreen(),
'/home': (context) => PersistentBottomNav(),

      },
    );
  }
}
