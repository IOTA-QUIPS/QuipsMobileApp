import 'package:flutter/material.dart';

class ChatSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Configuración del Chat")),
      body: ListView(
        children: [
          ListTile(
            title: Text("Notificaciones"),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Configurar notificaciones
              },
            ),
          ),
          ListTile(
            title: Text("Fondo de chat"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navegar a selección de fondo
            },
          ),
        ],
      ),
    );
  }
}
