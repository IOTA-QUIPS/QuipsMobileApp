import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Enable Notifications'),
            value: true, // Puedes manejar este estado con un State o Provider
            onChanged: (value) {
              // Acción para cambiar el estado de las notificaciones
            },
          ),
          ListTile(
            title: Text('Change Theme'),
            trailing: DropdownButton<String>(
              value: 'Light',
              items: <String>['Light', 'Dark'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                // Acción para cambiar el tema
              },
            ),
          ),
          ListTile(
            title: Text('Select Language'),
            trailing: DropdownButton<String>(
              value: 'English',
              items: <String>['English', 'Spanish'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                // Acción para cambiar el idioma
              },
            ),
          ),
        ],
      ),
    );
  }
}
