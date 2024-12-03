import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import '../../services/chat_service.dart';
import 'transaction_amount_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactListTransactionPage extends StatefulWidget {
  @override
  _ContactListTransactionPageState createState() =>
      _ContactListTransactionPageState();
}

class _ContactListTransactionPageState
    extends State<ContactListTransactionPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> appContacts = [];
  List<Map<String, dynamic>> filteredContacts = [];
  Map<String, String> deviceContactNames = {};
  bool isLoading = true;
  String? currentUserPhoneNumber;
  final ChatApiService chatApiService = ChatApiService();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      await _loadCurrentUserPhoneNumber();
      if (await Permission.contacts.request().isGranted) {
        await _getDeviceContactNames();
        List<String> phoneNumbers = deviceContactNames.keys.toList();
        List<dynamic>? registeredContacts =
        await chatApiService.getRegisteredContacts(phoneNumbers);
        if (registeredContacts != null) {
          setState(() {
            appContacts = registeredContacts.map((contact) {
              String phone = contact['phoneNumber'];
              String normalizedPhone =
              phone.replaceAll(RegExp(r'[()\s-]'), '');
              if (normalizedPhone.length == 9 &&
                  !normalizedPhone.startsWith('+51')) {
                normalizedPhone = '+51$normalizedPhone';
              }
              String displayName =
                  deviceContactNames[normalizedPhone] ?? phone;
              return {
                "name": displayName,
                "phone": phone,
                "accountNumber": contact['accountNumber'],
                "fullName": "${contact['firstName']} ${contact['lastName']}",
              };
            }).where((contact) {
              return contact["phone"] != currentUserPhoneNumber;
            }).toList();
            filteredContacts = appContacts;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("Permiso de contactos denegado.");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error al cargar los contactos: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadCurrentUserPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserPhoneNumber = prefs.getString('phoneNumber');
    print("[LOG] Current user phone number: $currentUserPhoneNumber");
  }

  Future<void> _getDeviceContactNames() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    for (var contact in contacts) {
      for (var phone in contact.phones!) {
        String normalizedPhone =
        phone.value!.replaceAll(RegExp(r'[()\s-]'), '');
        if (normalizedPhone.length == 9 &&
            !normalizedPhone.startsWith('+51')) {
          normalizedPhone = '+51$normalizedPhone';
        }
        String displayName = (contact.givenName ?? '') +
            (contact.familyName != null ? ' ${contact.familyName}' : '');
        deviceContactNames[normalizedPhone] = displayName.trim();
      }
    }
  }

  void _filterContacts(String query) {
    setState(() {
      filteredContacts = appContacts
          .where((contact) =>
      contact["name"]!.toLowerCase().contains(query.toLowerCase()) ||
          contact["phone"]!.contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seleccionar Contacto"),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Barra de búsqueda personalizada
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              keyboardType: TextInputType.phone, // Teclado numérico
              style: TextStyle(fontSize: 18), // Tamaño del texto
              decoration: InputDecoration(
                hintText: "Ingresa número o nombre...",
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterContacts('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: _filterContacts,
            ),
          ),
          // Lista de contactos filtrados
          Expanded(
            child: ListView.builder(
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = filteredContacts[index];
                return ListTile(
                  title: Text(contact["name"]!,
                      style: TextStyle(fontSize: 16)),
                  subtitle: Text(contact["phone"]!,
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionAmountPage(
                          receiverName: contact["fullName"]!,
                          receiverPhone: contact["phone"]!,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
