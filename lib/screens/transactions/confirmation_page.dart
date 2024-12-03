import 'package:flutter/material.dart';

class ConfirmationPage extends StatelessWidget {
  final String transactionCode = "TXN12345678"; // Código de ejemplo
  final String dateTime = "2024-08-31 12:34 PM"; // Fecha y hora de ejemplo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Confirmation'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Transaction Successful!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 20),
            Text(
              'Transaction Code:',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              transactionCode,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Date & Time:',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              dateTime,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/home'));
              },
              child: Text('Return to Home'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
