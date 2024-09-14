import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatApiService {
  final String baseUrl = 'http://10.0.2.2:8080/api'; // Base URL para todas las peticiones

  // Crear o recuperar una conversación entre dos usuarios
  Future<Map<String, dynamic>?> createOrGetConversation(String user1Id, String user2Id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/conversation?user1Id=$user1Id&user2Id=$user2Id'), // Enviar parámetros como query
      headers: {
        'Content-Type': 'application/json; charset=UTF-8', // No es necesario un body en este caso
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);  // Regresa la conversación creada o recuperada
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
      return jsonDecode(response.body);  // Regresa el mensaje enviado
    } else {
      print('Error al enviar el mensaje: ${response.statusCode} - ${response.body}');
      return {'error': 'Error al enviar el mensaje'};
    }
  }

  // Obtener los mensajes de una conversación
  Future<List<dynamic>?> getConversationMessages(String conversationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/conversation/$conversationId/messages'), // Cambiado a la ruta correcta
      headers: {
        'Content-Type': 'application/json; charset=UTF-8', // Formato JSON
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);  // Regresa la lista de mensajes
    } else {
      return null;  // Manejar error
    }
  }

  // Obtener todos los usuarios disponibles para chatear
  Future<List<dynamic>?> getAllUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),  // Usar el endpoint correcto para obtener todos los usuarios
      headers: {
        'Content-Type': 'application/json; charset=UTF-8', // Formato JSON
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);  // Regresa la lista de usuarios disponibles
    } else {
      return null;  // Manejar error
    }
  }

  // Obtener la información del usuario autenticado (si se necesita para otros casos)
  Future<Map<String, dynamic>?> getMyUserInfo(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'), // Endpoint para obtener información del usuario actual
      headers: {
        'Authorization': 'Bearer $token', // Incluir el token en la cabecera
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);  // Regresa la información del usuario
    } else {
      return {'error': 'Error al obtener la información del usuario'};
    }
  }
}
