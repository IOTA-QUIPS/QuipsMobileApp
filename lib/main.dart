import 'package:flutter/material.dart';
import 'package:quipsapp/screens/chat_history_page.dart';
import 'package:quipsapp/screens/contact_list_page.dart';
import 'package:quipsapp/screens/register_page.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/transaction_page.dart';
import 'screens/confirmation_page.dart';
import 'screens/transaction_history_page.dart';
import 'screens/user_profile_page.dart';
import 'screens/settings_page.dart';
import 'screens/support_page.dart';
import 'screens/chat_page.dart'; // Pantalla de chat

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
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/transaction': (context) => TransactionPage(),
        '/confirmation': (context) => ConfirmationPage(),
        '/history': (context) => TransactionHistoryPage(),
        '/profile': (context) => UserProfilePage(),
        '/settings': (context) => SettingsPage(),
        '/support': (context) => SupportPage(),
        '/contacts': (context) => ContactListPage(),
        '/chatHistory': (context) => ChatHistoryPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          final args = settings.arguments as Map<String, dynamic>; // Cambiar a Map<String, dynamic>

          return MaterialPageRoute(
            builder: (context) {
              return ChatPage(
                senderUsername: args['senderUsername'] as String,
                receiverUsername: args['receiverUsername'] as String,
                senderId: args['senderId'] as String,
                receiverId: args['receiverId'] as String,
              );
            },
          );
        }
        return null; // En caso de que la ruta no coincida
      },
    );
  }
}
