// middlescreen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mainscreen.dart';
import 'package:fresh_harvest/screen/buyer/userregistration.dart';
import 'package:fresh_harvest/screen/buyer/userlogin.dart';

class MiddleScreen extends StatefulWidget {
  @override
  _MiddleScreenState createState() => _MiddleScreenState();
}

class _MiddleScreenState extends State<MiddleScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (isLoggedIn) {
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    // Handle not logged in scenario, maybe navigate to login page again or show message.
    print("User is not logged in.");
  }
}

  clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegistrationPage())),
              child: Text("Register?"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginPage())),
              child: Text("Log In"),
            ),
            ElevatedButton(
              onPressed: () {
                clearSharedPreferences();
              },
              child: Text("Debug: Clear SharedPreferences"),
            ),
          ],
        ),
      ),
    );
  }
}
