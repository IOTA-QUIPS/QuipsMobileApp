import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'https://quips-backend-production.up.railway.app/api/users';

  // Método para hacer login usando PIN
  Future<Map<String, dynamic>?> login(String username, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': pin,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Retorna el token JWT
      } else if (response.statusCode == 403) {
        return {'error': 'Cuenta no activada o PIN no configurado.'};
      } else if (response.statusCode == 401) {
        return {'error': 'PIN incorrecto.'};
      } else {
        return {'error': 'Ocurrió un error. Intenta nuevamente más tarde.'};
      }
    } catch (e) {
      print('Exception: $e');
      return {'error': 'No se pudo conectar al servidor. Verifica tu conexión.'};
    }
  }

  // Método para registrar un nuevo usuario
  Future<Map<String, dynamic>?> register(
      String firstName, String lastName, String email, String phoneNumber, String referralCode) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNumber': phoneNumber,
          'referralCode': referralCode,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('token')) {
          // Retornar el token y otros datos útiles de la respuesta
          return {'token': responseData['token']};
        } else {
          return {'error': 'El servidor no devolvió un token.'};
        }
      } else if (response.statusCode == 400) {
        return {'error': 'Datos inválidos. Verifica los campos ingresados.'};
      } else {
        return {'error': 'Ocurrió un error. Intenta nuevamente más tarde.'};
      }
    } catch (e) {
      return {'error': 'No se pudo conectar al servidor. Verifica tu conexión.'};
    }
  }

  Future<Map<String, dynamic>?> getUserActivity(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user-activity/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('User Activity Response: ${response.body}');
        return jsonDecode(response.body);
      } else {
        print('Error fetching user activity: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  // Método para configurar el PIN
  Future<String?> setPin(String token, String pin) async {
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      return 'El PIN debe ser un número de 6 dígitos.';
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/setPin'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'sixDigitPin': pin,
        }),
      );

      if (response.statusCode == 200) {
        return null; // Éxito
      } else if (response.statusCode == 404) {
        return 'Usuario no encontrado.';
      } else {
        return 'Error al configurar el PIN. Intenta nuevamente.';
      }
    } catch (e) {
      print('Exception: $e');
      return 'No se pudo conectar al servidor. Verifica tu conexión.';
    }
  }

  // Método para obtener información del usuario autenticado
  Future<Map<String, dynamic>?> getUserInfo(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json; charset=utf-8', // Asegura la codificación UTF-8
        },
      );

      if (response.statusCode == 200) {
        print('User Info Response: ${utf8.decode(response.bodyBytes)}');
        return jsonDecode(utf8.decode(response.bodyBytes)); // Decodifica como UTF-8
      } else {
        print('Error fetching user info: ${utf8.decode(response.bodyBytes)}');
        return {'error': 'Error al obtener información del usuario.'};
      }
    } catch (e) {
      print('Exception: $e');
      return {'error': 'No se pudo conectar al servidor. Verifica tu conexión.'};
    }
  }

  // Método para solicitar recuperación del PIN
  Future<String?> resetPin(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resetPin'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(email),
      );

      if (response.statusCode == 200) {
        return 'Si el correo existe, hemos enviado un enlace de restablecimiento.';
      } else if (response.statusCode == 400) {
        return 'Formato de correo inválido.';
      } else {
        return 'Ocurrió un error. Intenta nuevamente más tarde.';
      }
    } catch (e) {
      print('Exception: $e');
      return 'No se pudo conectar al servidor. Verifica tu conexión.';
    }
  }

  // Método para confirmar el restablecimiento del PIN
  Future<String?> confirmResetPin(String token, String newPin) async {
    if (!RegExp(r'^\d{6}$').hasMatch(newPin)) {
      return 'El PIN debe ser un número de 6 dígitos.';
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/confirmResetPin?token=$token'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(newPin),
      );

      if (response.statusCode == 200) {
        return null; // Restablecimiento exitoso
      } else if (response.statusCode == 400) {
        return 'Token inválido o PIN incorrecto.';
      } else {
        return 'Error al restablecer el PIN.';
      }
    } catch (e) {
      print('Exception: $e');
      return 'No se pudo conectar al servidor. Verifica tu conexión.';
    }
  }
}
