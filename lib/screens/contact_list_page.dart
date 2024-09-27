import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart'; // Paquete para obtener los contactos
import 'package:permission_handler/permission_handler.dart'; // Paquete para solicitar permisos
import '../services/chat_service.dart'; // Para manejar las interacciones con el backend
import '../services/auth_service.dart'; // Servicio de autenticación
import 'package:shared_preferences/shared_preferences.dart';

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  final ChatApiService chatApiService = ChatApiService();
  Future<List<dynamic>?>? _contactsFuture;
  String? currentUserId;

  Map<String, String> phoneContactNames = {};  // Mapa para almacenar los nombres de los contactos del teléfono.

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadPhoneContacts();
  }

  Future<void> _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');
    if (token != null) {
      final response = await AuthService().getUserInfo(token);
      setState(() {
        currentUserId = response?['id'].toString();
      });
    }
  }

  Future<void> _loadPhoneContacts() async {
    await requestContactsPermission();
    List<String> phoneContacts = await getPhoneContacts();

    // Enviar los contactos al backend para obtener solo los registrados
    final registeredContacts = await chatApiService.getRegisteredContacts(phoneContacts);

    // Mapeo de números de teléfono a nombres de contactos
    for (var contact in await ContactsService.getContacts()) {
      for (var phone in contact.phones!) {
        String normalizedPhone = phone.value!.replaceAll(RegExp(r'\s+'), '');
        phoneContactNames[normalizedPhone] = contact.displayName ?? '';
      }
    }

    setState(() {
      _contactsFuture = Future.value(registeredContacts);
    });
  }

  Future<void> requestContactsPermission() async {
    PermissionStatus status = await Permission.contacts.status;
    if (!status.isGranted) {
      await Permission.contacts.request();
    }
  }

  Future<List<String>> getPhoneContacts() async {
    List<String> phoneNumbers = [];
    Iterable<Contact> contacts = await ContactsService.getContacts();
    for (var contact in contacts) {
      for (var phone in contact.phones!) {
        String normalizedPhone = phone.value!.replaceAll(RegExp(r'\s+'), '');
        phoneNumbers.add(normalizedPhone);
      }
    }
    return phoneNumbers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contact List")),
      body: FutureBuilder<List<dynamic>?>(
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
                final phoneNumber = contact['phoneNumber'];  // Número de teléfono registrado
                final contactName = phoneContactNames[phoneNumber] ?? phoneNumber;  // Nombre en la lista del teléfono

                if (contact['id'].toString() == currentUserId) {
                  return SizedBox.shrink();  // No mostrar al usuario actual
                }

                return ListTile(
                  title: Text(contactName),  // Mostrar el nombre del contacto desde el teléfono
                  subtitle: Text(phoneNumber),  // Mostrar el número de teléfono
                  onTap: () async {
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {
                        'senderUsername': 'You',  // Nombre del usuario logeado
                        'receiverUsername': contactName,  // Nombre del contacto del teléfono
                        'senderId': currentUserId!,
                        'receiverId': contact['id'].toString(),
                      },
                    );
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
