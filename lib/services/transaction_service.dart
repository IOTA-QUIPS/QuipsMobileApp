import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TransactionService {
  final String transactionApiUrl = 'https://quips-backend-production.up.railway.app/api/transactions'; // Endpoint para realizar transacciones

  // Método para realizar una transacción
  Future<Map<String, dynamic>?> makeTransaction(String senderAccountNumber, String receiverAccountNumber, double amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');  // Recuperar el token del usuario autenticado

    if (token == null) {
      return {'error': 'No token found'};  // Verificar que el usuario está autenticado
    }

    try {
      // Realizar la solicitud POST para crear una transacción
      final response = await http.post(
        Uri.parse(transactionApiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'senderPhoneNumber': senderAccountNumber,
          'receiverPhoneNumber': receiverAccountNumber,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);  // Si es exitoso, devuelve la respuesta JSON
      } else {
        return {'error': 'Transaction failed'};  // Si falla, devuelve un mensaje de error
      }
    } catch (e) {
      return {'error': 'Error connecting to server'};  // Manejo de excepciones
    }
  }
}
