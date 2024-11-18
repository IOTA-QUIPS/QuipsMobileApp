import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'chat_page.dart'; // Asegúrate de importar ChatPage aquí

class StartChatPage extends StatefulWidget {
  @override
  _StartChatPageState createState() => _StartChatPageState();
}

class _StartChatPageState extends State<StartChatPage> {
  final TextEditingController _searchController = TextEditingController();
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

  Future<void> _cacheContacts(List<dynamic> contacts) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cachedContacts', jsonEncode(contacts));
  }

  Future<List<dynamic>> _getCachedContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? contactsString = prefs.getString('cachedContacts');
    if (contactsString != null) {
      return jsonDecode(contactsString);
    }
    return [];
  }

  Future<void> _loadPhoneContacts() async {
    List<dynamic> cachedContacts = await _getCachedContacts();
    if (cachedContacts.isNotEmpty) {
      setState(() {
        _contactsFuture = Future.value(cachedContacts);
      });
    }

    await requestContactsPermission();
    List<String> phoneContacts = await getPhoneContacts();
    final registeredContacts = await chatApiService.getRegisteredContacts(phoneContacts);

    if (registeredContacts != null) {
      await _cacheContacts(registeredContacts);
    }

    for (var contact in await ContactsService.getContacts()) {
      for (var phone in contact.phones!) {
        String normalizedPhone = phone.value!.replaceAll(RegExp(r'\s+'), '');
        phoneContactNames[normalizedPhone] = contact.displayName ?? '';
      }
    }

    if (registeredContacts != null) {
      setState(() {
        _contactsFuture = Future.value(registeredContacts);
      });
    } else {
      setState(() {
        _contactsFuture = Future.value(cachedContacts);
      });
    }
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
        phoneContactNames[normalizedPhone] = contact.displayName ?? '';
      }
    }
    return phoneNumbers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New chat"),
        backgroundColor: Colors.teal[800],
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search name or number",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(Icons.group, color: Colors.teal),
                  title: Text("New group"),
                  onTap: () {
                    // Acción para crear un grupo
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person_add, color: Colors.teal),
                  title: Text("New contact"),
                  onTap: () {
                    // Acción para añadir un nuevo contacto
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
              future: _contactsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Colors.teal));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar contactos', style: TextStyle(color: Colors.red)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No contacts available', style: TextStyle(color: Colors.grey)));
                } else {
                  final contacts = snapshot.data!;
                  return ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      final phoneNumber = contact['phoneNumber'];
                      final contactName = phoneContactNames[phoneNumber] ?? phoneNumber;

                      if (contact['id'].toString() == currentUserId) {
                        return SizedBox.shrink();
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/default_avatar.png'),
                        ),
                        title: Text(contactName),
                        subtitle: Text(phoneNumber),
                        onTap: () {
                          // Navegar a ChatPage con la información adecuada
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                senderId: currentUserId!, // ID del usuario actual
                                receiverId: contact['id'].toString(), // ID del contacto seleccionado
                                senderUsername: 'You', // Nombre del usuario actual
                                receiverUsername: contactName, // Nombre del contacto seleccionado
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
