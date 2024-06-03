import 'package:flutter/material.dart';

class PastOrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Orders'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('This is the Past Orders screen'),
      ),
    );
  }
}
