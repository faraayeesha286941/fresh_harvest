import 'package:flutter/material.dart';

class OngoingOrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Orders'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('This is the Ongoing Orders screen'),
      ),
    );
  }
}
