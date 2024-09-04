import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text('John Doe'),
              subtitle: Text('Username'),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('johndoe@example.com'),
              subtitle: Text('Email'),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('+1 234 567 890'),
              subtitle: Text('Phone'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Acción para cambiar la contraseña
              },
              child: Text('Change Password'),
            ),
            ElevatedButton(
              onPressed: () {
                // Acción para cerrar sesión
              },
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
