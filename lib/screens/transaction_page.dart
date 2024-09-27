import 'package:flutter/material.dart';
import 'package:quipsapp/services/transaction_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Para localizaciones

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _receiverPhoneNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TransactionService _transactionService = TransactionService();
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  String _selectedCountryCode = '+51'; // Código por defecto (Perú)

  // Lista de códigos de país
  final List<Map<String, String>> _countryCodes = [
    {'name': 'Perú', 'code': '+51'},
    {'name': 'Colombia', 'code': '+57'},
    {'name': 'Chile', 'code': '+56'},
    {'name': 'Argentina', 'code': '+54'},
    {'name': 'USA', 'code': '+1'},
    {'name': 'Mexico', 'code': '+52'},
    {'name': 'El Salvador', 'code': '+503'},
  ];

  @override
  Widget build(BuildContext context) {
    // Obtener las traducciones desde el archivo de localización
    var localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.makeTransaction), // Localización de "Make a Transaction"
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selector de código de país
            DropdownButtonFormField<String>(
              value: _selectedCountryCode,
              items: _countryCodes.map((country) {
                return DropdownMenuItem<String>(
                  value: country['code'],
                  child: Text('${country['name']} (${country['code']})'),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: localizations.selectCountry, // Localización de "Select Country"
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedCountryCode = value!;
                });
              },
            ),
            SizedBox(height: 20),
            // Campo para el número de teléfono del destinatario
            TextFormField(
              controller: _receiverPhoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: localizations.receiverPhoneNumber, // Localización de "Receiver Phone Number"
                prefixText: _selectedCountryCode + " ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Campo para la cantidad a transferir
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: localizations.amount, // Localización de "Amount"
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 40),
            // Botón de transacción
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                  _successMessage = '';
                });

                // Concatenar el código del país y el número de teléfono
                String receiverPhoneNumber = _selectedCountryCode + _receiverPhoneNumberController.text;

                // Enviar la transacción
                final response = await _transactionService.makeTransaction(
                  'sender_phone_number',  // Obtén el número de teléfono del usuario logueado
                  receiverPhoneNumber,    // Número de teléfono con el código del país
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
                    _successMessage = localizations.transactionSuccessful; // Localización de "Transaction successful"
                  });
                  // Devuelve true para indicar éxito
                  Navigator.pop(context, true);
                }
              },
              child: Text(localizations.makeTransaction), // Localización de "Make Transaction"
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
