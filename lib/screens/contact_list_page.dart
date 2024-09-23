import 'package:flutter/material.dart';
import 'package:quipsapp/services/auth_service.dart'; // Agrega el servicio de autenticación
import 'package:shared_preferences/shared_preferences.dart';
import 'package:contacts_service/contacts_service.dart'; // Paquete para obtener los contactos
import 'package:permission_handler/permission_handler.dart'; // Paquete para solicitar permisos
import '../services/chat_service.dart'; // Para manejar las interacciones con el backend
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


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

        // Agrega el print aquí para verificar la respuesta
        print('Respuesta del servicio de autenticación: $response');

        if (response != null && !response.containsKey('error')) {
          setState(() {
            currentUserId = response['id'].toString();
            currentUsername = response['username'];
            print('Usuario actual cargado correctamente: $currentUsername ($currentUserId)');
          });
        } else {
          print('Error al obtener la información del usuario actual: $response');
        }
      } else {
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
      await requestContactsPermission();
      List<String> phoneContacts = await getPhoneContacts();

      // Imprimir los contactos del teléfono
      print('Contactos obtenidos del teléfono: $phoneContacts');

      // Enviar los contactos al backend para obtener solo los registrados
      final registeredContacts = await chatApiService.getRegisteredContacts(phoneContacts);

      // Imprimir los contactos registrados devueltos por el backend
      print('Contactos registrados devueltos por el backend: $registeredContacts');

      setState(() {
        _contactsFuture = Future.value(registeredContacts);
      });
    } catch (e) {
      print('Error al cargar contactos del teléfono: $e');
    }
  }

  /// Solicitar permisos para acceder a los contactos del teléfono.
  Future<void> requestContactsPermission() async {
    try {
      PermissionStatus status = await Permission.contacts.status;

      if (!status.isGranted) {
        // Solicitar el permiso si aún no ha sido concedido
        status = await Permission.contacts.request();
      }

      if (status.isGranted) {
        print('Permiso de contactos otorgado.');
      } else if (status.isDenied || status.isPermanentlyDenied) {
        print('Permiso de contactos denegado. Abriendo configuración.');
        openAppSettings(); // Abrir configuración de la app si se deniega permanentemente
      }
    } catch (e) {
      print('Error al solicitar permiso de contactos: $e');
      throw Exception('Error al solicitar permisos para los contactos');
    }
  }

  /// Obtener la ubicación actual del usuario y determinar el código de país.
  Future<String> getCountryCode() async {
    try {
      // Verificar si el permiso de ubicación está concedido
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Permiso de ubicación denegado.');
          return '+51';  // Código por defecto para Perú si no se puede obtener la ubicación
        }
      }

      // Obtener la ubicación actual del usuario (latitud y longitud)
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      print('Ubicación obtenida: ${position.latitude}, ${position.longitude}');

      // Usar el paquete 'geocoding' para obtener información sobre la ubicación
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      // Obtener el país del primer resultado
      String? country = placemarks.first.isoCountryCode;
      print('Código del país detectado: $country');

      // Usar un mapa para asociar los códigos de país a los códigos telefónicos internacionales
      Map<String, String> countryCodes = {
        'PE': '+51', // Perú
        'US': '+1',  // Estados Unidos
        'AR': '+54', // Argentina
        'CL': '+56', // Chile
        'MX': '+52', // México
        'SV': '+503', // El Salvador
        'CO': '+57', // Colombia
        // Agrega más países según sea necesario
      };

      // Retornar el código de país o un código por defecto
      return countryCodes[country] ?? '+51'; // Usar +51 si no se encuentra el país
    } catch (e) {
      print('Error al obtener la ubicación o el país: $e');
      return '+51';  // Código por defecto si algo falla
    }
  }

  /// Obtener y normalizar los números de teléfono de los contactos almacenados en el dispositivo.
  /// Se agrega el código de país dinámico si el número no tiene uno.
  Future<List<String>> getPhoneContacts() async {
    List<String> phoneNumbers = [];

    // Obtener el código de país dinámico basado en la ubicación
    String countryCode = await getCountryCode();

    try {
      Iterable<Contact> contacts = await ContactsService.getContacts();

      for (var contact in contacts) {
        for (var phone in contact.phones!) {
          // Eliminar caracteres no numéricos y espacios
          String normalizedPhone = phone.value!
              .replaceAll(RegExp(r'[^\d+]'), '');  // Mantener solo números y el símbolo '+'

          // Si el número no empieza con '+', asumimos que es un número local y agregamos el código de país dinámico
          if (!normalizedPhone.startsWith('+')) {
            normalizedPhone = '$countryCode$normalizedPhone';
          }

          phoneNumbers.add(normalizedPhone);
        }
      }

      // Imprimir contactos normalizados para depuración
      print("Contactos normalizados obtenidos del teléfono: $phoneNumbers");
    } catch (e) {
      print('Error al obtener contactos: $e');
      throw Exception('Error al obtener contactos del teléfono');
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
                    print('currentUserId: $currentUserId, contactId: ${contact['id']}');
                    if (currentUserId != null && contact['id'] != null) {
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
                    } else {
                      print('currentUserId o contactId es null, no se puede iniciar la conversación.');
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No se puede iniciar la conversación, datos incompletos.'))
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
