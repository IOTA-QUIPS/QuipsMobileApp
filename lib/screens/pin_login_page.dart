import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class PinLoginPage extends StatefulWidget {
  @override
  _PinLoginPageState createState() => _PinLoginPageState();
}

class _PinLoginPageState extends State<PinLoginPage> {
  final TextEditingController _pinController = TextEditingController();
  String _errorMessage = '';
  List<int> _numbers = [];
  int _attempts = 0;
  bool _isBlocked = false;
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _showPad = false;

  @override
  void initState() {
    super.initState();
    _shuffleNumbers();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _shuffleNumbers() {
    setState(() {
      _numbers = List<int>.generate(10, (i) => i);
      _numbers.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Ingresar con Clave Secreta'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView( // Envuelve el contenido en un scroll
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.lock,
                    color: Colors.amber[300],
                    size: 40,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showPad = !_showPad;
                });
              },
              child: _buildPinField(),
            ),
            SizedBox(height: 20),
            if (_showPad && !_isBlocked)
              Column(
                children: [
                  _buildNumericPad(),
                  SizedBox(height: 20),
                  _buildDeleteButton(),
                ],
              ),
            if (_isBlocked) _buildBlockMessage(),
            if (_errorMessage.isNotEmpty) _buildErrorMessage(),
            TextButton(
              onPressed: () {
                // Acción de "¿Olvidaste tu clave?"
              },
              child: Text(
                '¿Olvidaste tu clave?',
                style: TextStyle(color: Colors.amber[300], fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
        controller: _pinController,
        keyboardType: TextInputType.none,
        obscureText: true,
        readOnly: true,
        style: TextStyle(color: Colors.white, fontSize: 18),
        decoration: InputDecoration(
          labelText: 'Ingrese su clave de 6 dígitos',
          labelStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
        ),
        onTap: () {
          setState(() {
            _showPad = true;
          });
        },
      ),
    );
  }

  Widget _buildBlockMessage() {
    return Column(
      children: [
        Text(
          'Demasiados intentos fallidos. Inténtalo de nuevo en $_secondsRemaining segundos.',
          style: TextStyle(color: Colors.redAccent, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNumericPad() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), // Evitar scroll independiente
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
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
              if (_pinController.text.length == 6) {
                _validatePin();
              }
            },
            child: Text(
              _numbers[index].toString(),
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(16),
              shadowColor: Colors.amber.withOpacity(0.5),
              elevation: 6,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeleteButton() {
    return IconButton(
      icon: Icon(Icons.backspace, color: Colors.redAccent),
      onPressed: () {
        if (_pinController.text.isNotEmpty) {
          setState(() {
            _pinController.text =
                _pinController.text.substring(0, _pinController.text.length - 1);
          });
        }
      },
      iconSize: 30,
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        _errorMessage,
        style: TextStyle(color: Colors.redAccent, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _validatePin() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedPin = prefs.getString('sixDigitPin');

      if (savedPin == null) throw Exception('No se encontró una clave guardada.');

      savedPin = savedPin.replaceAll('"', '');

      if (_pinController.text == savedPin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Clave incorrecta';
          _pinController.clear();
          _attempts++;
        });

        if (_attempts >= 3) _startBlockTimer();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocurrió un error. Inténtalo nuevamente.';
      });
    }
  }

  void _startBlockTimer() {
    setState(() {
      _isBlocked = true;
      _secondsRemaining = 300;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _isBlocked = false;
          _attempts = 0;
          _timer?.cancel();
        }
      });
    });
  }
}
