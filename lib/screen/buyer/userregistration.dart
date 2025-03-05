import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:intl/intl.dart';
import 'userlogin.dart';  // Ensure this import is correct based on your project structure

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

    final DatabaseReference counterRef = FirebaseDatabase.instance.ref().child('user_counter');
    final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('db_user');

    // Get the current user counter
    DataSnapshot counterSnapshot = await counterRef.get();
    int userCounter = (counterSnapshot.value ?? 0) as int;

    // Increment the counter for the new user
    userCounter++;

    String hashedPassword = BCrypt.hashpw(passwordController.text, BCrypt.gensalt());
    String currentDate = DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now());

    await usersRef.child(userCounter.toString()).set({
      'first_name': firstNameController.text,
      'last_name': lastNameController.text,
      'username': usernameController.text,
      'email': emailController.text,
      'password': hashedPassword,
      'user_id': userCounter,
      'account_type': 'Buyer',
      'date_reg': currentDate,
    });

    // Update the counter in the database
    await counterRef.set(userCounter);

    setState(() {
      isLoading = false;
    });

    Fluttertoast.showToast(msg: 'User registered successfully');

    // Navigate to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
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
