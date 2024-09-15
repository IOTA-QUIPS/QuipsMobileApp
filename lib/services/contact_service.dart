import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

/// Solicitar permisos para acceder a los contactos del teléfono.
Future<void> requestContactsPermission() async {
  try {
    // Verificar si el permiso ya está concedido
    PermissionStatus status = await Permission.contacts.status;

    if (!status.isGranted) {
      // Solicitar el permiso si aún no ha sido concedido
      status = await Permission.contacts.request();
    }

    // Verificar el estado del permiso
    if (status.isGranted) {
      print('Permiso de contactos otorgado.');
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // Si el permiso es denegado, abre la configuración de la app
      print('Permiso de contactos denegado. Solicitando que abra la configuración.');
      openAppSettings();
    }
  } catch (e) {
    print('Error al solicitar el permiso de contactos: $e');
    throw Exception('Error al solicitar permisos para los contactos');
  }
}



/// Obtener los números de teléfono de los contactos almacenados en el dispositivo.
Future<List<String>> getPhoneContacts() async {
  Iterable<Contact> contacts = await ContactsService.getContacts();
  List<String> phoneNumbers = [];

  for (var contact in contacts) {
    for (var phone in contact.phones!) {
      // Eliminar espacios en blanco y otros caracteres no numéricos
      String normalizedPhone = phone.value!.replaceAll(RegExp(r'\s+'), '');
      phoneNumbers.add(normalizedPhone);
    }
  }

  // Imprimir contactos para depuración
  print("Contactos normalizados obtenidos del teléfono: $phoneNumbers");

  return phoneNumbers;
}
