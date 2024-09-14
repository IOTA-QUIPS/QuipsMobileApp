import 'package:flutter/material.dart';
import 'package:quipsapp/services/auth_service.dart'; // Agrega el servicio de autenticación
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chat_service.dart'; // Para manejar el token

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  final ChatApiService chatApiService = ChatApiService();
  final AuthService authService = AuthService();
  Future<List<dynamic>?>? _contactsFuture;
  String? currentUserId;  // Para almacenar el ID del usuario actual
  String? currentUsername; // Para almacenar el nombre del usuario actual

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();  // Cargar el usuario logeado
    _contactsFuture = chatApiService.getAllUsers();  // Cargar todos los usuarios disponibles
  }

  // Método para obtener el usuario logeado desde el token
  Future<void> _loadCurrentUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwtToken');  // Obtener el token almacenado

      if (token != null) {
        // Llamada al servicio de autenticación para obtener la información del usuario
        final response = await authService.getUserInfo(token);
        if (response != null && !response.containsKey('error')) {
          setState(() {
            currentUserId = response['id'].toString();
            currentUsername = response['username'];
            print('Usuario actual cargado correctamente: $currentUsername ($currentUserId)');
          });
        } else {
          print('Error al obtener la información del usuario actual');
        }
      } else {
        // Manejar el caso donde no hay token disponible
        print('No se encontró el token, redirigiendo al login');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('Error al cargar el usuario logeado: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contact List")),
      body: FutureBuilder<List<dynamic>?>(  // Mostrar contactos con FutureBuilder
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error al cargar contactos: ${snapshot.error}');
            return Center(child: Text('Error al cargar contactos'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('No hay usuarios disponibles');
            return Center(child: Text('No hay usuarios disponibles'));
          } else {
            final contacts = snapshot.data!;
            print('Usuarios cargados correctamente: $contacts');
            return ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                if (contact['id'].toString() == currentUserId) {
                  return SizedBox.shrink();  // No mostrar al usuario actual
                }
                return ListTile(
                  title: Text("${contact['firstName']} ${contact['lastName']}"),
                  subtitle: Text(contact['username']),
                  onTap: () async {
                    try {
                      print('Iniciando conversación con ${contact['username']}');
                      final result = await chatApiService.createOrGetConversation(
                          currentUserId!, contact['id'].toString());

                      if (result != null && result.containsKey('id')) {
                        print('Conversación creada/obtenida con éxito. Navegando al chat...');
                        // Aquí es donde agregas el Navigator.pushNamed
                        Navigator.pushNamed(
                          context,
                          '/chat',
                          arguments: {
                            'senderUsername': currentUsername!,  // Nombre del usuario actual
                            'receiverUsername': contact['username'],
                            'conversationId': result['id'].toString(),
                            'senderId': currentUserId!,
                            'receiverId': contact['id'].toString(),
                          },
                        );
                      } else {
                        print('Error al crear o recuperar la conversación: $result');
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al crear o recuperar la conversación'))
                        );
                      }
                    } catch (e) {
                      print('Error al intentar abrir el chat: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al intentar abrir el chat: $e'))
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
