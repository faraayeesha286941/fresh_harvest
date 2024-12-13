import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String receiverId;

  ChatPage({required this.userId, required this.receiverId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Admin'),
        backgroundColor: Colors.blue[800],
      ),
      body: Center(
        child: Text('Chat Page'),
      ),
    );
  }
}
