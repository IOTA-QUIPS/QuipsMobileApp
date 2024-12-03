import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'chat_page.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    await _loadCurrentUser();
    await _loadPhoneContacts();
    setState(() => _isLoading = false);
  }

  Future<void> _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');
    if (token != null) {
      final response = await AuthService().getUserInfo(token);
      if (mounted) {
        currentUserId = response?['id'].toString();
      }
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
    // Obtener contactos almacenados en caché
    List<dynamic> cachedContacts = await _getCachedContacts();

    // Solicitar permiso de contactos
    await requestContactsPermission();

    // Obtener contactos del dispositivo
    List<String> phoneContacts = await getPhoneContacts();

    // Normalizar números locales
    List<String> normalizedPhoneContacts = phoneContacts.map((number) {
      String cleanedNumber = number.replaceAll(RegExp(r'[()\s-]'), '');
      if (cleanedNumber.length == 9 && !cleanedNumber.startsWith('+51')) {
        cleanedNumber = '+51$cleanedNumber';
      }
      return cleanedNumber;
    }).toList();

    // Llamar a la API con números normalizados
    final registeredContacts = await chatApiService.getRegisteredContacts(normalizedPhoneContacts);

    if (registeredContacts != null && registeredContacts.isNotEmpty) {
      for (var contact in registeredContacts) {
        String normalizedPhoneNumber = contact['phoneNumber'].replaceAll(RegExp(r'[()\s-]'), '');
        if (normalizedPhoneNumber.length == 9 && !normalizedPhoneNumber.startsWith('+51')) {
          normalizedPhoneNumber = '+51$normalizedPhoneNumber';
        }
        contact['displayName'] = phoneContactNames[normalizedPhoneNumber] ?? contact['phoneNumber'];
      }

      await _cacheContacts(registeredContacts);
      _contactsFuture = Future.value(registeredContacts);
    } else {
      _contactsFuture = Future.value(cachedContacts);
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
        String normalizedPhone = phone.value!.replaceAll(RegExp(r'[()\s-]'), '');

        if (normalizedPhone.length == 9 && !normalizedPhone.startsWith('+51')) {
          normalizedPhone = '+51$normalizedPhone';
        }

        phoneNumbers.add(normalizedPhone);

        // Agregar al mapa con el nombre agendado
        phoneContactNames[normalizedPhone] = contact.displayName ?? '';
      }
    }

    print("Contactos almacenados en phoneContactNames: $phoneContactNames");
    return phoneNumbers;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.teal))
          : Column(
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
                      final contactName = contact['displayName'] ?? contact['phoneNumber'];
                      final phoneNumber = contact['phoneNumber'];

                      if (contact['id'].toString() == currentUserId) {
                        return SizedBox.shrink();
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/default_avatar.png'),
                        ),
                        title: Text(contactName), // Mostrar el nombre agendado
                        subtitle: Text(phoneNumber), // Mostrar el número
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                senderId: currentUserId!,
                                receiverId: contact['id'].toString(),
                                senderUsername: 'You',
                                receiverUsername: contactName,
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
