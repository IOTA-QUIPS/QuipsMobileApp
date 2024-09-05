import 'package:flutter/material.dart';
import 'package:quipsapp/services/transaction_service.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _receiverAccountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TransactionService _transactionService = TransactionService();
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make a Transaction'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _receiverAccountController,
              decoration: InputDecoration(
                labelText: 'Receiver Account Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 40),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                  _successMessage = '';
                });

                // Enviar la transacción
                final response = await _transactionService.makeTransaction(
                  'sender_account_number',  // Obtén el número de cuenta del usuario logueado
                  _receiverAccountController.text,
                  double.parse(_amountController.text),
                );

                setState(() {
                  _isLoading = false;
                });

                if (response != null && response.containsKey('error')) {
                  setState(() {
                    _errorMessage = response['error'];
                  });
                } else {
                  setState(() {
                    _successMessage = 'Transaction successful';
                  });
                }
              },
              child: Text('Make Transaction'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            if (_successMessage.isNotEmpty)
              Text(
                _successMessage,
                style: TextStyle(color: Colors.green),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
