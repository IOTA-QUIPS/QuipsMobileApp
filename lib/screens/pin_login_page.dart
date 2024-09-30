import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart'; // Importar la página de inicio para usuarios normales

class PinLoginPage extends StatefulWidget {
  @override
  _PinLoginPageState createState() => _PinLoginPageState();
}

class _PinLoginPageState extends State<PinLoginPage> {
  final TextEditingController _pinController = TextEditingController();
  String _errorMessage = '';
  List<int> _numbers = [];
  int _attempts = 0; // Contador de intentos fallidos
  bool _isBlocked = false; // Bandera para indicar si está bloqueado
  Timer? _timer; // Temporizador para controlar el tiempo de bloqueo
  int _secondsRemaining = 0; // Segundos restantes durante el bloqueo

  @override
  void initState() {
    super.initState();
    _shuffleNumbers(); // Barajar los números al iniciar
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancelar el temporizador si se destruye el widget
    super.dispose();
  }

  void _shuffleNumbers() {
    setState(() {
      _numbers = List<int>.generate(10, (i) => i); // Generar los números del 0 al 9
      _numbers.shuffle(); // Barajar los números
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ingresar con Clave Secreta'),
        backgroundColor: Colors.blueAccent, // Color azul para el tema
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Espacio reservado para el logo
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // Fondo gris claro
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "Logo Aquí",
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Campo para ingresar el PIN
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.none, // Evita que se abra el teclado estándar
                obscureText: true,
                readOnly: true, // El teclado numérico es personalizado
                decoration: InputDecoration(
                  labelText: 'Ingrese su clave de 6 dígitos',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              _isBlocked
                  ? Column(
                children: [
                  Text(
                    'Demasiados intentos fallidos. Inténtalo de nuevo en $_secondsRemaining segundos.',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                ],
              )
                  : Column(
                children: [
                  // Teclado numérico personalizado
                  _buildNumericPad(),
                  SizedBox(height: 20),
                  // Botón de borrar
                  ElevatedButton(
                    onPressed: () {
                      if (_pinController.text.isNotEmpty) {
                        setState(() {
                          _pinController.text = _pinController.text
                              .substring(0, _pinController.text.length - 1);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                    child: Text('Borrar'),
                  ),
                ],
              ),
              // Mostrar siempre el mensaje de error si está presente
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              TextButton(
                onPressed: () {
                  // Acción de "¿Olvidaste tu clave?"
                },
                child: Text(
                  '¿Olvidaste tu clave?',
                  style: TextStyle(color: Colors.greenAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir el teclado numérico
  Widget _buildNumericPad() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Tres columnas
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: _numbers.length,
        itemBuilder: (context, index) {
          return ElevatedButton(
            onPressed: () {
              if (_pinController.text.length < 6) {
                setState(() {
                  _pinController.text += _numbers[index].toString();
                });
              }

              // Validar automáticamente cuando se ingresen 6 dígitos
              if (_pinController.text.length == 6) {
                _validatePin(); // Llamar la función de validación
              }
            },
            child: Text(
              _numbers[index].toString(),
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent, // Color del botón
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 20),
            ),
          );
        },
      ),
    );
  }

  // Método para validar el PIN
  void _validatePin() async {
    try {
      // Obtener la clave guardada en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedPin = prefs.getString('sixDigitPin');

      // Verificar si hay una clave guardada
      if (savedPin == null) {
        throw Exception('No se encontró una clave guardada.');
      }

      // Eliminar las comillas adicionales en caso de que existan
      savedPin = savedPin.replaceAll('"', '');

      // Validar si la clave ingresada coincide con la guardada
      if (_pinController.text == savedPin) {
        // Clave correcta, redirigir a la HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } else {
        // Clave incorrecta
        setState(() {
          _errorMessage = 'Clave incorrecta';
          _pinController.clear(); // Limpiar el campo PIN después de un intento fallido
          _attempts++; // Incrementar el contador de intentos fallidos
        });

        if (_attempts >= 3) {
          // Bloquear la pantalla después de 3 intentos fallidos
          _startBlockTimer();
        }
      }
    } catch (e) {
      // Captura cualquier error y lo muestra
      setState(() {
        _errorMessage = 'Ocurrió un error. Inténtalo nuevamente.';
      });
    }
  }

  // Iniciar el temporizador de bloqueo (5 minutos)
  void _startBlockTimer() {
    setState(() {
      _isBlocked = true;
      _secondsRemaining = 300; // 300 segundos = 5 minutos
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _isBlocked = false; // Desbloquear después de los 5 minutos
          _attempts = 0; // Reiniciar los intentos
          _timer?.cancel(); // Detener el temporizador
        }
      });
    });
  }
}
