import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:fresh_harvest/appconfig/myconfig.dart';

void main() {
  runApp(MaterialApp(
    home: RegistrationPage(),
  ));
}

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController retypePasswordController = TextEditingController();

  void registerUser() async {
  final response = await http.post(
    Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/register_user.php'),
    body: {
      'first_name': firstNameController.text,
      'last_name': lastNameController.text,
      'username': usernameController.text,
      'email': emailController.text,
      'password': passwordController.text,
    },
  );

  if (response.statusCode == 200) {
    // Adjusting the response to remove the 'success' text before decoding
    var jsonResponse = response.body;
    if (jsonResponse.startsWith('success')) {
      jsonResponse = jsonResponse.substring('success'.length);
    }
    // Assuming server returns a JSON object on successful registration
    var data = json.decode(jsonResponse);
    Fluttertoast.showToast(msg: data['message']);
  } else {
    Fluttertoast.showToast(msg: 'Error registering user');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registration')),
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
                  child: Text('First Name'),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: firstNameController,
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
                  child: Text('Last Name'),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: lastNameController,
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
                  child: Text('Username'),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: usernameController,
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
                  child: Text('Email Address'),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: emailController,
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
              Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: 20.0, right: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Re-type Password'),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: retypePasswordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (passwordController.text == retypePasswordController.text) {
                    registerUser();
                  } else {
                    Fluttertoast.showToast(msg: 'Passwords do not match');
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}