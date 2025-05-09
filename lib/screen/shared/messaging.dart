import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String receiverId;

  ChatPage({required this.userId, required this.receiverId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Message> messages = [];
  late DatabaseReference messagesRef;
  late DatabaseReference counterRef;
  StreamSubscription<DatabaseEvent>? messagesSubscription;

  @override
  void initState() {
    super.initState();
    messagesRef = FirebaseDatabase.instance.ref().child('messages');
    counterRef = FirebaseDatabase.instance.ref().child('messages_counter');
    _fetchMessages();
    messagesSubscription = messagesRef.onValue.listen((event) {
      _fetchMessages();
    });
  }

  @override
  void dispose() {
    messagesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    DataSnapshot snapshot = await messagesRef.get();
    if (snapshot.exists) {
      if (snapshot.value is Map) {
        Map<dynamic, dynamic> messagesData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          messages = messagesData.entries
              .map((entry) => Message.fromJson(Map<String, dynamic>.from(entry.value)))
              .toList()
              .where((message) =>
                  (message.senderId == widget.userId && message.receiverId == widget.receiverId) ||
                  (message.senderId == widget.receiverId && message.receiverId == widget.userId))
              .toList();
        });
      } else if (snapshot.value is List) {
        List<dynamic> messagesData = snapshot.value as List<dynamic>;
        setState(() {
          messages = messagesData
              .where((entry) => entry != null)
              .map((entry) => Message.fromJson(Map<String, dynamic>.from(entry)))
              .toList()
              .where((message) =>
                  (message.senderId == widget.userId && message.receiverId == widget.receiverId) ||
                  (message.senderId == widget.receiverId && message.receiverId == widget.userId))
              .toList();
        });
      }
    } else {
      print('No messages found');
    }
  }

  Future<void> _sendMessage(String message) async {
    String timestamp = DateTime.now().toIso8601String();

    // Get the current value of messages_counter
    DataSnapshot counterSnapshot = await counterRef.get();
    int messageId = 1;
    if (counterSnapshot.exists) {
      messageId = counterSnapshot.value as int;
    }

    // Increment the messages_counter
    await counterRef.set(messageId + 1);

    // Save the new message with the incremented ID
    DatabaseReference newMessageRef = messagesRef.child(messageId.toString());
    await newMessageRef.set({
      'id': messageId.toString(),
      'sender_id': widget.userId,
      'receiver_id': widget.receiverId,
      'message': message,
      'timestamp': timestamp,
    });
    _controller.clear();
    _fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Admin'),
        backgroundColor: Colors.blue[800],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  var message = messages[index];
                  bool isSender = message.senderId == widget.userId;
                  return Align(
                    alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSender ? Colors.blue[800] : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.message,
                            style: TextStyle(
                              color: isSender ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            message.timestamp,
                            style: TextStyle(
                              color: isSender ? Colors.white70 : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Send a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: Colors.blue[50],
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Colors.blue[800],
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      receiverId: json['receiver_id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }
}
