import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quipsapp/services/auth_service.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String fullName = "Loading...";
  String username = "Loading...";
  final AuthService _authService = AuthService(); // Instancia de AuthService

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token != null) {
      // Llamada a AuthService para obtener los datos del usuario
      final response = await _authService.getUserInfo(token);

      if (response != null && !response.containsKey('error')) {
        setState(() {
          fullName = response['firstName'] + " " + response['lastName'];
          username = response['username'];
        });
      } else {
        // Manejar error
        print('Error al cargar los datos del usuario');
      }
    } else {
      // Si no hay token, redirigir al login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

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
              title: Text(fullName),
              subtitle: Text('Full Name'),
            ),
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text(username),
              subtitle: Text('Username'),
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
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('jwtToken');
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
