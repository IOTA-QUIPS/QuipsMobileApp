import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/chat_service.dart';  // Asume que este servicio está implementado
import '../services/auth_service.dart'; // Asume que este servicio está implementado

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  final ChatApiService chatApiService = ChatApiService(); // Servicio del backend para contactos
  final AuthService authService = AuthService(); // Servicio para autenticación
  Future<List<dynamic>?>? _contactsFuture;
  String? currentUserId;
  String? currentUsername;
  Map<String, String> phoneContactNames = {}; // Almacenar nombres locales con el número normalizado

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();  // Cargar el usuario logueado
    _loadPhoneContacts();  // Cargar contactos del teléfono y filtrarlos por los registrados
  }

  // Cargar usuario logueado desde el token
  Future<void> _loadCurrentUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwtToken');  // Obtener token almacenado

      if (token != null) {
        final response = await authService.getUserInfo(token);
        if (response != null && !response.containsKey('error')) {
          setState(() {
            currentUserId = response['id'].toString();
            currentUsername = response['username'];
          });
        } else {
          print('Error al obtener el usuario: $response');
        }
      } else {
        print('No se encontró token, redirigiendo al login');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('Error al cargar el usuario logueado: $e');
    }
  }

  // Obtener contactos del teléfono y filtrarlos por los registrados
  Future<void> _loadPhoneContacts() async {
    try {
      await requestContactsPermission();
      List<Contact> phoneContacts = (await ContactsService.getContacts()).toList();

      for (var contact in phoneContacts) {
        for (var phone in contact.phones!) {
          String normalizedPhone = phone.value!.replaceAll(RegExp(r'[^\d+]'), '');
          if (!normalizedPhone.startsWith('+')) {
            normalizedPhone = '+51' + normalizedPhone; // Código de país predeterminado
          }
          phoneContactNames[normalizedPhone] = contact.displayName ?? 'Desconocido';
        }
      }

      // Enviar los contactos normalizados al backend para obtener los registrados
      final registeredContacts = await chatApiService.getRegisteredContacts(phoneContactNames.keys.toList());

      setState(() {
        _contactsFuture = Future.value(registeredContacts);
      });
    } catch (e) {
      print('Error al cargar los contactos: $e');
    }
  }

  // Solicitar permiso para acceder a los contactos
  Future<void> requestContactsPermission() async {
    PermissionStatus status = await Permission.contacts.status;
    if (!status.isGranted) {
      status = await Permission.contacts.request();
    }
    if (status.isDenied || status.isPermanentlyDenied) {
      openAppSettings(); // Abrir configuración si se deniega permanentemente
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
            return Center(child: Text('Error al cargar contactos'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay usuarios disponibles'));
          } else {
            final contacts = snapshot.data!;
            return ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final phoneNumber = contact['phoneNumber'];

                // Mostrar nombre de contacto local si existe
                final localName = phoneContactNames[phoneNumber] ?? contact['username'];

                // Evitar que el contacto actual (el propio usuario) se muestre
                if (contact['id'].toString() == currentUserId || phoneNumber == currentUsername) {
                  return SizedBox.shrink();  // Ocultar al usuario actual
                }

                return ListTile(
                  title: Text(localName),  // Nombre del contacto en la libreta de contactos
                  subtitle: Text(phoneNumber),
                  onTap: () {
                    // Lógica para iniciar conversación
                    if (currentUserId != null && contact['id'] != null) {
                      _startConversation(contact);
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

  // Método para iniciar conversación
  Future<void> _startConversation(dynamic contact) async {
    try {
      final result = await chatApiService.createOrGetConversation(
          currentUserId!, contact['id'].toString());

      if (result != null && result.containsKey('id')) {
        Navigator.pushNamed(
          context,
          '/chat',
          arguments: {
            'senderUsername': currentUsername!,
            'receiverUsername': contact['username'],
            'conversationId': result['id'].toString(),
            'senderId': currentUserId!,
            'receiverId': contact['id'].toString(),
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear o recuperar la conversación'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al intentar abrir el chat: $e'))
      );
    }
  }
}
