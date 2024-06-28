import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_harvest/appconfig/myconfig.dart';

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
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => _fetchMessages());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    final serverUrl = MyConfig().SERVER;

    final response = await http.get(Uri.parse('$serverUrl/fresh_harvest/php/getmessages.php?user_id=${widget.userId}&receiver_id=${widget.receiverId}'));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse is List) {
        setState(() {
          messages = jsonResponse.map((data) => Message.fromJson(data)).toList();
        });
      } else {
        // Handle unexpected response format
        print('Unexpected response format: $jsonResponse');
      }
    } else {
      // Handle error
      print('Error fetching messages: ${response.statusCode}');
    }
  }

  Future<void> _sendMessage(String message) async {
    final serverUrl = MyConfig().SERVER;

    final response = await http.post(
      Uri.parse('$serverUrl/fresh_harvest/php/sendmessage.php'),
      body: {
        'sender_id': widget.userId,
        'receiver_id': widget.receiverId,
        'message': message,
      },
    );

    if (response.statusCode == 200) {
      _fetchMessages(); // Refresh messages after sending a new one
    } else {
      // Handle error
      print('Error sending message: ${response.statusCode}');
    }
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
                      _controller.clear();
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

  Message({required this.id, required this.senderId, required this.receiverId, required this.message, required this.timestamp});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }
}
