import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import '../services/auth_service.dart';
import 'transaction_confirmation_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionAmountPage extends StatelessWidget {
  final String receiverName; // Nombre completo registrado en la app
  final String receiverPhone; // Teléfono del receptor

  TransactionAmountPage({
    required this.receiverName,
    required this.receiverPhone,
  });

  final TextEditingController _amountController = TextEditingController();
  final TransactionService transactionService = TransactionService();
  final AuthService _authService = AuthService();

  Future<String?> _getSenderPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? senderPhoneNumber = prefs.getString('phoneNumber');
    if (senderPhoneNumber != null) {
      print("[LOG] Sender phone number from SharedPreferences: $senderPhoneNumber");
      return senderPhoneNumber;
    }

    // Si el número de teléfono no está en SharedPreferences, obtenerlo desde el backend
    String? token = prefs.getString('jwtToken');
    if (token != null) {
      final response = await _authService.getUserInfo(token);
      if (response != null && !response.containsKey('error')) {
        senderPhoneNumber = response['phoneNumber'];

        // Verificar si senderPhoneNumber no es null antes de guardarlo
        if (senderPhoneNumber != null) {
          await prefs.setString('phoneNumber', senderPhoneNumber); // Guardar en SharedPreferences
          print("[LOG] Sender phone number retrieved from backend and saved: $senderPhoneNumber");
        } else {
          print("[LOG] senderPhoneNumber is null, not saving to SharedPreferences.");
        }
        return senderPhoneNumber;
      } else {
        print("[LOG] Error retrieving user info: ${response?['error'] ?? 'Unknown error'}");
        return null;
      }
    } else {
      print("[LOG] JWT token is null.");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quipear a"),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            // Nombre del destinatario
            Center(
              child: Text(
                receiverName,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24),
            // Campo para ingresar el monto
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                  fontSize: 48, fontWeight: FontWeight.bold, color: Colors.purple),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                prefixText: "Q!  ",
                prefixStyle: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple),
                hintText: "0.00",
                hintStyle: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400]),
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 12),
            // Límite de transferencia
            Text(
              "Límite por yapear S/ 500, límite total por día S/ 2,000",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            Spacer(),
            // Botón de confirmación
            ElevatedButton(
              onPressed: () async {
                if (_amountController.text.isNotEmpty) {
                  double amount = double.tryParse(_amountController.text) ?? 0.0;
                  if (amount > 0) {
                    String? senderPhoneNumber = await _getSenderPhoneNumber();
                    if (senderPhoneNumber != null) {
                      print("[LOG] Starting transaction...");
                      print("[LOG] Sender Phone Number: $senderPhoneNumber");
                      print("[LOG] Receiver Phone Number: $receiverPhone");
                      print("[LOG] Amount: $amount");

                      // Lógica para realizar la transacción
                      final transactionResponse = await transactionService
                          .makeTransaction(
                        senderPhoneNumber, // Ahora se usa el número de teléfono del remitente
                        receiverPhone, // Se usa el número de teléfono del receptor
                        amount,
                      );

                      if (transactionResponse != null &&
                          !transactionResponse.containsKey('error')) {
                        print("[LOG] Transaction successful: $transactionResponse");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionConfirmationPage(
                              receiverName: receiverName,
                              amount: amount,
                              timestamp: transactionResponse['timestamp'],
                              operationHash: transactionResponse['hash'],
                            ),
                          ),
                        );
                      } else {
                        print("[LOG] Transaction failed: ${transactionResponse?['error'] ?? 'Unknown error'}");
                        _showErrorDialog(
                            context,
                            transactionResponse?['error'] ?? 'Error desconocido.');
                      }
                    } else {
                      print("[LOG] Sender phone number is null.");
                      _showErrorDialog(context, "Error al obtener el número de teléfono del remitente.");
                    }
                  } else {
                    print("[LOG] Invalid amount entered: $amount");
                    _showErrorDialog(context, "Ingrese un monto válido.");
                  }
                } else {
                  print("[LOG] Amount field is empty.");
                  _showErrorDialog(context, "El campo de monto está vacío.");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                "Quipear",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Mostrar diálogo de error
  void _showErrorDialog(BuildContext context, String message) {
    print("[LOG] Error Dialog: $message");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }
}
