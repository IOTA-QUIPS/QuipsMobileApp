import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quipsapp/services/auth_service.dart';
import '../admin/admin_home.dart';
import 'home_page.dart';
import 'set_pin_page.dart'; // Importa la página para configurar la clave secreta
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Importa localizaciones

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    // Obtener las traducciones desde el archivo de localización
    var localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                localizations.welcomeBack, // Localización de "Welcome Back"
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: localizations.email, // Localización de "Email"
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: localizations.password, // Localización de "Password"
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = '';
                  });

                  // Realiza la solicitud de login y obtiene el token si es exitoso
                  final response = await _authService.login(
                    _usernameController.text,
                    _passwordController.text,
                  );

                  setState(() {
                    _isLoading = false;
                  });

                  if (response != null && response.containsKey('error')) {
                    // Muestra el mensaje de error si ocurre
                    setState(() {
                      _errorMessage = response['error'];
                    });
                  } else if (response != null && response.containsKey('token')) {
                    // Si el login es exitoso, guarda el token en SharedPreferences
                    final token = response['token'];
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('jwtToken', token);

                    // Segunda solicitud para obtener la información completa del usuario (/me)
                    final userInfo = await _authService.getUserInfo(token);

                    // Si el usuario ya configuró la clave secreta, guardarla en SharedPreferences
                    if (userInfo != null && userInfo.containsKey('sixDigitPin')) {
                      final String? sixDigitPin = userInfo['sixDigitPin'];
                      if (sixDigitPin != null && sixDigitPin.isNotEmpty) {
                        await prefs.setString('sixDigitPin', sixDigitPin);
                      } else {
                        // Si el usuario no tiene la clave secreta configurada, redirigirlo a la pantalla de configuración
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SetPinPage(token), // Redirige a SetPinPage
                          ),
                        );
                        return;
                      }
                    }

                    // Verificar los roles del usuario y redirigir
                    if (userInfo != null && userInfo.containsKey('roles')) {
                      final roles = userInfo['roles'];
                      if (roles.contains('ROLE_ADMIN')) {
                        // Redirigir al Admin Dashboard
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminHome(token),
                          ),
                        );
                      } else {
                        // Redirigir a la HomePage (usuarios normales)
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      }
                    } else {
                      // Manejar error al obtener la información del usuario
                      setState(() {
                        _errorMessage = localizations.errorFetchingUserInfo; // Localización de error
                      });
                    }
                  }
                },
                child: Text(localizations.login), // Localización de "Login"
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text(
                  localizations.dontHaveAccountSignUp, // Localización de "Don't have an account? Sign Up"
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
