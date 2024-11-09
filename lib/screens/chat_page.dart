import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    chatApiService = ChatApiService();
    _initializeConversation();

    // Configura STOMP y define la función de recepción de mensajes
    chatApiService.initializeStomp(
      widget.senderId,
      widget.receiverId,
          (messageData) {
        setState(() {
          String sender = messageData['senderId'].toString() == widget.senderId
              ? '${widget.senderUsername} (You)'
              : widget.receiverUsername;
          _messages.add("$sender: ${messageData['content']}");
        });
      },
    );
  }

  Future<void> _initializeConversation() async {
    final response = await chatApiService.createOrGetConversation(
      widget.senderId,
      widget.receiverId,
    );

    if (response != null && !response.containsKey('error')) {
      setState(() {
        conversationId = response['id'].toString();
        _loadMessages();
      });
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

  void _sendMessage() {
    if (_controller.text.isNotEmpty && conversationId != null) {
      // Envía el mensaje a través de STOMP sin añadirlo directamente a la lista de mensajes
      chatApiService.sendMessage(
        conversationId!,
        widget.senderId,
        widget.receiverId,
        _controller.text,
      );

      // Limpia el campo de entrada después de enviar el mensaje
      _controller.clear();
    }
  }

  @override
  void dispose() {
    chatApiService.deactivateStomp();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.receiverUsername}'),
        backgroundColor: Colors.black,
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
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSender ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _messages[index],
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
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter a message',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
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
