import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String loginApiUrl = 'http://34.122.251.215:8080/api/users/login'; // Ajusta la IP si es necesario
  final String registerApiUrl = 'http://34.122.251.215:8080/api/users'; // Endpoint para el registro
  final String userInfoApiUrl = 'http://34.122.251.215:8080/api/users/me'; // Endpoint para obtener información del usuario

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

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        return {'error': 'Invalid username or password'};
      } else {
        return {'error': 'An error occurred. Please try again later.'};
      }
    } catch (e) {
      print('Exception: $e');
      return {'error': 'Could not connect to the server. Please check your connection.'};
    }
  }

  // Método para hacer registro
  Future<String?> register(String username, String password, String firstName, String lastName, String email, String phoneNumber, String referralCode) async {
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
          'phoneNumber': phoneNumber,
          'referralCode': referralCode, // Agregar número de teléfono
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



  // Método para guardar la clave secreta
  Future<String?> setPin(String token, String pin) async {
    final response = await http.post(
      Uri.parse('http://34.122.251.215:8080/api/users/setPin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'sixDigitPin': pin, // Ahora se envía el PIN dentro de un objeto JSON
      }),
    );

    if (response.statusCode == 200) {
      return null; // Éxito
    } else {
      return 'Error al configurar la clave';
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
        print('User Info Response: ${response.body}');  // Imprimir los datos recibidos
        return jsonDecode(response.body); // Retorna los datos del usuario
      } else {
        print('Error fetching user info: ${response.body}');  // Imprimir el error si ocurre
        return {'error': 'Failed to fetch user info'};
      }
    } catch (e) {
      print('Exception: $e');
      return {'error': 'Could not connect to the server. Please check your connection.'};
    }
  }

}
