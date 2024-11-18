import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:quipsapp/screens/start_chat_page.dart';
import '../services/chat_service.dart';
import '../services/contact_service.dart';
import 'chat_page.dart';
import 'dart:convert';

class ChatListPage extends StatefulWidget {
  final String userId;

  ChatListPage({required this.userId});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late ChatApiService chatApiService;
  List<dynamic> _conversations = [];
  List<dynamic> _filteredConversations = [];
  Map<String, String> contactNames = {}; // Mapa de números normalizados a nombres de contactos
  final TextEditingController _searchController = TextEditingController();
  bool contactsLoaded = false; // Verificador de carga de contactos

  @override
  void initState() {
    super.initState();
    chatApiService = ChatApiService();
    _initializeContactsAndConversations();
    _searchController.addListener(_filterConversations);
  }

  Future<void> _initializeContactsAndConversations() async {
    await _loadPhoneContacts(); // Asegurar que contactos estén cargados
    contactsLoaded = true;
    _loadConversations();
  }

  Future<void> _loadPhoneContacts() async {
    await requestContactsPermission();

    for (var contact in await ContactsService.getContacts()) {
      for (var phone in contact.phones!) {
        String normalizedPhone = _normalizePhoneNumber(phone.value!);
        contactNames[normalizedPhone] = contact.displayName ?? '';
      }
    }
    print("Contactos almacenados en contactNames: $contactNames");
  }

  String _normalizePhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'^\+51|\D+'), '');
  }

  Future<void> _loadConversations() async {
    final response = await chatApiService.getUserConversations(widget.userId);
    if (response != null) {
      setState(() {
        _conversations = response;
      });
    }
    _filterConversations();
  }

  void _filterConversations() {
    if (!contactsLoaded) return;

    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredConversations = _conversations.where((conversation) {
        final isGroup = conversation['isGroup'] ?? false;
        String name = 'Usuario sin nombre';

        if (isGroup) {
          name = conversation['groupName'] ?? 'Grupo sin nombre';
        } else {
          List<dynamic> participants = conversation['participants'] ?? [];
          String? phoneNumber;
          for (var participant in participants) {
            if (participant['user']?['id'].toString() != widget.userId) {
              phoneNumber = participant['user']?['phoneNumber'];
              break;
            }
          }

          if (phoneNumber != null) {
            final normalizedPhone = _normalizePhoneNumber(phoneNumber);
            name = contactNames[normalizedPhone] ?? normalizedPhone;
          }
        }

        return name.toLowerCase().contains(query);
      }).toList();
    });
  }

  String formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('hh:mm a').format(dateTime);
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
        title: Text('Chats'),
        backgroundColor: Colors.teal[800],
        actions: [
          IconButton(
            icon: Icon(Icons.group_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StartChatPage()),
              );
            },
            tooltip: "Crear grupo",
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadConversations,
            tooltip: "Actualizar",
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
                hintText: "Buscar chats...",
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
          Expanded(
            child: _filteredConversations.isNotEmpty
                ? ListView.builder(
              itemCount: _filteredConversations.length,
              itemBuilder: (context, index) {
                final conversation = _filteredConversations[index];
                final isGroup = conversation['isGroup'] ?? false;
                String name = 'Usuario sin nombre';

                if (isGroup) {
                  name = conversation['groupName'] ?? 'Grupo sin nombre';
                } else {
                  List<dynamic> participants = conversation['participants'] ?? [];
                  String? phoneNumber;
                  for (var participant in participants) {
                    if (participant['user']?['id'].toString() != widget.userId) {
                      phoneNumber = participant['user']?['phoneNumber'];
                      break;
                    }
                  }

                  if (phoneNumber != null) {
                    final normalizedPhone = _normalizePhoneNumber(phoneNumber);
                    name = contactNames[normalizedPhone] ?? normalizedPhone;
                  }
                }

                final lastMessageContent = (conversation['messages']?.isNotEmpty ?? false)
                    ? conversation['messages'].last['content'] ?? 'No hay mensajes'
                    : 'No hay mensajes';
                final lastMessageTimestamp = (conversation['messages']?.isNotEmpty ?? false)
                    ? formatTimestamp(conversation['messages'].last['timestamp'])
                    : '';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(isGroup ? Icons.group : Icons.person),
                  ),
                  title: Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    lastMessageContent,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    lastMessageTimestamp,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    print("Intentando abrir conversación...");
                    print("Sender ID: ${widget.userId}");

                    // Encuentra al otro participante
                    String? receiverId;
                    String receiverName = 'Usuario sin nombre';
                    List<dynamic> participants = conversation['participants'] ?? [];
                    for (var participant in participants) {
                      if (participant['user']?['id'].toString() != widget.userId) {
                        receiverId = participant['user']?['id'].toString();

                        // Obtener el número de teléfono del receptor
                        String? phoneNumber = participant['user']?['phoneNumber'];
                        if (phoneNumber != null) {
                          String normalizedPhone = _normalizePhoneNumber(phoneNumber);
                          receiverName = contactNames[normalizedPhone] ?? normalizedPhone;
                        }
                        break;
                      }
                    }

                    print("Receiver ID: $receiverId");
                    print("Receiver Name: $receiverName");

                    // Validar si el `receiverId` es igual al `senderId`
                    if (receiverId == widget.userId) {
                      print("Error: Intento de crear una conversación entre el mismo usuario (${widget.userId})");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("No puedes crear una conversación contigo mismo")),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          senderId: widget.userId,
                          receiverId: receiverId!,
                          senderUsername: 'You',
                          receiverUsername: receiverName,
                        ),
                      ),
                    );
                  },
                );
              },
            )
                : Center(
              child: Text(
                "No se encontraron conversaciones",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
