import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class PinLoginPage extends StatefulWidget {
  @override
  _PinLoginPageState createState() => _PinLoginPageState();
}

class _PinLoginPageState extends State<PinLoginPage> with TickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  List<int> _numbers = [];
  int _attempts = 0;
  bool _isBlocked = false;
  Timer? _timer;
  int _secondsRemaining = 0;
  List<bool> _pinState = [false, false, false, false, false, false];

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTopContent(),
              if (!_isBlocked) _buildPinIndicator(),
              if (!_isBlocked) _buildNumericPad(screenSize),
              if (_isBlocked) _buildBlockMessage(),
              TextButton(
                onPressed: () {
                  // Acción para "¿Olvidaste tu clave?"
                },
                child: Text(
                  '¿Olvidaste tu clave?',
                  style: TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopContent() {
    return Column(
      children: [
        SizedBox(height: 20),
        Image.asset(
          'assets/isotipo.png',
          height: 120,
        ),
        SizedBox(height: 20),
        Text(
          'Ingresa tu clave',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPinIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6,
            (index) => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _pinState[index] ? Colors.purple : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildNumericPad(Size screenSize) {
    double buttonSize = screenSize.width / 4.5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: _numbers.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (_pinController.text.length < 6) {
                setState(() {
                  _pinController.text += _numbers[index].toString();
                  _pinState[_pinController.text.length - 1] = true;
                });
              }
              if (_pinController.text.length == 6) {
                _validatePin();
              }
            },
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _numbers[index].toString(),
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlockMessage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Demasiados intentos fallidos. Inténtalo de nuevo en $_secondsRemaining segundos.',
        style: TextStyle(color: Colors.redAccent, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _validatePin() async {
    _showLoadingDialog(); // Muestra el diálogo de carga

    await Future.delayed(Duration(seconds: 2)); // Simula el tiempo de procesamiento

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedPin = prefs.getString('sixDigitPin');

      Navigator.pop(context); // Cierra el diálogo de carga

      if (savedPin == null) throw Exception('No se encontró una clave guardada.');

      if (_pinController.text == savedPin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } else {
        setState(() {
          _pinController.clear();
          _pinState = [false, false, false, false, false, false];
          _attempts++;
        });

        if (_attempts >= 3) _startBlockTimer();

        _showErrorDialog();
      }
    } catch (e) {
      Navigator.pop(context); // Cierra el diálogo de carga si ocurre un error
      _showErrorDialog(message: 'Ocurrió un error. Inténtalo nuevamente.');
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // No permite cerrar el diálogo tocando fuera
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.purple),
                SizedBox(height: 20),
                Text(
                  'Validando datos',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog({String message = 'Clave incorrecta'}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Error', style: TextStyle(color: Colors.red)),
          content: Text(message, style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Intentar de nuevo', style: TextStyle(color: Colors.purple)),
            ),
          ],
        );
      },
    );
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
