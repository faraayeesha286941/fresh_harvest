import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'middlescreen.dart';
import 'mainscreen.dart';  // Ensure this is correctly imported

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    Timer(const Duration(seconds: 3), () {
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');  // Adjusted to navigate to home route
      } else {
        Navigator.pushReplacementNamed(context, '/middleScreen');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/splash.jpg'),  // Splash screen image display
      ),
    );
  }
}
