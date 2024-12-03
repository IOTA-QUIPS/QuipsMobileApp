import 'package:flutter/material.dart';
import 'package:quipsapp/services/transaction_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    var localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(localizations.makeTransaction),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selector de código de país con estilo premium
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedCountryCode,
                  dropdownColor: Colors.grey[900],
                  iconEnabledColor: Colors.amber[300],
                  style: TextStyle(color: Colors.white),
                  items: _countryCodes.map((country) {
                    return DropdownMenuItem<String>(
                      value: country['code'],
                      child: Text(
                        '${country['name']} (${country['code']})',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: localizations.selectCountry,
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedCountryCode = value!;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),

              // Campo para el número de teléfono del destinatario con estilo premium
              _buildTextField(
                controller: _receiverPhoneNumberController,
                hintText: localizations.receiverPhoneNumber,
                icon: Icons.phone,
                prefixText: _selectedCountryCode + " ",
              ),
              SizedBox(height: 20),

              // Campo para la cantidad a transferir con estilo premium
              _buildTextField(
                controller: _amountController,
                hintText: localizations.amount,
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 40),

              // Botón de transacción mejorado
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.amber[300]))
                  : ElevatedButton(
                onPressed: _makeTransaction,
                child: Text(localizations.makeTransaction),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[300],
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  shadowColor: Colors.amber[100],
                  elevation: 6,
                ),
              ),
              SizedBox(height: 20),

              // Mensajes de error y éxito
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              if (_successMessage.isNotEmpty)
                Text(
                  _successMessage,
                  style: TextStyle(color: Colors.greenAccent, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.amber[300]),
          prefixText: prefixText,
          prefixStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[900],
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Future<void> _makeTransaction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final response = await _transactionService.makeTransaction(
        'sender_phone_number',  // Reemplaza con el número de teléfono del usuario logueado
        _selectedCountryCode + _receiverPhoneNumberController.text, // Número de teléfono completo
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
          var localizations = AppLocalizations.of(context)!;
          _successMessage = localizations.transactionSuccessful;
        });
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error al realizar la transacción";
      });
    }
  }
}
