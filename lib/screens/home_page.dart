import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quipsapp/services/auth_service.dart';
import 'package:quipsapp/screens/transaction_page.dart'; // Asegúrate de tener la ruta correcta
import 'package:quipsapp/services/news_service.dart';
import 'package:quipsapp/model/news_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
          // Acceder a coins directamente del nivel superior del JSON
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

  // Mejoramos los botones con gradiente y sombras suaves
  Widget _buildActionButtons() {
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
            child: Text('Make a Transaction'),
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
              'Chat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
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

  // Sección de Noticias
  Widget _buildNewsSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest News',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Icon(FontAwesomeIcons.newspaper, color: Colors.blueAccent),
                    title: Text(news.title, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(news.content, maxLines: 2, overflow: TextOverflow.ellipsis),
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
