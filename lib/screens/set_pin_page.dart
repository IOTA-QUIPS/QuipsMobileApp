import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quipsapp/services/auth_service.dart';

class SetPinPage extends StatefulWidget {
  final String token;

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Configurar Clave Secreta',
          style: TextStyle(color: Colors.amber[300], fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título para la introducción
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Text(
                'Establezca una clave de 6 dígitos para asegurar su cuenta.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[400],
                ),
              ),
            ),

            // Campo para ingresar la clave
            _buildPinField(
              controller: _pinController,
              hintText: 'Ingrese su clave de 6 dígitos',
            ),
            SizedBox(height: 24),

            // Campo para confirmar la clave
            _buildPinField(
              controller: _confirmPinController,
              hintText: 'Confirme su clave de 6 dígitos',
            ),
            SizedBox(height: 32),

            // Botón para guardar la clave
            ElevatedButton(
              onPressed: () async {
                if (_pinController.text != _confirmPinController.text) {
                  setState(() {
                    _errorMessage = 'Las claves no coinciden';
                  });
                  return;
                }

                final result = await _authService.setPin(widget.token, _pinController.text);

                if (result == null) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  setState(() {
                    _errorMessage = result;
                  });
                }
              },
              child: Text('Guardar Clave'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[300],
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                shadowColor: Colors.amber[100],
                elevation: 6,
              ),
            ),
            SizedBox(height: 24),

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
          ],
        ),
      ),
    );
  }

  Widget _buildPinField({
    required TextEditingController controller,
    required String hintText,
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
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: 6,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          counterText: "", // Oculta el contador de caracteres
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
          prefixIcon: Icon(Icons.lock, color: Colors.amber[300], size: 24),
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
}
