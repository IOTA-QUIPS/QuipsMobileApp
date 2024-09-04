import 'package:flutter/material.dart';
import 'screens/home_page.dart'; // Importa la pantalla de inicio
import 'screens/transaction_page.dart'; // Importa la pantalla de transacción
import 'screens/confirmation_page.dart'; // Importa la pantalla de confirmación
import 'screens/transaction_history_page.dart'; // Importa la pantalla de historial
import 'screens/user_profile_page.dart'; // Importa la pantalla de perfil
import 'screens/settings_page.dart'; // Importa la pantalla de ajustes
import 'screens/support_page.dart'; // Importa la pantalla de soporte

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Banking App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomePage(),
        '/transaction': (context) => TransactionPage(),
        '/confirmation': (context) => ConfirmationPage(),
        '/history': (context) => TransactionHistoryPage(),
        '/profile': (context) => UserProfilePage(),
        '/settings': (context) => SettingsPage(),
        '/support': (context) => SupportPage(),
      },
    );
  }
}
