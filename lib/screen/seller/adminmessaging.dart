import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fresh_harvest/appconfig/myconfig.dart';

class AdminMessagingPage extends StatefulWidget {
  @override
  _AdminMessagingPageState createState() => _AdminMessagingPageState();
}

class _AdminMessagingPageState extends State<AdminMessagingPage> {
  List<User> users = [];
  User? selectedUser;
  List<Message> messages = [];
  Timer? timer;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final serverUrl = MyConfig().SERVER;

    final response = await http.get(Uri.parse('$serverUrl/fresh_harvest/php/getusers.php'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        users = jsonResponse.map((data) => User.fromJson(data)).toList();
      });
    } else {
      // Handle error
    }
  }

  Future<void> _fetchMessages(String userId) async {
    final serverUrl = MyConfig().SERVER;

    final response = await http.get(Uri.parse('$serverUrl/fresh_harvest/php/getmessages.php?user_id=$userId&receiver_id=3'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        messages = jsonResponse.map((data) => Message.fromJson(data)).toList();
      });
    } else {
      // Handle error
    }
  }

  Future<void> _sendMessage(String message) async {
    final serverUrl = MyConfig().SERVER;

    final response = await http.post(
      Uri.parse('$serverUrl/fresh_harvest/php/sendmessage.php'),
      body: {
        'sender_id': '3', // Admin's user ID
        'receiver_id': selectedUser!.id,
        'message': message,
      },
    );

    if (response.statusCode == 200) {
      _fetchMessages(selectedUser!.id); // Refresh messages after sending a new one
    } else {
      // Handle error
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Messaging'),
        backgroundColor: Colors.blue[800],
      ),
      body: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                return ListTile(
                  title: Text(user.name),
                  onTap: () {
                    setState(() {
                      selectedUser = user;
                      messages = [];
                    });
                    _fetchMessages(user.id);
                  },
                );
              },
            ),
          ),
          Expanded(
            flex: 5,
            child: selectedUser == null
                ? Center(child: Text('Select a user to view messages'))
                : Column(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListView.builder(
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              var message = messages[index];
                              bool isSender = message.senderId == '3';
                              return Align(
                                alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSender ? Colors.blue[800] : Colors.white,
                                    borderRadius: BorderRadius.circular(15).copyWith(
                                      bottomLeft: Radius.circular(isSender ? 15 : 0),
                                      bottomRight: Radius.circular(isSender ? 0 : 15),
                                    ),
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
          ),
        ],
      ),
    );
  }
}

class User {
  final String id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
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
