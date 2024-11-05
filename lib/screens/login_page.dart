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
    var localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Image.asset(
                'assets/isotipo.png', // Ajusta la ruta según tu configuración
                height: 100,
              ),
              SizedBox(height: 20),
              Text(
                localizations.welcomeBack,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[300],
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  hintText: localizations.email,
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.email, color: Colors.amber[300]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  hintText: localizations.password,
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.lock, color: Colors.amber[300]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.amber[300]))
                  : ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = '';
                  });

                  final response = await _authService.login(
                    _usernameController.text,
                    _passwordController.text,
                  );

                  setState(() {
                    _isLoading = false;
                  });

                  if (response != null && response.containsKey('error')) {
                    setState(() {
                      _errorMessage = response['error'];
                    });
                  } else if (response != null && response.containsKey('token')) {
                    final token = response['token'];
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('jwtToken', token);

                    final userInfo = await _authService.getUserInfo(token);

                    if (userInfo != null && userInfo.containsKey('sixDigitPin')) {
                      final String? sixDigitPin = userInfo['sixDigitPin'];
                      if (sixDigitPin != null && sixDigitPin.isNotEmpty) {
                        await prefs.setString('sixDigitPin', sixDigitPin);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SetPinPage(token),
                          ),
                        );
                        return;
                      }
                    }

                    if (userInfo != null && userInfo.containsKey('roles')) {
                      final roles = userInfo['roles'];
                      if (roles.contains('ROLE_ADMIN')) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminHome(token),
                          ),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      }
                    } else {
                      setState(() {
                        _errorMessage = localizations.errorFetchingUserInfo;
                      });
                    }
                  }
                },
                child: Text(localizations.login),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.amber[300],
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text(
                  localizations.dontHaveAccountSignUp,
                  style: TextStyle(color: Colors.amber[300]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}