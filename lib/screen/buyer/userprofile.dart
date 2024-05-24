import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fresh_harvest/appconfig/myconfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String firstName = '';
  String lastName = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');

    if (userEmail != null) {
      var url = Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/userregistration.php');
      var response = await http.post(url, body: {
        'email': userEmail,  // Include the email parameter in the request
      });

      if (response.statusCode == 200) {
        var jsonResponse = response.body;
        print(jsonResponse);
        if (!jsonResponse.contains("Email parameter missing") && !jsonResponse.contains("User not found")) {
          if (jsonResponse.startsWith('success')) {
            jsonResponse = jsonResponse.substring('success'.length);
            var data = json.decode(jsonResponse);
            setState(() {
              firstName = data['first_name'];
              lastName = data['last_name'];
              email = data['email'];
            });
          }
        } else {
          print(jsonResponse);
        }
      } else {
        // Handle other status codes or errors
        print('Server error: ${response.statusCode}');
      }
    } else {
      print('Email not found in SharedPreferences');
      // Perhaps navigate to login screen or show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Center(  // Center the content
        child: SingleChildScrollView(  // Ensures content is scrollable
          padding: const EdgeInsets.all(16.0),  // Add padding around content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,  // Center the column content vertically
            crossAxisAlignment: CrossAxisAlignment.center,  // Center the column content horizontally
            children: <Widget>[
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/user_avatar.png'),
              ),
              const SizedBox(height: 20),
              Text('First Name: $firstName'),
              Text('Last Name: $lastName'),
              Text('Email: $email'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/editprofile.dart');
                },
                child: const Text('Edit Profile'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/sellerregistration.dart');
                },
                child: const Text('Want to become a seller?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}