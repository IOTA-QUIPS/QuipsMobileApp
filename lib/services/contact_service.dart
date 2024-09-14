import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestContactsPermission() async {
  if (await Permission.contacts.request().isGranted) {
    // Permiso otorgado, puedes acceder a los contactos
  } else {
    // Permiso denegado
    openAppSettings(); // Abre la configuración de la app si el permiso es denegado
  }
}

Future<List<String>> getPhoneContacts() async {
  Iterable<Contact> contacts = await ContactsService.getContacts();
  List<String> phoneNumbers = [];

  for (var contact in contacts) {
    for (var phone in contact.phones!) {
      phoneNumbers.add(phone.value!);
    }
  }
  return phoneNumbers;
}
