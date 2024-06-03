import 'package:flutter/material.dart';

class MyProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('This is the My Products screen'),
      ),
    );
  }
}
