import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatApiService {
  final String baseUrl = 'http://10.0.2.2:8080/api'; // Base URL para todas las peticiones

  // Crear o recuperar una conversación entre dos usuarios
  Future<Map<String, dynamic>?> createOrGetConversation(String user1Id, String user2Id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/conversation?user1Id=$user1Id&user2Id=$user2Id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error al crear o recuperar la conversación. Código: ${response.statusCode}');
      print('Detalles del error: ${response.body}');
      return {'error': 'Error al crear o recuperar la conversación'};
    }
  }

  // Enviar un mensaje en una conversación existente
  Future<Map<String, dynamic>?> sendMessage(String conversationId, String senderId, String receiverId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/sendMessage'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'conversationId': conversationId,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error al enviar el mensaje: ${response.statusCode} - ${response.body}');
      return {'error': 'Error al enviar el mensaje'};
    }
  }

  // Obtener los mensajes de una conversación
  Future<List<dynamic>?> getConversationMessages(String conversationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/conversation/$conversationId/messages'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // Obtener todos los usuarios disponibles para chatear
  Future<List<dynamic>?> getAllUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // Obtener la información del usuario autenticado (si se necesita para otros casos)
  Future<Map<String, dynamic>?> getMyUserInfo(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'error': 'Error al obtener la información del usuario'};
    }
  }

  // Aquí agregamos el método faltante para obtener contactos registrados
  // Obtener solo los contactos que están registrados en la app
  Future<List<dynamic>> getRegisteredContacts(List<String> phoneNumbers) async {
    final response = await http.post(
      Uri.parse('$baseUrl/contacts/check'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(phoneNumbers), // Enviamos la lista de contactos en formato JSON
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);  // Devuelve la lista de contactos registrados
    } else {
      print('Error al obtener contactos registrados: ${response.statusCode} - ${response.body}');
      throw Exception('Error al obtener contactos registrados');
    }
  }
}
