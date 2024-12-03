import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How can we help you?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Acción para abrir formulario de contacto
              },
              child: Text('Contact Us'),
            ),
            ElevatedButton(
              onPressed: () {
                // Acción para abrir preguntas frecuentes
              },
              child: Text('FAQs'),
            ),
            ElevatedButton(
              onPressed: () {
                // Acción para abrir guías o tutoriales
              },
              child: Text('Guides'),
            ),
          ],
        ),
      ),
    );
  }
}
