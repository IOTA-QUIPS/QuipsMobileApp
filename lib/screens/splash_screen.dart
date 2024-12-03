import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login_page.dart';
import 'auth/pin_login_page.dart'; // Importar la pantalla de ingreso con PIN

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwtToken');
      String? pin = prefs.getString('sixDigitPin');

      // Agrega un pequeño retraso (opcional) para que el splash sea más visible
      await Future.delayed(Duration(seconds: 1));

      // Si el token y la clave de 6 dígitos están presentes, redirigir a PinLoginPage
      if (token != null && pin != null && pin.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PinLoginPage(),
          ),
        );
      } else {
        // Si no hay token o clave, redirigir a la pantalla de login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      }
    } catch (e) {
      // En caso de error, redirigir al login e imprimir el error
      print('Error al verificar el estado de sesión: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Puedes agregar un logo o una imagen aquí
            FlutterLogo(size: 100), // Logo de ejemplo, puedes cambiarlo por tu propio logo
            SizedBox(height: 20),
            CircularProgressIndicator(), // Muestra un indicador de carga
          ],
        ),
      ),
    );
  }
}
