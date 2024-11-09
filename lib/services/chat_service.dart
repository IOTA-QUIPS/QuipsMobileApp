import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ChatApiService {
  final String baseUrl;
  late StompClient stompClient;

  ChatApiService({this.baseUrl = 'http://34.122.251.215:8080/api'});

  // Inicializar STOMP sin SockJS y con `ws://`
  void initializeStomp(String senderId, String receiverId, Function onMessageReceived) {
    try {
      stompClient = StompClient(
        config: StompConfig(
          url: 'ws://34.122.251.215:8080/chat', // Cambia a `ws://` para conexión WebSocket pura
          onConnect: (StompFrame frame) {
            print("STOMP conectado exitosamente.");
            _subscribeToConversation(senderId, receiverId, onMessageReceived);
          },
          onStompError: (dynamic error) => print("STOMP Error: $error"),
          onWebSocketError: (dynamic error) => print("WebSocket Error: $error"),
        ),
      );
      stompClient.activate();
    } catch (e) {
      print("Error al inicializar STOMP: $e");
    }
  }

  // Suscribirse a la conversación específica
  void _subscribeToConversation(String senderId, String receiverId, Function onMessageReceived) {
    try {
      stompClient.subscribe(
        destination: '/topic/messages/$senderId/$receiverId',
        callback: (frame) {
          if (frame.body != null) {
            var data = jsonDecode(frame.body!);
            onMessageReceived(data);
          }
        },
      );
      print("Suscripción a la conversación entre $senderId y $receiverId exitosa.");
    } catch (e) {
      print("Error en la suscripción a la conversación: $e");
    }
  }

  // Enviar mensaje a través de STOMP
  void sendMessage(String conversationId, String senderId, String receiverId, String content) {
    try {
      stompClient.send(
        destination: '/app/chat/$senderId/$receiverId',
        body: jsonEncode({
          'senderId': senderId,
          'receiverId': receiverId,
          'content': content,
          'conversationId': conversationId,
        }),
      );
      print("Mensaje enviado a la conversación $conversationId.");
    } catch (e) {
      print("Error al enviar mensaje a través de STOMP: $e");
    }
  }

  // Cerrar STOMP
  void deactivateStomp() {
    try {
      stompClient.deactivate();
      print("STOMP desactivado correctamente.");
    } catch (e) {
      print("Error al desactivar STOMP: $e");
    }
  }

  // Métodos HTTP con manejo de errores
  Future<Map<String, dynamic>?> createOrGetConversation(String user1Id, String user2Id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/conversation?user1Id=$user1Id&user2Id=$user2Id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        print("Conversación creada o recuperada exitosamente.");
        return jsonDecode(response.body);
      } else {
        print('Error al crear o recuperar la conversación. Código: ${response.statusCode}');
        print('Detalles del error: ${response.body}');
        return {'error': 'Error al crear o recuperar la conversación'};
      }
    } catch (e) {
      print("Excepción al crear o recuperar la conversación: $e");
      return {'error': 'Excepción en la solicitud de conversación'};
    }
  }

  Future<Map<String, dynamic>?> sendMessageHttp(String conversationId, String senderId, String receiverId, String content) async {
    try {
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
        print("Mensaje enviado exitosamente a través de HTTP.");
        return jsonDecode(response.body);
      } else {
        print('Error al enviar el mensaje: ${response.statusCode} - ${response.body}');
        return {'error': 'Error al enviar el mensaje'};
      }
    } catch (e) {
      print("Excepción al enviar el mensaje a través de HTTP: $e");
      return {'error': 'Excepción en la solicitud de envío de mensaje'};
    }
  }

  Future<List<dynamic>?> getConversationMessages(String conversationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/conversation/$conversationId/messages'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        print("Mensajes de la conversación obtenidos exitosamente.");
        return jsonDecode(response.body);
      } else {
        print('Error al obtener los mensajes: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print("Excepción al obtener los mensajes de la conversación: $e");
      return null;
    }
  }

  Future<List<dynamic>?> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        print("Usuarios obtenidos exitosamente.");
        return jsonDecode(response.body);
      } else {
        print('Error al obtener los usuarios: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print("Excepción al obtener todos los usuarios: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMyUserInfo(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        print("Información del usuario obtenida exitosamente.");
        return jsonDecode(response.body);
      } else {
        print('Error al obtener la información del usuario: ${response.statusCode} - ${response.body}');
        return {'error': 'Error al obtener la información del usuario'};
      }
    } catch (e) {
      print("Excepción al obtener la información del usuario: $e");
      return {'error': 'Excepción en la solicitud de información del usuario'};
    }
  }

  Future<List<dynamic>> getRegisteredContacts(List<String> phoneNumbers) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/contacts/check'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(phoneNumbers),
      );

      if (response.statusCode == 200) {
        print("Contactos registrados obtenidos exitosamente.");
        return jsonDecode(response.body);
      } else {
        print('Error al obtener contactos registrados: ${response.statusCode} - ${response.body}');
        throw Exception('Error al obtener contactos registrados');
      }
    } catch (e) {
      print("Excepción al obtener contactos registrados: $e");
      throw Exception('Excepción en la solicitud de contactos registrados');
    }
  }
}
