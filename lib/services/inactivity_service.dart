import 'dart:async';
import 'package:flutter/foundation.dart'; // Importa esto para usar VoidCallback

class InactivityService {
  Timer? _inactivityTimer;
  final int timeoutInSeconds;
  final VoidCallback onInactivityDetected; // Aquí usamos VoidCallback

  InactivityService({required this.timeoutInSeconds, required this.onInactivityDetected});

  void start() {
    _resetTimer();
  }

  void _resetTimer() {
    // Cancelar el temporizador actual si está corriendo
    if (_inactivityTimer != null) {
      _inactivityTimer!.cancel();
    }

    // Configurar el temporizador para la inactividad
    _inactivityTimer = Timer(Duration(seconds: timeoutInSeconds), () {
      onInactivityDetected();
    });
  }

  void resetTimer() {
    _resetTimer();
  }

  void dispose() {
    if (_inactivityTimer != null) {
      _inactivityTimer!.cancel();
    }
  }
}
