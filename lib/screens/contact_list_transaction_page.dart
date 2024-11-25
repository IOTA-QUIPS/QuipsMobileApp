import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import '../services/chat_service.dart'; // Importa ChatApiService
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
  List<Map<String, dynamic>> appContacts = []; // Contactos registrados en la app
  List<Map<String, dynamic>> filteredContacts = [];
  Map<String, String> deviceContactNames = {}; // Nombres agendados en el dispositivo
  bool isLoading = true;
  String? currentUserPhoneNumber; // Número de teléfono del usuario actual
  final ChatApiService chatApiService = ChatApiService(); // Instancia de ChatApiService

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  /// Cargar contactos del dispositivo y verificar cuáles están registrados en la app
  Future<void> _loadContacts() async {
    try {
      // Obtener el número de teléfono del usuario actual
      await _loadCurrentUserPhoneNumber();

      // Solicitar permisos para acceder a los contactos
      if (await Permission.contacts.request().isGranted) {
        // Obtener contactos del dispositivo y llenar `deviceContactNames`
        await _getDeviceContactNames();

        // Obtener los números de teléfono de los contactos
        List<String> phoneNumbers = deviceContactNames.keys.toList();

        // Verificar contactos registrados en la app
        List<dynamic>? registeredContacts =
        await chatApiService.getRegisteredContacts(phoneNumbers);

        // Actualizar la lista de contactos si se encuentran registros
        if (registeredContacts != null) {
          setState(() {
            appContacts = registeredContacts.map((contact) {
              String phone = contact['phoneNumber'];

              // Normalizar número antes de buscarlo en los nombres agendados
              String normalizedPhone = phone.replaceAll(RegExp(r'[()\s-]'), '');
              if (normalizedPhone.length == 9 && !normalizedPhone.startsWith('+51')) {
                normalizedPhone = '+51$normalizedPhone';
              }

              String displayName = deviceContactNames[normalizedPhone] ?? phone;

              return {
                "name": displayName, // Nombre agendado
                "phone": phone, // Teléfono
                "accountNumber": contact['accountNumber'], // Número de cuenta
                "fullName": "${contact['firstName']} ${contact['lastName']}", // Nombre registrado en la app
              };
            }).where((contact) {
              // Filtrar el contacto del propio usuario
              return contact["phone"] != currentUserPhoneNumber;
            }).toList();

            filteredContacts = appContacts; // Inicialmente mostrar todos los contactos
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false; // Manejar el caso donde no hay contactos registrados
          });
        }
      } else {
        print("Permiso de contactos denegado.");
        setState(() {
          isLoading = false; // Manejar el caso donde se deniegan los permisos
        });
      }
    } catch (e) {
      print("Error al cargar los contactos: $e");
      setState(() {
        isLoading = false; // Manejar errores en la carga de contactos
      });
    }
  }

  /// Obtener el número de teléfono del usuario logueado desde SharedPreferences
  Future<void> _loadCurrentUserPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserPhoneNumber = prefs.getString('phoneNumber'); // Este valor debe ser guardado al iniciar sesión
    print("[LOG] Current user phone number: $currentUserPhoneNumber");
  }

  /// Obtener nombres completos de contactos del dispositivo (nombre y apellido)
  Future<void> _getDeviceContactNames() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();

    for (var contact in contacts) {
      for (var phone in contact.phones!) {
        // Normalizar los números eliminando espacios y caracteres no numéricos
        String normalizedPhone = phone.value!.replaceAll(RegExp(r'[()\s-]'), '');

        // Si es un número de 9 dígitos, agregar el prefijo +51
        if (normalizedPhone.length == 9 && !normalizedPhone.startsWith('+51')) {
          normalizedPhone = '+51$normalizedPhone';
        }

        // Construir nombre completo (nombre + apellido)
        String displayName = (contact.givenName ?? '') +
            (contact.familyName != null ? ' ${contact.familyName}' : '');

        deviceContactNames[normalizedPhone] =
            displayName.trim(); // Asegurarse de eliminar espacios innecesarios
      }
    }
  }

  /// Filtrar contactos según el texto ingresado en la barra de búsqueda
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
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar contacto o número...",
                prefixIcon: Icon(Icons.search),
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
                  title: Text(contact["name"]!), // Nombre agendado
                  subtitle: Text(contact["phone"]!),
                  onTap: () {
                    // Mantener el constructor actual de TransactionAmountPage
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
