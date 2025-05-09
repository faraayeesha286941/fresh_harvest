import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminMessagingPage extends StatefulWidget {
  @override
  _AdminMessagingPageState createState() => _AdminMessagingPageState();
}

class _AdminMessagingPageState extends State<AdminMessagingPage> {
  List<User> users = [];
  User? selectedUser;
  List<Message> messages = [];
  late DatabaseReference usersRef;
  late DatabaseReference messagesRef;
  StreamSubscription<DatabaseEvent>? usersSubscription;
  StreamSubscription<DatabaseEvent>? messagesSubscription;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    usersRef = FirebaseDatabase.instance.ref().child('db_user');
    messagesRef = FirebaseDatabase.instance.ref().child('messages');
    _fetchUsers();
  }

  @override
  void dispose() {
    usersSubscription?.cancel();
    messagesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    DataSnapshot snapshot = await usersRef.get();
    print('Users event: ${snapshot.value}'); // Debug log

    if (snapshot.exists) {
      List<User> fetchedUsers = [];

      if (snapshot.value is List) {
        List<dynamic> usersList = snapshot.value as List<dynamic>;
        fetchedUsers = usersList.where((value) => value != null).map((value) {
          Map<String, dynamic> userJson = Map<String, dynamic>.from(value as Map);
          return User.fromJson(userJson);
        }).toList();
      } else if (snapshot.value is Map) {
        Map<dynamic, dynamic> usersMap = snapshot.value as Map<dynamic, dynamic>;
        fetchedUsers = usersMap.values.where((value) => value != null).map((value) {
          Map<String, dynamic> userJson = Map<String, dynamic>.from(value as Map);
          return User.fromJson(userJson);
        }).toList();
      }

      setState(() {
        users = fetchedUsers;
      });

      // Filter users who have sent a message to the admin
      await _fetchMessagesForUsers(fetchedUsers);
    }
  }

  Future<void> _fetchMessagesForUsers(List<User> allUsers) async {
    DataSnapshot snapshot = await messagesRef.get();
    print('Messages event: ${snapshot.value}'); // Debug log

    if (snapshot.exists) {
      List<String> userIds = [];

      if (snapshot.value is List) {
        List<dynamic> messagesList = snapshot.value as List<dynamic>;
        messagesList.where((value) => value != null).forEach((value) {
          Map<String, dynamic> messageJson = Map<String, dynamic>.from(value as Map);
          if (messageJson['receiver_id'] == '1' || messageJson['sender_id'] == '1') {
            String otherUserId = messageJson['receiver_id'] == '1'
                ? messageJson['sender_id'].toString()
                : messageJson['receiver_id'].toString();
            userIds.add(otherUserId);
          }
        });
      } else if (snapshot.value is Map) {
        Map<dynamic, dynamic> messagesMap = snapshot.value as Map<dynamic, dynamic>;
        messagesMap.values.where((value) => value != null).forEach((value) {
          Map<String, dynamic> messageJson = Map<String, dynamic>.from(value as Map);
          if (messageJson['receiver_id'] == '1' || messageJson['sender_id'] == '1') {
            String otherUserId = messageJson['receiver_id'] == '1'
                ? messageJson['sender_id'].toString()
                : messageJson['receiver_id'].toString();
            userIds.add(otherUserId);
          }
        });
      }

      setState(() {
        users = allUsers.where((user) => userIds.contains(user.id)).toList();
      });
    }
  }

  Future<void> _fetchMessages(String userId) async {
    DataSnapshot snapshot = await messagesRef.get();
    print('Messages event: ${snapshot.value}'); // Debug log

    if (snapshot.exists) {
      List<Message> fetchedMessages = [];

      if (snapshot.value is List) {
        List<dynamic> messagesList = snapshot.value as List<dynamic>;
        fetchedMessages = messagesList.where((value) => value != null).map((value) {
          Map<String, dynamic> messageJson = Map<String, dynamic>.from(value as Map);
          return Message.fromJson(messageJson);
        }).toList();
      } else if (snapshot.value is Map) {
        Map<dynamic, dynamic> messagesMap = snapshot.value as Map<dynamic, dynamic>;
        fetchedMessages = messagesMap.values.where((value) => value != null).map((value) {
          Map<String, dynamic> messageJson = Map<String, dynamic>.from(value as Map);
          return Message.fromJson(messageJson);
        }).toList();
      }

      setState(() {
        messages = fetchedMessages.where((message) =>
            (message.senderId == userId && message.receiverId == '1') ||
            (message.senderId == '1' && message.receiverId == userId)).toList();
      });
    }
  }

  Future<void> _sendMessage(String message) async {
    String timestamp = DateTime.now().toIso8601String();
    DatabaseReference newMessageRef = messagesRef.push();
    await newMessageRef.set({
      'sender_id': '1', // Admin's user ID
      'receiver_id': selectedUser!.id,
      'message': message,
      'timestamp': timestamp,
    });
    _controller.clear();
    _fetchMessages(selectedUser!.id);
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
                              bool isSender = message.senderId == '1';
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
      id: json['user_id'].toString(),
      name: '${json['first_name']} ${json['last_name']}',
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
      senderId: json['sender_id'].toString(),
      receiverId: json['receiver_id'].toString(),
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }
}
