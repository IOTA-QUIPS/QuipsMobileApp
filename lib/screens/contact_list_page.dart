import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Para localizaciones

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

    final registeredContacts = await chatApiService.getRegisteredContacts(phoneContacts);

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
    var localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.contactList), // Título localizado
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<dynamic>?>( // FutureBuilder para cargar contactos
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
                  final contactName = phoneContactNames[phoneNumber] ?? phoneNumber;

                  if (contact['id'].toString() == currentUserId) {
                    return SizedBox.shrink(); // No mostrar al usuario actual
                  }

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    color: Colors.grey[900],
                    child: ListTile(
                      title: Text(contactName, style: TextStyle(color: Colors.white)), // Nombre del contacto
                      subtitle: Text(phoneNumber, style: TextStyle(color: Colors.grey[400])), // Número de teléfono
                      onTap: () async {
                        Navigator.pushNamed(
                          context,
                          '/chat',
                          arguments: {
                            'senderUsername': localizations.you,  // Nombre del usuario logeado
                            'receiverUsername': contactName,  // Nombre del contacto del teléfono
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
