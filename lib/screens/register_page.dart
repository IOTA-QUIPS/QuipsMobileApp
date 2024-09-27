import 'package:flutter/material.dart';
import 'package:quipsapp/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Importa localizaciones

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController(); // Controlador para el código de referido

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _acceptTerms = false; // Variable para gestionar si aceptó los términos y condiciones

  String _selectedCountryCode = '+51'; // Código por defecto (Perú)

  // Lista de códigos de país
  final List<Map<String, String>> _countryCodes = [
    {'name': 'Perú', 'code': '+51'},
    {'name': 'Colombia', 'code': '+57'},
    {'name': 'Chile', 'code': '+56'},
    {'name': 'Argentina', 'code': '+54'},
    {'name': 'USA', 'code': '+1'},
    {'name': 'Mexico', 'code': '+52'},
    {'name': 'El Salvador', 'code': '+503'},
  ];

  @override
  Widget build(BuildContext context) {
    // Obtener las traducciones desde el archivo de localización
    var localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                localizations.createAccount, // Localización de "Create Account"
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  hintText: localizations.firstName, // Localización de "First Name"
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  hintText: localizations.lastName, // Localización de "Last Name"
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: localizations.username, // Localización de "Username"
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
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
              // Selector de código de país
              DropdownButtonFormField<String>(
                value: _selectedCountryCode,
                items: _countryCodes.map((country) {
                  return DropdownMenuItem<String>(
                    value: country['code'],
                    child: Text('${country['name']} (${country['code']})'),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: localizations.selectCountry, // Localización de "Select Country"
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedCountryCode = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: localizations.phoneNumber, // Localización de "Phone Number"
                  prefixText: _selectedCountryCode + " ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Campo para el código de referido
              TextFormField(
                controller: _referralCodeController,
                decoration: InputDecoration(
                  hintText: localizations.referralCodeOptional, // Localización de "Referral Code (Optional)"
                  prefixIcon: Icon(Icons.card_giftcard),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Checkbox para aceptar los términos y condiciones
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptTerms = value!;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/terms');
                    },
                    child: Text(
                      localizations.acceptTermsAndConditions, // Localización de "I accept the terms and conditions"
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: () async {
                  if (!_acceptTerms) {
                    setState(() {
                      _errorMessage = localizations.mustAcceptTerms; // Localización de "You must accept the terms and conditions"
                    });
                    return;
                  }

                  setState(() {
                    _isLoading = true;
                    _errorMessage = '';
                  });

                  // Concatenar el código del país y el número de teléfono
                  String phoneNumber = _selectedCountryCode + _phoneNumberController.text;

                  String? errorMessage = await _authService.register(
                    _usernameController.text,
                    _passwordController.text,
                    _firstNameController.text,
                    _lastNameController.text,
                    _emailController.text,
                    phoneNumber,
                    _referralCodeController.text, // Pasar el código de referido
                  );

                  setState(() {
                    _isLoading = false;
                  });

                  if (errorMessage == null) {
                    // Registro exitoso, redirige al login
                    Navigator.pushReplacementNamed(context, '/login');
                  } else {
                    // Fallo en el registro, muestra el mensaje de error
                    setState(() {
                      _errorMessage = errorMessage;
                    });
                  }
                },
                child: Text(localizations.register), // Localización de "Register"
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
                  Navigator.pushNamed(context, '/login');
                },
                child: Text(
                  localizations.alreadyHaveAccountLogin, // Localización de "Already have an account? Login"
                  style: TextStyle(color: Colors.greenAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
