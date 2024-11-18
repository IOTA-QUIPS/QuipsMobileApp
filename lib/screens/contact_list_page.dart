import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  final ChatApiService chatApiService = ChatApiService();
  Future<List<dynamic>?>? _contactsFuture;
  String? currentUserId;
  Map<String, String> phoneContactNames = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadPhoneContacts(); // Cargar contactos al iniciar la pantalla
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

  // Función para guardar contactos en caché
  Future<void> _cacheContacts(List<dynamic> contacts) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cachedContacts', jsonEncode(contacts));
  }

  // Función para obtener contactos desde la caché
  Future<List<dynamic>> _getCachedContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? contactsString = prefs.getString('cachedContacts');
    if (contactsString != null) {
      return jsonDecode(contactsString);
    }
    return [];
  }

  // Función principal para cargar contactos desde la caché y actualizar desde la API
  Future<void> _loadPhoneContacts() async {
    // Cargar contactos desde la caché primero
    List<dynamic> cachedContacts = await _getCachedContacts();
    if (cachedContacts.isNotEmpty) {
      setState(() {
        _contactsFuture = Future.value(cachedContacts);
      });
    }

    // Solicitar permisos y cargar contactos del dispositivo
    await requestContactsPermission();
    List<String> phoneContacts = await getPhoneContacts();

    // Llamada a la API para obtener los contactos registrados
    final registeredContacts = await chatApiService.getRegisteredContacts(phoneContacts);

    // Verificar si se recibieron contactos registrados antes de almacenarlos en caché
    if (registeredContacts != null) {
      // Guardar los contactos en caché para futuras cargas rápidas
      await _cacheContacts(registeredContacts);
    }

    // Llenar el mapa de nombres de contactos con los nombres del dispositivo
    for (var contact in await ContactsService.getContacts()) {
      for (var phone in contact.phones!) {
        String normalizedPhone = phone.value!.replaceAll(RegExp(r'\s+'), '');
        phoneContactNames[normalizedPhone] = contact.displayName ?? '';
      }
    }

    // Actualizar la UI con los contactos más recientes si `registeredContacts` no es nulo
    if (registeredContacts != null) {
      setState(() {
        _contactsFuture = Future.value(registeredContacts);
      });
    } else {
      // Si `registeredContacts` es nulo, mostrar los contactos de la caché o vacíos
      setState(() {
        _contactsFuture = Future.value(cachedContacts);
      });
    }
  }

  // Función para solicitar permisos de contacto
  Future<void> requestContactsPermission() async {
    PermissionStatus status = await Permission.contacts.status;
    if (!status.isGranted) {
      await Permission.contacts.request();
    }
  }

  // Función para obtener los contactos del teléfono
  Future<List<String>> getPhoneContacts() async {
    List<String> phoneNumbers = [];
    Iterable<Contact> contacts = await ContactsService.getContacts();
    for (var contact in contacts) {
      for (var phone in contact.phones!) {
        String normalizedPhone = phone.value!.replaceAll(RegExp(r'\s+'), '');
        phoneNumbers.add(normalizedPhone);
        phoneContactNames[normalizedPhone] = contact.displayName ?? '';
      }
    }
    return phoneNumbers;
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.contactList),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>?>(
          future: _contactsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.amber[300]));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error al cargar contactos', style: TextStyle(color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay usuarios disponibles', style: TextStyle(color: Colors.white)));
            } else {
              final contacts = snapshot.data!;
              return ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  final phoneNumber = contact['phoneNumber'];
                  final contactName = phoneContactNames[phoneNumber] ?? phoneNumber; // Mostrar número si no hay nombre

                  if (contact['id'].toString() == currentUserId) {
                    return SizedBox.shrink(); // No mostrar al usuario actual
                  }

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    color: Colors.grey[900],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      title: Text(contactName, style: TextStyle(color: Colors.white)),
                      subtitle: Text(phoneNumber, style: TextStyle(color: Colors.grey[400])),
                      onTap: () async {
                        Navigator.pushNamed(
                          context,
                          '/chat',
                          arguments: {
                            'senderUsername': localizations.you,
                            'receiverUsername': contactName,
                            'senderId': currentUserId!,
                            'receiverId': contact['id'].toString(),
                          },
                        );
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
