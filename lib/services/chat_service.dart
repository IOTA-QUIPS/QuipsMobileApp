import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatApiService {
  final String baseUrl;

  ChatApiService({this.baseUrl = 'https://quips-backend-production.up.railway.app/api/chat'});

  // Crear o obtener conversación uno-a-uno
  Future<Map<String, dynamic>?> createOrGetConversation(String user1Id, String user2Id) async {
    print("Preparando solicitud para crear o recuperar conversación.");
    print("Sender ID: $user1Id");
    print("Receiver ID: $user2Id");

    try {
      final url = Uri.parse('$baseUrl/conversation?user1Id=$user1Id&user2Id=$user2Id');
      print("Solicitud a URL: $url");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print("Respuesta del servidor (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error al crear o recuperar la conversación: ${response.statusCode}");
        return {'error': 'Error al crear o recuperar la conversación: ${response.statusCode}'};
      }
    } catch (e, stacktrace) {
      print("Excepción al crear o recuperar conversación: $e");
      print("Stacktrace: $stacktrace");
      return {'error': 'Error en la solicitud de conversación: $e'};
    }
  }

  // Método para obtener los contactos registrados en el sistema
  Future<List<dynamic>?> getRegisteredContacts(List<String> phoneNumbers) async {
    print("Verificando contactos registrados: $phoneNumbers");
    try {
      final response = await http.post(
        Uri.parse('https://quips-backend-production.up.railway.app/api/contacts/check'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(phoneNumbers),
      );

      print("Respuesta de verificación de contactos: ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error al obtener contactos registrados");
        return null;
      }
    } catch (e) {
      print("Excepción al obtener contactos registrados: $e");
      return null;
    }
  }

  // Enviar mensaje
  Future<Map<String, dynamic>?> sendMessage(String conversationId, String senderId, String receiverId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sendMessage'),
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
        return {'error': 'Error al enviar el mensaje'};
      }
    } catch (e) {
      print("Error al enviar el mensaje: $e");
      return {'error': 'Error en la solicitud de mensaje'};
    }
  }

  // Obtener mensajes de una conversación
  Future<List<dynamic>?> getConversationMessages(String conversationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversation/$conversationId/messages'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)); // Asegúrate de decodificar
        return decodedResponse as List<dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print("Error al obtener mensajes: $e");
      return null;
    }
  }

  // Crear grupo
  Future<Map<String, dynamic>?> createGroup(String groupName, String creatorId, List<String> participantIds) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/createGroup'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'groupName': groupName,
          'creatorId': creatorId,
          'participantIds': participantIds,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Error al crear el grupo'};
      }
    } catch (e) {
      print("Error al crear el grupo: $e");
      return {'error': 'Error en la solicitud de creación de grupo'};
    }
  }

  // Obtener información del grupo
  Future<Map<String, dynamic>?> getGroupInfo(String groupId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/group/$groupId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Error al obtener la información del grupo'};
      }
    } catch (e) {
      print("Error al obtener la información del grupo: $e");
      return {'error': 'Error en la solicitud de información del grupo'};
    }
  }

  // Eliminar grupo
  Future<Map<String, dynamic>?> deleteGroup(String groupId, String adminId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/group/$groupId?adminId=$adminId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 204) {
        return {'message': 'Grupo eliminado exitosamente'};
      } else {
        return {'error': 'Error al eliminar el grupo'};
      }
    } catch (e) {
      print("Error al eliminar el grupo: $e");
      return {'error': 'Error en la solicitud de eliminación de grupo'};
    }
  }

  // Polling para actualizaciones de mensajes
  Future<List<dynamic>?> pollUpdates(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pollUpdates?userId=$userId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> updates = jsonDecode(response.body);
        return updates;
      } else {
        return [];
      }
    } catch (e) {
      print("Error en polling de actualizaciones: $e");
      return [];
    }
  }

  // Obtener todas las conversaciones de un usuario
  Future<List<dynamic>?> getUserConversations(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversations/$userId'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)); // Asegúrate de decodificar
        return decodedResponse as List<dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print("Error al obtener las conversaciones: $e");
      return null;
    }
  }
}
