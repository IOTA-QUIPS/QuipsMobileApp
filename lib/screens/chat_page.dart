import 'dart:async';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String senderUsername;
  final String receiverUsername;

  ChatPage({
    required this.senderId,
    required this.receiverId,
    required this.senderUsername,
    required this.receiverUsername,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatApiService chatApiService;
  final TextEditingController _controller = TextEditingController();
  List<String> _messages = [];
  String? conversationId;
  Timer? _messageFetchTimer;

  @override
  void initState() {
    super.initState();
    chatApiService = ChatApiService();
    _initializeConversation();
  }

  @override
  void dispose() {
    _messageFetchTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeConversation() async {
    final response = await chatApiService.createOrGetConversation(
      widget.senderId,
      widget.receiverId,
    );

    if (response != null && !response.containsKey('error')) {
      setState(() {
        conversationId = response['id'].toString();
      });
      _loadMessages();
      _startAutoRefresh();
    } else {
      print('Error al crear o recuperar la conversación');
    }
  }

  Future<void> _loadMessages() async {
    if (conversationId != null) {
      final messagesResponse = await chatApiService.getConversationMessages(conversationId!);
      if (messagesResponse != null) {
        setState(() {
          _messages = messagesResponse.map<String>((msg) {
            String sender = msg['sender']['id'].toString() == widget.senderId
                ? '${widget.senderUsername} (You)'
                : widget.receiverUsername;
            return "$sender: ${msg['content']}";
          }).toList();
        });
      } else {
        print('Error al cargar los mensajes');
      }
    }
  }

  void _startAutoRefresh() {
    _messageFetchTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _loadMessages();
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty && conversationId != null) {
      chatApiService.sendMessage(
        conversationId!,
        widget.senderId,
        widget.receiverId,
        _controller.text,
      );
      _controller.clear();
      _loadMessages(); // Refresh messages immediately after sending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 8),
            Text(widget.receiverUsername),
          ],
        ),
        backgroundColor: Colors.teal[800],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isSender = _messages[index].startsWith('${widget.senderUsername} (You)');
                return Align(
                  alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSender ? Colors.teal[400] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _messages[index].split(": ")[1], // Mostrar solo el contenido del mensaje
                      style: TextStyle(color: isSender ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.teal),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
