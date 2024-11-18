import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa Firebase
import 'providers/locale_provider.dart';
import 'screens/splash_screen.dart'; // Importa la pantalla SplashScreen
import 'screens/chat_history_page.dart';
import 'screens/contact_list_page.dart';
import 'screens/register_page.dart';
import 'screens/terms_page.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/transaction_page.dart';
import 'screens/confirmation_page.dart';
import 'screens/transaction_history_page.dart';
import 'screens/user_profile_page.dart';
import 'screens/settings_page.dart';
import 'screens/support_page.dart';
import 'screens/chat_page.dart';
import 'admin/admin_home.dart';
import 'admin/manage_news.dart';
import 'admin/add_edit_news.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario para inicializaciones asíncronas

  // Inicializa Firebase y maneja errores
  try {
    await Firebase.initializeApp();
    print("Firebase se inicializó correctamente.");
  } catch (e) {
    print("Error al inicializar Firebase: $e");
  }



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'Flutter Quips App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
              useMaterial3: true,
            ),
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('es', ''),
            ],
            initialRoute: '/', // Cambiamos la ruta inicial a '/'
            routes: {
              '/': (context) => SplashScreen(), // Pantalla de verificación de sesión
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
              '/terms': (context) => TermsPage(),
              '/admin': (context) => AdminHome('admin-token'),
              '/manage-news': (context) => ManageNews('admin-token'),
              '/add-news': (context) => AddEditNews(token: 'admin-token', isEditing: false, onSave: () {}),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/chat') {
                final args = settings.arguments as Map<String, dynamic>;

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
              } else if (settings.name == '/edit-news') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) {
                    return AddEditNews(
                      token: args['token'] as String,
                      isEditing: true,
                      news: args['news'],
                      onSave: args['onSave'] as VoidCallback,
                    );
                  },
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
