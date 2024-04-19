import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:fresh_harvest/appconfig/myconfig.dart';
   import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(MaterialApp(
    home: LoginPage(),
  ));
}

class LoginPage extends StatefulWidget {
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
    // Adjusting the response to remove the 'success' text before decoding
    var jsonResponse = response.body;
    print(jsonResponse);
    if (jsonResponse.startsWith('success')) {
      jsonResponse = jsonResponse.substring('success'.length);
    }
    // Assuming server returns a JSON object on successful registration
    var data = json.decode(jsonResponse);
    Fluttertoast.showToast(msg: data['message']);
  } else {
    Fluttertoast.showToast(msg: 'Error logging in');
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: 20.0, right: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Username/Email'),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: loginController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: 20.0, right: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password'),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  loginUser();
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
