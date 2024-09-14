import 'package:flutter/material.dart';
import 'package:quipsapp/services/auth_service.dart'; // Agrega el servicio de autenticación
import 'package:shared_preferences/shared_preferences.dart';
import 'package:contacts_service/contacts_service.dart'; // Paquete para obtener los contactos
import 'package:permission_handler/permission_handler.dart'; // Paquete para solicitar permisos
import '../services/chat_service.dart'; // Para manejar las interacciones con el backend

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
    _loadCurrentUser();  // Cargar el usuario logueado
    _loadPhoneContacts();  // Cargar contactos del teléfono y filtrar los registrados
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

  // Método para obtener contactos del teléfono y filtrarlos por los que están registrados
  Future<void> _loadPhoneContacts() async {
    try {
      // Pedir permisos y obtener contactos del teléfono
      await requestContactsPermission();
      List<String> phoneContacts = await getPhoneContacts();

      // Enviar los contactos al backend para obtener solo los registrados
      final registeredContacts = await chatApiService.getRegisteredContacts(phoneContacts); // Aquí envías la lista de contactos al backend

      setState(() {
        _contactsFuture = Future.value(registeredContacts);  // Solo contactos registrados
      });
    } catch (e) {
      print('Error al cargar contactos del teléfono: $e');
    }
  }

  // Pedir permiso para acceder a los contactos del teléfono
  Future<void> requestContactsPermission() async {
    if (await Permission.contacts.request().isGranted) {
      // Permiso otorgado, puedes acceder a los contactos
    } else {
      // Permiso denegado
      openAppSettings(); // Abre la configuración de la app si el permiso es denegado
    }
  }

  // Obtener contactos del teléfono
  Future<List<String>> getPhoneContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    List<String> phoneNumbers = [];

    for (var contact in contacts) {
      for (var phone in contact.phones!) {
        phoneNumbers.add(phone.value!);
      }
    }
    return phoneNumbers;
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
