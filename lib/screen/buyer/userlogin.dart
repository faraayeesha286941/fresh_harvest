import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:fresh_harvest/appconfig/myconfig.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_harvest/screen/persistent_bottom_nav.dart';
import 'package:fresh_harvest/screen/seller/admindashboard.dart';

void main() {
  runApp(MaterialApp(
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
  bool isLoading = false;

  void loginUser() async {
    setState(() {
      isLoading = true;
    });

    String login = loginController.text;
    String password = passwordController.text;

    // Check for hardcoded admin credentials
    if (login == 'admin' && password == 'admin123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard()),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/login_user.php'),
      body: {
        'login': login,
        'password': password,
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
        await prefs.setString('accountType', data['account_type']); // Store account_type
        await prefs.setBool('isLoggedIn', true);  // Set the isLoggedIn flag

        // Navigate to PersistentBottomNav after successful login
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PersistentBottomNav()),
        );
      } else {
        // Show error message in case of any issue
        Fluttertoast.showToast(msg: jsonDecode(jsonResponse)['message']);
      }
    } else {
      Fluttertoast.showToast(msg: 'Failed to connect to the server');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blue[800],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please login to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Username/Email',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: TextField(
                  controller: loginController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your username or email',
                    isDense: true,
                    contentPadding: EdgeInsets.all(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: TextField(
                  controller: passwordController,
                  obscureText: true, // Hide password
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your password',
                    isDense: true,
                    contentPadding: EdgeInsets.all(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        loginUser();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800], // Background color
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text('Login'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
