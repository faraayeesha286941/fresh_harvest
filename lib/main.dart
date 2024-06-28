import 'package:flutter/material.dart';
import 'package:fresh_harvest/screen/persistent_bottom_nav.dart';
import 'package:fresh_harvest/screen/splashscreen.dart';
import 'package:fresh_harvest/screen/middlescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_harvest/screen/seller/seller_dashboard.dart';
import 'package:fresh_harvest/screen/seller/my_products_screen.dart';
import 'package:fresh_harvest/screen/seller/ongoing_orders_screen.dart';
import 'package:fresh_harvest/screen/seller/past_orders_screen.dart';
import 'package:fresh_harvest/screen/seller/admindashboard.dart'; // Import AdminDashboard
import 'package:fresh_harvest/screen/seller/productview.dart'; // Import ProductView

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String currentInterface = prefs.getString('currentInterface') ?? 'buyer';
  runApp(MyApp(isLoggedIn: isLoggedIn, currentInterface: currentInterface));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String currentInterface;
  MyApp({required this.isLoggedIn, required this.currentInterface});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: isLoggedIn 
          ? (currentInterface == 'buyer' ? PersistentBottomNav() : SellerDashboard())
          : SplashScreen(),
      routes: {
        '/middleScreen': (context) => MiddleScreen(),
        '/home': (context) => currentInterface == 'buyer' ? PersistentBottomNav() : SellerDashboard(),
        '/myProducts': (context) => MyProductsScreen(),
        '/ongoingOrders': (context) => OngoingOrdersScreen(),
        '/pastOrders': (context) => PastOrdersScreen(),
        '/adminDashboard': (context) => AdminDashboard(), // Add AdminDashboard route
        '/productView': (context) => ProductView(), // Add ProductView route
      },
    );
  }
}
