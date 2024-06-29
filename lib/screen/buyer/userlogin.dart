import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_harvest/screen/persistent_bottom_nav.dart';
import 'package:fresh_harvest/screen/seller/admindashboard.dart';
import 'package:bcrypt/bcrypt.dart';

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
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void loginUser() async {
    setState(() {
      isLoading = true;
    });

    String email = emailController.text;
    String password = passwordController.text;

    // Check for hardcoded admin credentials first
    if (email == 'admin@admin.com' && password == 'admin123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard()),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('db_user');
    try {
      DatabaseEvent event = await usersRef.once();
      print("Database event: ${event.snapshot.value}");

      if (event.snapshot.value != null) {
        List<dynamic> users = event.snapshot.value as List<dynamic>;
        debugPrint(users.toString());

        bool userFound = false;

        for (var user in users) {
          print('Checking user: $user');
          if (user != null && user['email'] == email && BCrypt.checkpw(password, user['password'])) {
            userFound = true;
            print('User found: $user');

            // Store user data in SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('userEmail', user['email']);
            await prefs.setString('userId', user['user_id'].toString());
            await prefs.setString('accountType', user['account_type']);
            await prefs.setBool('isLoggedIn', true);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PersistentBottomNav()),
            );
            break;
          }
        }

        if (!userFound) {
          Fluttertoast.showToast(msg: 'Invalid email or password');
          print('Invalid email or password');
        }
      } else {
        Fluttertoast.showToast(msg: 'No users found');
        print('No users found');
      }
    } catch (error) {
      Fluttertoast.showToast(msg: 'Error: $error');
      print('Error: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
                    'Email',
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
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your email',
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
                      onPressed: loginUser,
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
