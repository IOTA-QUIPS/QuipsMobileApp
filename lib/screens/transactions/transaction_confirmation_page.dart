import 'package:flutter/material.dart';
import '../home/home_page.dart'; // Importa tu página de inicio aquí

class TransactionConfirmationPage extends StatelessWidget {
  final String receiverName;
  final double amount;
  final String timestamp;
  final String operationHash;

  TransactionConfirmationPage({
    required this.receiverName,
    required this.amount,
    required this.timestamp,
    required this.operationHash,
  }) {
    // Imprimir la hora en la consola al crear esta pantalla
    final localTime = DateTime.now().toLocal();
    print("Transacción realizada el: $localTime");
  }

  String _formatTimestamp(String timestamp) {
    // Convertir la marca de tiempo a local
    DateTime parsedDate = DateTime.parse(timestamp).toLocal();
    return "${parsedDate.day.toString().padLeft(2, '0')} ${_monthName(parsedDate.month)} ${parsedDate.year}, ${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0')} ${parsedDate.hour >= 12 ? 'pm' : 'am'}";
  }

  String _monthName(int month) {
    const months = [
      "Enero",
      "Febrero",
      "Marzo",
      "Abril",
      "Mayo",
      "Junio",
      "Julio",
      "Agosto",
      "Septiembre",
      "Octubre",
      "Noviembre",
      "Diciembre"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 32), // Espacio para mover el cuadro más arriba
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          "¡Quipeaste!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Q! ${amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      receiverName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      _formatTimestamp(timestamp),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Divider(color: Colors.grey[300]),
                    SizedBox(height: 16),
                    _buildDetailRow("N° de operación:", operationHash.substring(0, 8)), // Mostrar solo 8 caracteres del hash
                  ],
                ),
              ),
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton(Icons.share, "Compartir", onTap: () {
                      // Lógica para compartir
                    }),
                    _buildActionButton(Icons.home, "Ir a inicio", onTap: () {
                      // Navegar a HomePage
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    }),
                    _buildActionButton(Icons.local_offer, "Mis Promos", onTap: () {
                      // Lógica futura para promociones
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.purple[100],
            radius: 28,
            child: Icon(icon, color: Colors.purple, size: 28),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.purple),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
