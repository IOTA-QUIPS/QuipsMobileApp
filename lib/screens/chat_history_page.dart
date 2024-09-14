import 'package:flutter/material.dart';

class ChatHistoryPage extends StatelessWidget {
  final List<Map<String, String>> chatHistory = [
    {'contact': 'User1', 'lastMessage': 'Hello!'},
    {'contact': 'User2', 'lastMessage': 'How are you?'},
    {'contact': 'User3', 'lastMessage': 'See you soon!'}
  ]; // Lista de chats previos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat History')),
      body: ListView.builder(
        itemCount: chatHistory.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(chatHistory[index]['contact']!),
            subtitle: Text(chatHistory[index]['lastMessage']!),
            onTap: () {
              // Navegar al chat con el contacto seleccionado
              Navigator.pushNamed(
                context,
                '/chat',
                arguments: {
                  'senderUsername': 'currentUser',  // Usuario actual
                  'receiverUsername': chatHistory[index]['contact'],  // Contacto del historial
                },
              );
            },
          );
        },
      ),
    );
  }
}
