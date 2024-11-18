import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quipsapp/services/auth_service.dart';
import '../admin/admin_home.dart';
import 'home_page.dart';
import 'set_pin_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailOrUsernameController = TextEditingController();
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
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo con animación de desvanecimiento
              AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(seconds: 2),
                child: Image.asset(
                  'assets/isotipo.png',
                  height: 120,
                ),
              ),
              SizedBox(height: 24),

              // Título con sombra sutil
              Text(
                "Quip!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.amber[300],
                  shadows: [
                    Shadow(
                      offset: Offset(0, 4),
                      blurRadius: 10,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Campo de texto para el email o username
              _buildTextField(
                controller: _emailOrUsernameController,
                hintText: localizations.emailOrUsername,
                icon: Icons.person,
              ),
              SizedBox(height: 16),

              // Campo de texto para la contraseña
              _buildTextField(
                controller: _passwordController,
                hintText: localizations.password,
                icon: Icons.lock,
                obscureText: true,
              ),
              SizedBox(height: 24),

              // Botón de login con animación y sombra
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.amber[300]))
                  : ElevatedButton(
                onPressed: _login,
                child: Text(localizations.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[300],
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  shadowColor: Colors.amber[100],
                  elevation: 8,
                ),
              ),
              SizedBox(height: 20),

              // Mensaje de error
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: 24),

              // Enlace para registrarse
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text(
                  localizations.dontHaveAccountSignUp,
                  style: TextStyle(
                    color: Colors.amber[300],
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.amber[300]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[900],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final response = await _authService.login(
      _emailOrUsernameController.text,
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
          var localizations = AppLocalizations.of(context)!;
          _errorMessage = localizations.errorFetchingUserInfo;
        });
      }
    }
  }
}
