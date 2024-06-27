import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fresh_harvest/appconfig/myconfig.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'upload_documents.dart'; // Import the new page
import 'purchases_screen.dart'; // Import PurchasesScreen
import 'package:fresh_harvest/screen/shared/edit_profile_screen.dart'; // Import EditProfileScreen
import 'package:fresh_harvest/screen/seller/seller_dashboard.dart'; // Import SellerDashboard
import 'package:fresh_harvest/screen/persistent_bottom_nav.dart'; // Import PersistentBottomNav

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String accountType = '';
  bool loading = true;

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
        'email': userEmail,  // Include the email parameter in the request
      });

      if (response.statusCode == 200) {
        var jsonResponse = response.body;
        print(jsonResponse);
        if (jsonResponse.startsWith('success')) {
          jsonResponse = jsonResponse.substring('success'.length);
          var data = json.decode(jsonResponse);
          setState(() {
            firstName = data['first_name'];
            lastName = data['last_name'];
            email = data['email'];
            accountType = data['account_type'];
            loading = false;
          });
        } else {
          setState(() {
            loading = false;
          });
        }
      } else {
        setState(() {
          loading = false;
        });
      }
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  void _switchToSellerInterface() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentInterface', 'seller');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SellerDashboard()),
    );
  }

  void _switchToBuyerInterface() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentInterface', 'buyer');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PersistentBottomNav()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.blue[800],
      ),
      body: Center(
        child: loading
            ? CircularProgressIndicator()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/user_avatar.png'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'First Name: $firstName',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Last Name: $lastName',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email: $email',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditProfileScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Edit Profile'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PurchasesScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('My Purchases'),
                    ),
                    const SizedBox(height: 20),
                    if (accountType == 'Seller') ...[
                      ElevatedButton(
                        onPressed: _switchToSellerInterface,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Switch to Seller Interface'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _switchToBuyerInterface,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Switch to Buyer Interface'),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
