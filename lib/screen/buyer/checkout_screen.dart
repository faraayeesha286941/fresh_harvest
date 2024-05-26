import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Image.asset('assets/QR.jpg'), // Ensure QR.jpg is in the assets folder and listed in pubspec.yaml
      ),
    );
  }
}
