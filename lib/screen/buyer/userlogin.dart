import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:fresh_harvest/appconfig/myconfig.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_harvest/screen/mainscreen.dart';

void main() {
  runApp(const MaterialApp(
    home: LoginPage(),
  ));
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void loginUser() async {
    final response = await http.post(
      Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/login_user.php'),
      body: {
        'login': loginController.text,
        'password': passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = response.body;
      print(jsonResponse);

      // Check if the response contains "success" and then parse the JSON
      if (jsonResponse.contains('success')) {
        jsonResponse = jsonResponse.replaceFirst('{"message":"success",', '');
        jsonResponse = '{' + jsonResponse; // Re-add the opening brace

        var data = jsonDecode(jsonResponse); // Decode JSON response

        // Save user data here
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', data['email']);
        await prefs.setString('userPassword', passwordController.text);
        await prefs.setString('userId', data['user_id']); // Store user_id
        await prefs.setBool('isLoggedIn', true);  // Set the isLoggedIn flag

        // Navigate to MainScreen after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        // Show error message in case of any issue
        Fluttertoast.showToast(msg: jsonDecode(jsonResponse)['message']);
      }
    } else {
      Fluttertoast.showToast(msg: 'Failed to connect to the server');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: 20.0, right: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Username/Email'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: loginController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: 20.0, right: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: passwordController,
                  obscureText: true, // Hide password
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  loginUser();
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
