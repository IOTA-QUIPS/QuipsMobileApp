import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String loginApiUrl = 'http://10.0.2.2:8080/api/users/login'; // Ajusta la IP si es necesario
  final String registerApiUrl = 'http://10.0.2.2:8080/api/users'; // Endpoint para el registro
  final String userInfoApiUrl = 'http://10.0.2.2:8080/api/users/me'; // Endpoint para obtener información del usuario

  // Método para hacer login
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginApiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Login exitoso, parsear la respuesta como JSON
        return jsonDecode(response.body); // Puede contener información del usuario
      } else if (response.statusCode == 400) {
        return {'error': 'Invalid username or password'};
      } else {
        return {'error': 'An error occurred. Please try again later.'};
      }
    } catch (e) {
      return {'error': 'Could not connect to the server. Please check your connection.'};
    }
  }

  // Método para hacer registro
  Future<String?> register(String username, String password, String firstName, String lastName, String email, String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse(registerApiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,                // Agregar email
          'phoneNumber': phoneNumber,    // Agregar número de teléfono
        }),
      );

      if (response.statusCode == 200) {
        return null; // Registro exitoso
      } else if (response.statusCode == 400) {
        return 'Invalid data. Please check the input fields.';
      } else {
        return 'An error occurred. Please try again later.';
      }
    } catch (e) {
      return 'Could not connect to the server. Please check your connection.';
    }
  }

  // Método para obtener información del usuario autenticado
  Future<Map<String, dynamic>?> getUserInfo(String token) async {
    try {
      final response = await http.get(
        Uri.parse(userInfoApiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Retorna los datos del usuario
      } else {
        return {'error': 'Failed to fetch user info'};
      }
    } catch (e) {
      return {'error': 'Could not connect to the server. Please check your connection.'};
    }
  }
}
