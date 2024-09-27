import 'package:flutter/material.dart';
import '../services/chat_service.dart';  // Servicio de API HTTP para el chat

class ChatPage extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String senderUsername;
  final String receiverUsername;  // Ahora este será el nombre recuperado del teléfono

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
  }

  Future<void> _initializeConversation() async {
    final response = await chatApiService.createOrGetConversation(
      widget.senderId,
      widget.receiverId,
    );

    if (response != null && !response.containsKey('error')) {
      setState(() {
        conversationId = response['id'].toString();  // Guardar el ID de la conversación
        _loadMessages();  // Cargar los mensajes previos
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
          _messages = messagesResponse
              .map<String>((msg) => "${widget.receiverUsername}: ${msg['content']}")
              .toList();
        });
      } else {
        print('Error al cargar los mensajes');
      }
    }
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty && conversationId != null) {
      final response = await chatApiService.sendMessage(
        conversationId!,
        widget.senderId,
        widget.receiverId,
        _controller.text,
      );

      if (response != null && !response.containsKey('error')) {
        setState(() {
          _messages.add('${widget.senderUsername}: ${_controller.text}');
        });
        _controller.clear();  // Limpiar el campo de entrada de texto
      } else {
        print('Error al enviar el mensaje');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.receiverUsername}'),  // Mostramos el nombre del contacto del teléfono
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isSender = _messages[index].startsWith(widget.senderUsername);
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
                    decoration: InputDecoration(
                      hintText: 'Enter a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
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
