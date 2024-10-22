import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quipsapp/services/auth_service.dart';
import 'package:quipsapp/screens/transaction_page.dart'; // Asegúrate de tener la ruta correcta
import 'package:quipsapp/services/news_service.dart';
import 'package:quipsapp/model/news_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Para localizaciones
import 'package:quipsapp/services/inactivity_service.dart'; // Importa el servicio de inactividad
import 'pin_login_page.dart'; // Importa la pantalla de ingreso con clave de 6 dígitos

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "Loading...";
  double balance = 0.0;
  List<News> newsList = [];
  final AuthService _authService = AuthService();
  late NewsService _newsService;
  late InactivityService _inactivityService; // Declarar el servicio de inactividad

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadNewsData();

    // Inicializar el servicio de inactividad
    _inactivityService = InactivityService(
      timeoutInSeconds: 300, // Tiempo de inactividad en segundos
      onInactivityDetected: _handleInactivity, // Manejar la inactividad
    );
    _inactivityService.start(); // Iniciar la detección de inactividad
  }

  @override
  void dispose() {
    _inactivityService.dispose(); // Cancelar el temporizador cuando se cierre la pantalla
    super.dispose();
  }

  // Función para manejar la inactividad (redirigir a PinLoginPage)
  void _handleInactivity() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PinLoginPage()), // Redirige a la pantalla de ingreso con PIN
    );
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token != null) {
      final response = await _authService.getUserInfo(token);

      if (response != null && !response.containsKey('error')) {
        setState(() {
          userName = response['firstName'] + " " + response['lastName'];
          balance = response['coins'] != null ? response['coins'].toDouble() : 0.0;
        });
      } else {
        print('Error al cargar los datos del usuario');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _loadNewsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');
    if (token != null) {
      _newsService = NewsService(token);
      try {
        List<News> news = await _newsService.getAllNews();
        setState(() {
          newsList = news;
        });
      } catch (e) {
        print('Error al cargar las noticias: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener las traducciones desde el archivo de localización
    var localizations = AppLocalizations.of(context)!;

    // Envuelve la pantalla completa en GestureDetector para capturar la interacción del usuario
    return GestureDetector(
      onTap: _inactivityService.resetTimer, // Reiniciar el temporizador en interacción
      onPanDown: (_) => _inactivityService.resetTimer(), // Reiniciar al hacer scroll o deslizar
      child: Scaffold(
        appBar: AppBar(
          title: Text('Quips App'),
          backgroundColor: Colors.blueAccent,
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
        drawer: _buildDrawer(localizations),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(localizations),
              SizedBox(height: 20),
              _buildBalanceCard(localizations),
              SizedBox(height: 20),
              _buildActionButtons(localizations),
              SizedBox(height: 20),
              _buildNewsSection(localizations),
            ],
          ),
        ),
      ),
    );
  }

  // Sección del Header con texto localizado
  Widget _buildHeader(AppLocalizations localizations) {
    return Text(
      '${localizations.hello} $userName', // "Hello" traducido
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    );
  }

  // Sección del Balance con texto localizado
  Widget _buildBalanceCard(AppLocalizations localizations) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(FontAwesomeIcons.wallet, color: Colors.green, size: 40),
        title: Text(localizations.yourBalance, style: TextStyle(fontSize: 20)), // "Your Balance" traducido
        subtitle: Text('\$$balance', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green)),
      ),
    );
  }

  // Mejoramos los botones con gradiente y sombras suaves
  Widget _buildActionButtons(AppLocalizations localizations) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.greenAccent, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransactionPage()),
              ).then((value) {
                if (value == true) {
                  // Si la transacción fue exitosa, recargar los datos del usuario
                  _loadUserData();
                }
              });
            },
            child: Text(localizations.makeTransaction), // "Make a Transaction" traducido
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              textStyle: TextStyle(fontSize: 18),
            ),
          ),
        ),
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/contacts');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: 16.0),
            ),
            icon: Icon(FontAwesomeIcons.solidComments, size: 24),
            label: Text(
              localizations.chat, // "Chat" traducido
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // Sección del Drawer
  Widget _buildDrawer(AppLocalizations localizations) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Text(
              '${localizations.hello} $userName', // "Hello" traducido
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text(localizations.yourBalance), // "Your Balance" traducido
            subtitle: Text('\$$balance'),
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text(localizations.transactionHistory), // "Transaction History" traducido
            onTap: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(localizations.profile), // "Profile" traducido
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text(localizations.support), // "Support" traducido
            onTap: () {
              Navigator.pushNamed(context, '/support');
            },
          ),
          ListTile(
            leading: Icon(Icons.chat),
            title: Text(localizations.chat), // "Chat" traducido
            onTap: () {
              Navigator.pushNamed(context, '/contacts');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text(localizations.logOut), // "Log Out" traducido
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('jwtToken');
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  // Sección de Noticias mejorada
  Widget _buildNewsSection(AppLocalizations localizations) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.latestNews, // "Latest News" traducido
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          newsList.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final news = newsList[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mostrar imagen si hay un imageUrl disponible y limitar el tamaño
                        news.imageUrl.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            news.imageUrl,
                            height: 80,
                            width: 80, // Limitar el ancho de la imagen
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.broken_image,
                                size: 80,
                                color: Colors.red,
                              );
                            },
                          ),
                        )
                            : Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 10),
                        // Usamos Expanded para evitar el overflow del texto
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis, // Previene overflow
                              ),
                              SizedBox(height: 5),
                              Text(
                                news.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Usamos Expanded para permitir que el texto use el espacio disponible
                                  Expanded(
                                    child: Text(
                                      '${localizations.publishedAt}: ${news.publishedAt}', // "Published at" traducido
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                      overflow: TextOverflow.ellipsis, // Prevenir overflow
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward),
                                    onPressed: () {
                                      // Acción para ver más detalles de la noticia
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
