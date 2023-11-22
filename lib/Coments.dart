import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'main.dart';

class Coments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Komentarze',
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _getMessages();
    _checkForUpdates();
  }

  Future<void> _getMessages() async {
    final user = 'user_id'; // ID aktualnego użytkownika
    final admin = 'admin_id'; // ID administratora

    final querySender = QueryBuilder(ParseObject('Message'))
      ..whereEqualTo('senderId', user)
      ..whereEqualTo('receiverId', admin);

    final queryReceiver = QueryBuilder(ParseObject('Message'))
      ..whereEqualTo('senderId', admin)
      ..whereEqualTo('receiverId', user);

    try {
      final responseSender = await querySender.query();
      final responseReceiver = await queryReceiver.query();

      setState(() {
        final List<dynamic> senderMessages = responseSender.results ?? [];
        final List<dynamic> receiverMessages = responseReceiver.results ?? [];

        final List<dynamic> allMessages = [];
        allMessages.addAll(senderMessages);
        allMessages.addAll(receiverMessages);

        allMessages.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));

        _messages = allMessages.map<Map<String, dynamic>>((message) {
          return {
            'text': message['text'] as String,
            'senderId': message['senderId'] as String,
          };
        }).toList();
      });
    } catch (e) {
      print('Error getting messages: $e');
    }
  }

  Future<void> _sendMessage(String message) async {
    final user = 'user_id'; // ID aktualnego użytkownika
    final admin = 'admin_id'; // ID administratora

    final newMessage = ParseObject('Message')
      ..set('text', message)
      ..set('senderId', user)
      ..set('receiverId', admin);

    try {
      await newMessage.save();
      _getMessages();
    } catch (e) {
      print('Error sending message: $e');
    }
  }
  Future<void> _checkForUpdates() async {
    while (true) {
      await Future.delayed(Duration(seconds: 10)); // Oczekiwanie 1 sekundy

      try {
        final user = 'user_id'; // ID aktualnego użytkownika
        final admin = 'admin_id'; // ID administratora

        final querySender = QueryBuilder(ParseObject('Message'))
          ..whereEqualTo('senderId', user)
          ..whereEqualTo('receiverId', admin);

        final queryReceiver = QueryBuilder(ParseObject('Message'))
          ..whereEqualTo('senderId', admin)
          ..whereEqualTo('receiverId', user);

        final responseSender = await querySender.query();
        final responseReceiver = await queryReceiver.query();

        final List<dynamic> senderMessages = responseSender.results ?? [];
        final List<dynamic> receiverMessages = responseReceiver.results ?? [];

        final List<dynamic> allMessages = [];
        allMessages.addAll(senderMessages);
        allMessages.addAll(receiverMessages);

        allMessages.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));

        setState(() {
          _messages = allMessages.map<Map<String, dynamic>>((message) {
            return {
              'text': message['text'] as String,
              'senderId': message['senderId'] as String,
            };
          }).toList();
        });
      } catch (e) {
        print('Error checking for updates: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messenger Chat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                final message = _messages[index];
                final isUser = message['senderId'] == 'user_id';

                return Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${message['senderId']}',
                      style: TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                    Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Divider(height: 1.0),
          Container(
            margin: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String message = _messageController.text;
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                      _messageController.clear();
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