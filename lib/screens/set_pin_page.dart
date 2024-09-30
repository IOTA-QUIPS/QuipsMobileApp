import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quipsapp/services/auth_service.dart';

class SetPinPage extends StatefulWidget {
  final String token; // El token JWT que recibimos tras el login

  SetPinPage(this.token);

  @override
  _SetPinPageState createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final AuthService _authService = AuthService();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurar Clave Secreta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Ingrese su clave de 6 dígitos'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirme su clave de 6 dígitos'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Validar si ambas claves coinciden
                if (_pinController.text != _confirmPinController.text) {
                  setState(() {
                    _errorMessage = 'Las claves no coinciden';
                  });
                  return;
                }

                // Llamar al servicio para guardar la clave
                final result = await _authService.setPin(widget.token, _pinController.text);

                if (result == null) {
                  // Si el resultado es null, la clave fue guardada correctamente
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  setState(() {
                    _errorMessage = result;
                  });
                }
              },
              child: Text('Guardar Clave'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
