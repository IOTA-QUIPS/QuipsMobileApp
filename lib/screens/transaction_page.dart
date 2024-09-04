import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final List<String> contacts = ["Alice", "Bob", "Charlie"]; // Ejemplo de contactos
  String? selectedContact;
  double? amount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Contact and Amount'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Contact',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              items: contacts.map((String contact) {
                return DropdownMenuItem<String>(
                  value: contact,
                  child: Text(contact),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedContact = value;
                });
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  amount = double.tryParse(value);
                });
              },
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: selectedContact != null && amount != null
                  ? () {
                Navigator.pushNamed(context, '/confirmation');
              }
                  : null,
              child: Text('Continue'),
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
