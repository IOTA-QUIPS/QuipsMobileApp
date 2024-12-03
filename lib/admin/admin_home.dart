import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quipsapp/services/auth_service.dart';
import 'package:quipsapp/screens/transactions/transaction_page.dart';
import 'package:quipsapp/services/news_service.dart';
import 'package:quipsapp/model/news_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'manage_news.dart'; // Para la gestión de noticias

class AdminHome extends StatefulWidget {
  final String token;

  AdminHome(this.token);

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String userName = "Loading...";
  double balance = 0.0;
  List<News> newsList = [];
  final AuthService _authService = AuthService();
  late NewsService _newsService;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadNewsData();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
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
      drawer: _buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            _buildBalanceCard(),
            SizedBox(height: 20),
            _buildActionButtons(),
            SizedBox(height: 20),
            _buildManageNewsButton(), // Botón para gestionar noticias
            SizedBox(height: 20),
            _buildNewsSection(),
          ],
        ),
      ),
    );
  }

  // Sección del Header
  Widget _buildHeader() {
    return Text(
      'Hello, $userName',
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    );
  }

  // Sección del Balance
  Widget _buildBalanceCard() {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(FontAwesomeIcons.wallet, color: Colors.green, size: 40),
        title: Text('Your Balance', style: TextStyle(fontSize: 20)),
        subtitle: Text('\$$balance', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green)),
      ),
    );
  }

  // Botones para Acciones de Usuario
  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildGradientButton(
          label: 'Make a Transaction',
          icon: FontAwesomeIcons.moneyBillTransfer,
          color1: Colors.greenAccent,
          color2: Colors.green,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TransactionPage()),
            ).then((value) {
              if (value == true) {
                _loadUserData();
              }
            });
          },
        ),
        SizedBox(height: 20),
        _buildGradientButton(
          label: 'Chat',
          icon: FontAwesomeIcons.solidComments,
          color1: Colors.blueAccent,
          color2: Colors.lightBlue,
          onPressed: () {
            Navigator.pushNamed(context, '/contacts');
          },
        ),
      ],
    );
  }

  // Botón para gestionar noticias (solo admin)
  Widget _buildManageNewsButton() {
    return _buildGradientButton(
      label: 'Manage News',
      icon: FontAwesomeIcons.newspaper,
      color1: Colors.deepOrangeAccent,
      color2: Colors.orange,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ManageNews(widget.token)),
        );
      },
    );
  }

  // Método reutilizable para botones con gradiente
  Widget _buildGradientButton({
    required String label,
    required IconData icon,
    required Color color1,
    required Color color2,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color1.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );
  }

  // Sección del Drawer
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Text(
              'Hello, $userName',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text('Your Balance'),
            subtitle: Text('\$$balance'),
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Transaction History'),
            onTap: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Support'),
            onTap: () {
              Navigator.pushNamed(context, '/support');
            },
          ),
          ListTile(
            leading: Icon(Icons.chat),
            title: Text('Chat'),
            onTap: () {
              Navigator.pushNamed(context, '/contacts');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log Out'),
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
  Widget _buildNewsSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest News',
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
                        // Mostrar imagen si hay un imageUrl disponible
                        news.imageUrl.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            news.imageUrl,
                            height: 80,
                            width: 80,
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
                                overflow: TextOverflow.ellipsis,
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
                                  Expanded(
                                    child: Text(
                                      'Published at: ${news.publishedAt}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                      overflow: TextOverflow.ellipsis,
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
