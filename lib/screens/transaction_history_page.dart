import 'package:flutter/material.dart';

class TransactionHistoryPage extends StatelessWidget {
  final List<Map<String, String>> transactions = [
    {"date": "2024-08-30", "amount": "-\$100", "contact": "Alice"},
    {"date": "2024-08-29", "amount": "+\$200", "contact": "Bob"},
    // Más transacciones de ejemplo...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return ListTile(
            title: Text(transaction['contact']!),
            subtitle: Text(transaction['date']!),
            trailing: Text(transaction['amount']!),
          );
        },
      ),
    );
  }
}
