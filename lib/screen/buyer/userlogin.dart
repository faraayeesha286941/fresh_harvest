import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:fresh_harvest/appconfig/myconfig.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
  if (jsonResponse.startsWith('success')) {
    jsonResponse = jsonResponse.substring('success'.length);
    var data = json.decode(jsonResponse);
    // Save user data here
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Replace 'userEmail' with the actual data you want to save. For example:
    await prefs.setString('userEmail', data['email']); // Assuming 'email' is a key returned by your API
    Fluttertoast.showToast(msg: data['message']);
  } else {
    Fluttertoast.showToast(msg: 'Error logging in');
  }
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
