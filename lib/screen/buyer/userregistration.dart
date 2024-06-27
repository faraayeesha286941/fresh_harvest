import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:fresh_harvest/appconfig/myconfig.dart';

void main() {
  runApp(const MaterialApp(
    home: RegistrationPage(),
  ));
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

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
  bool isLoading = false;

  void registerUser() async {
    setState(() {
      isLoading = true;
    });

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

    setState(() {
      isLoading = false;
    });

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Registration'),
        backgroundColor: Colors.blue[800],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Create an Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
              const SizedBox(height: 20),
              buildTextField('First Name', firstNameController),
              buildTextField('Last Name', lastNameController),
              buildTextField('Username', usernameController),
              buildTextField('Email Address', emailController),
              buildTextField('Password', passwordController, obscureText: true),
              buildTextField('Re-type Password', retypePasswordController, obscureText: true),
              const SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        if (passwordController.text == retypePasswordController.text) {
                          registerUser();
                        } else {
                          Fluttertoast.showToast(msg: 'Passwords do not match');
                        }
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
                      child: const Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.blue[50],
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            ),
          ),
        ],
      ),
    );
  }
}
