import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ChatApiService {
  final String baseUrl;
  late StompClient stompClient;
  bool isConnected = false;

  ChatApiService({this.baseUrl = 'https://quips-backend-production.up.railway.app/api'});

  // Inicializar STOMP con manejo de reconexión
  void initializeStomp(String senderId, String receiverId, Function onMessageReceived) {
    print("Iniciando STOMP con senderId: $senderId y receiverId: $receiverId");
    try {
      stompClient = StompClient(
        config: StompConfig(
          url: 'wss://quips-backend-production.up.railway.app/chat', // WebSocket seguro sin puerto
          onConnect: (StompFrame frame) {
            isConnected = true;
            print("STOMP conectado exitosamente con frame: ${frame.headers}");
            _subscribeToConversation(senderId, receiverId, onMessageReceived);
          },
          onStompError: (dynamic error) {
            print("STOMP Error: $error");
            _handleReconnect(senderId, receiverId, onMessageReceived);
          },
          onWebSocketError: (dynamic error) {
            print("WebSocket Error: $error");
            _handleReconnect(senderId, receiverId, onMessageReceived);
          },
          onDisconnect: (frame) {
            print("Desconectado de STOMP.");
            isConnected = false;
          },
        ),
      );
      stompClient.activate();
    } catch (e) {
      print("Excepción al inicializar STOMP: $e");
      _handleReconnect(senderId, receiverId, onMessageReceived);
    }
  }

  // Método para manejar reconexión en caso de error
  void _handleReconnect(String senderId, String receiverId, Function onMessageReceived) {
    if (!isConnected) {
      Future.delayed(Duration(seconds: 3), () {
        print("Intentando reconectar STOMP...");
        initializeStomp(senderId, receiverId, onMessageReceived);
      });
    }
  }

  // Suscribirse a la conversación específica
  void _subscribeToConversation(String senderId, String receiverId, Function onMessageReceived) {
    print("Intentando suscribirse a la conversación entre $senderId y $receiverId");
    try {
      stompClient.subscribe(
        destination: '/topic/messages/$senderId/$receiverId',
        callback: (frame) {
          print("Mensaje recibido en la suscripción: ${frame.body}");
          if (frame.body != null) {
            var data = jsonDecode(frame.body!);
            onMessageReceived(data);
          }
        },
      );
      print("Suscripción exitosa a la conversación entre $senderId y $receiverId");
    } catch (e) {
      print("Error en la suscripción a la conversación: $e");
    }
  }

  // Enviar mensaje a través de STOMP
  void sendMessage(String conversationId, String senderId, String receiverId, String content) {
    print("Intentando enviar mensaje a través de STOMP con datos:");
    print("Conversation ID: $conversationId, Sender ID: $senderId, Receiver ID: $receiverId, Content: $content");
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
      _handleReconnect(senderId, receiverId, (_) {}); // Intentar reconectar si falla
    }
  }

  // Cerrar STOMP
  void deactivateStomp() {
    print("Intentando desactivar STOMP...");
    try {
      stompClient.deactivate();
      isConnected = false;
      print("STOMP desactivado correctamente.");
    } catch (e) {
      print("Error al desactivar STOMP: $e");
    }
  }

  // Crear o obtener conversación
  Future<Map<String, dynamic>?> createOrGetConversation(String user1Id, String user2Id) async {
    print("Intentando crear o recuperar conversación entre $user1Id y $user2Id");
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/conversation?user1Id=$user1Id&user2Id=$user2Id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print("Respuesta de la solicitud de conversación: ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Error al crear o recuperar la conversación'};
      }
    } catch (e) {
      print("Excepción al crear o recuperar la conversación: $e");
      return {'error': 'Excepción en la solicitud de conversación'};
    }
  }

  // Enviar mensaje HTTP
  Future<Map<String, dynamic>?> sendMessageHttp(String conversationId, String senderId, String receiverId, String content) async {
    print("Enviando mensaje HTTP con Conversation ID: $conversationId, Sender ID: $senderId, Receiver ID: $receiverId");
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

      print("Respuesta al enviar mensaje HTTP: ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Error al enviar el mensaje'};
      }
    } catch (e) {
      print("Excepción al enviar el mensaje a través de HTTP: $e");
      return {'error': 'Excepción en la solicitud de envío de mensaje'};
    }
  }

  // Obtener mensajes de una conversación
  Future<List<dynamic>?> getConversationMessages(String conversationId) async {
    print("Obteniendo mensajes de la conversación $conversationId");
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/conversation/$conversationId/messages'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print("Respuesta de obtener mensajes: ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("Excepción al obtener los mensajes de la conversación: $e");
      return null;
    }
  }

  // Obtener todos los usuarios
  Future<List<dynamic>?> getAllUsers() async {
    print("Obteniendo todos los usuarios");
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print("Respuesta de obtener todos los usuarios: ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print("Excepción al obtener todos los usuarios: $e");
      return null;
    }
  }

  // Obtener información del usuario autenticado
  Future<Map<String, dynamic>?> getMyUserInfo(String token) async {
    print("Obteniendo información del usuario autenticado con token: $token");
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print("Respuesta de obtener información del usuario: ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Error al obtener la información del usuario'};
      }
    } catch (e) {
      print("Excepción al obtener la información del usuario: $e");
      return {'error': 'Excepción en la solicitud de información del usuario'};
    }
  }

  // Verificar contactos registrados
  Future<List<dynamic>> getRegisteredContacts(List<String> phoneNumbers) async {
    print("Verificando contactos registrados: $phoneNumbers");
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/contacts/check'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(phoneNumbers),
      );

      print("Respuesta de verificación de contactos: ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener contactos registrados');
      }
    } catch (e) {
      print("Excepción al obtener contactos registrados: $e");
      throw Exception('Excepción en la solicitud de contactos registrados');
    }
  }
}
