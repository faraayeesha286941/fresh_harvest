import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_harvest/appconfig/myconfig.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String initialUsername = '';
  String initialEmail = '';

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');

    if (userEmail != null) {
      var url = Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/userprofile.php');
      var response = await http.post(url, body: {
        'email': userEmail,
      });

      if (response.statusCode == 200) {
  var jsonResponse = response.body;
  if (jsonResponse.startsWith('success')) {
    jsonResponse = jsonResponse.substring('success'.length);
    // Print the modified jsonResponse for debugging
    print('Modified jsonResponse: $jsonResponse');

    var data = json.decode(jsonResponse);
    // Print the data for debugging
    print('Decoded data: $data');

    setState(() {
      initialUsername = data['username'] ?? ''; // Use empty string if null
      initialEmail = data['email'] ?? ''; // Use empty string if null
      _usernameController.text = data['username'] ?? '';
      _emailController.text = data['email'] ?? '';
      _loading = false;
    });
  } else {
    // Handle case where the response does not start with 'success'
    setState(() {
      _loading = false;
    });
  }
} else {
  // Handle non-200 status codes
  setState(() {
    _loading = false;
  });
}
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';

    var url = Uri.parse('${MyConfig().SERVER}/fresh_harvest/php/update_profile.php');
    var response = await http.post(url, body: {
      'user_id': userId,
      'username': _usernameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    });

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['message'] == 'Profile updated successfully') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.blue,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text('Update Profile'),
                  ),
                ],
              ),
            ),
    );
  }
}
