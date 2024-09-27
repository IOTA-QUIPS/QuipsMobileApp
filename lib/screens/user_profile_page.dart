import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quipsapp/services/auth_service.dart';
import 'package:flutter/services.dart'; // Para copiar el texto al portapapeles
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Para localizaciones

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String fullName = "Cargando...";
  String username = "Cargando...";
  String email = "Cargando...";
  String phoneNumber = "Cargando...";
  String accountNumber = "Cargando...";
  String referralCode = "Cargando...";
  double coins = 0.0;
  bool isActive = true;

  final AuthService _authService = AuthService(); // Instancia de AuthService

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token != null) {
      // Llamada a AuthService para obtener los datos del usuario
      final response = await _authService.getUserInfo(token);

      if (response != null && !response.containsKey('error')) {
        setState(() {
          fullName = response['firstName'] + " " + response['lastName'];
          username = response['username'];
          email = response['email'];
          phoneNumber = response['phoneNumber'];
          accountNumber = response['accountNumber'];
          referralCode = response['referralCode'];
          coins = response['coins'];
          isActive = response['active'];
        });
      } else {
        // Manejar error
        print('Error al cargar los datos del usuario');
      }
    } else {
      // Si no hay token, redirigir al login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener las traducciones desde el archivo de localización
    var localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profile), // Localización de "Perfil de Usuario"
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Nombre completo
            ListTile(
              leading: Icon(Icons.person),
              title: Text(fullName),
              subtitle: Text(localizations.fullName), // Localización de "Nombre Completo"
            ),
            // Username
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text(username),
              subtitle: Text(localizations.username), // Localización de "Username"
            ),
            // Correo electrónico
            ListTile(
              leading: Icon(Icons.email),
              title: Text(email),
              subtitle: Text(localizations.email), // Localización de "Correo Electrónico"
            ),
            // Teléfono
            ListTile(
              leading: Icon(Icons.phone),
              title: Text(phoneNumber),
              subtitle: Text(localizations.phoneNumber), // Localización de "Teléfono"
            ),
            // Número de cuenta
            ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text(accountNumber),
              subtitle: Text(localizations.accountNumber), // Localización de "Número de Cuenta"
            ),
            // Saldo de monedas
            ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text(coins.toString()),
              subtitle: Text(localizations.coins), // Localización de "Saldo de Monedas"
            ),
            // Código de Referencia con opción de copiar
            ListTile(
              leading: Icon(Icons.link),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(referralCode),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: referralCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.copiedToClipboard), // Localización de "Código copiado"
                        ),
                      );
                    },
                  ),
                ],
              ),
              subtitle: Text(localizations.referralCode), // Localización de "Código de Referencia"
            ),
            // Estado de la cuenta (Activa o Inactiva)
            ListTile(
              leading: Icon(isActive ? Icons.check_circle : Icons.error),
              title: Text(isActive ? localizations.active : localizations.inactive), // Localización de "Activa" o "Inactiva"
              subtitle: Text(localizations.accountStatus), // Localización de "Estado de la Cuenta"
            ),
            SizedBox(height: 20),
            // Botón para cambiar contraseña
            ElevatedButton(
              onPressed: () {
                // Acción para cambiar la contraseña
              },
              child: Text(localizations.changePassword), // Localización de "Cambiar Contraseña"
            ),
            // Botón para cerrar sesión
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('jwtToken');
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text(localizations.logOut), // Localización de "Cerrar Sesión"
            ),
          ],
        ),
      ),
    );
  }
}
