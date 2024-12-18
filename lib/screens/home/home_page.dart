import 'package:flutter/material.dart';
import 'package:quipsapp/screens/transactions/contact_list_transaction_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quipsapp/services/auth_service.dart';
import 'package:quipsapp/screens/transactions/transaction_page.dart';
import 'package:quipsapp/screens/chat/chat_list_page.dart';
import 'package:quipsapp/services/news_service.dart';
import 'package:quipsapp/model/news_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quipsapp/services/inactivity_service.dart';
import '../auth/pin_login_page.dart';
import 'news_detail_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "Loading...";
  String? userId;
  double balance = 0.0;
  String activityLevel = "No Activo"; // Nivel de actividad predeterminado
  List<News> newsList = [];
  final AuthService _authService = AuthService();
  late NewsService _newsService;
  late InactivityService _inactivityService;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadNewsData();
    _getUserActivityLevel();
    _inactivityService = InactivityService(
      timeoutInSeconds: 300,
      onInactivityDetected: _handleInactivity,
    );
    _inactivityService.start();
  }

  @override
  void dispose() {
    _inactivityService.dispose();
    super.dispose();
  }

  void _handleInactivity() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PinLoginPage()),
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
          userId = response['id'].toString();
          balance = response['coins'] != null ? response['coins'].toDouble() : 0.0;
        });
        prefs.setBool('isActive', response['active']);
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

  Future<void> _getUserActivityLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');
    if (token != null && userId != null) {
      final response = await _authService.getUserActivity(userId!, token);
      if (response != null && response.containsKey('nivelActividad')) {
        setState(() {
          activityLevel = response['nivelActividad'];
        });
      } else {
        print('Error al obtener el nivel de actividad del usuario');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: _inactivityService.resetTimer,
      onPanDown: (_) => _inactivityService.resetTimer(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: Text(
            'Quips App',
            style: TextStyle(color: Colors.amber[300], fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: Colors.amber[300]),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
        drawer: _buildDrawer(localizations),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(localizations),
              SizedBox(height: 20),
              _buildBalanceCard(localizations),
              SizedBox(height: 20),
              _buildActivityIndicator(localizations), // Semáforo de actividad
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

  Widget _buildHeader(AppLocalizations localizations) {
    String firstName = userName.split(" ")[0];

    return Text(
      '${localizations.hello} $firstName',
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber[300]),
    );
  }

  Widget _buildBalanceCard(AppLocalizations localizations) {
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(FontAwesomeIcons.wallet, color: Colors.amber[300], size: 40),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.yourBalance,
                  style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                ),
                Text(
                  'Q! $balance',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amber[300]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityIndicator(AppLocalizations localizations) {
    Color activityColor;
    switch (activityLevel) {
      case "Activo":
        activityColor = Colors.green;
        break;
      case "Normal":
        activityColor = Colors.amber;
        break;
      default:
        activityColor = Colors.red;
    }

    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizations.activityLevel,
              style: TextStyle(fontSize: 20, color: Colors.grey[400]),
            ),
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: activityColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  activityLevel,
                  style: TextStyle(
                    fontSize: 20,
                    color: activityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations localizations) {
    return Column(
      children: [
        _buildGradientButton(
          text: localizations.makeTransaction,
          icon: Icons.monetization_on,
          gradientColors: [Colors.greenAccent, Colors.green],
          onPressed: () async {
            if (!await _isUserActive()) {
              _showActivationDialog(context, localizations);
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContactListTransactionPage()),
            ).then((value) {
              if (value == true) {
                _loadUserData();
              }
            });
          },
        ),
        SizedBox(height: 20),
        _buildGradientButton(
          text: localizations.chat,
          icon: FontAwesomeIcons.solidComments,
          gradientColors: [Colors.blueAccent, Colors.lightBlue],
          onPressed: () async {
            if (!await _isUserActive()) {
              _showActivationDialog(context, localizations);
              return;
            }
            if (userId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatListPage(userId: userId!),
                ),
              );
            } else {
              print("Error: userId es nulo");
            }
          },
        ),
      ],
    );
  }

  Widget _buildDrawer(AppLocalizations localizations) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.black),
            child: Text(
              '${localizations.hello} $userName',
              style: TextStyle(color: Colors.amber[300], fontSize: 24),
            ),
          ),
          _buildDrawerItem(Icons.account_balance_wallet, localizations.yourBalance, '$balance'),
          _buildDrawerItem(Icons.history, localizations.transactionHistory, '', onTap: () {
            Navigator.pushNamed(context, '/history');
          }),
          _buildDrawerItem(Icons.person, localizations.profile, '', onTap: () {
            Navigator.pushNamed(context, '/profile');
          }),
          _buildDrawerItem(Icons.help, localizations.support, '', onTap: () {
            Navigator.pushNamed(context, '/support');
          }),
          _buildDrawerItem(Icons.logout, localizations.logOut, '', onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('jwtToken');
            Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.amber[300]),
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(color: Colors.grey)) : null,
      onTap: onTap,
    );
  }

  Widget _buildNewsSection(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.latestNews,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber[300]),
        ),
        SizedBox(height: 10),
        newsList.isEmpty
            ? Center(child: CircularProgressIndicator(color: Colors.amber[300]))
            : ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            final news = newsList[index];
            return Card(
              color: Colors.grey[900],
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: news.imageUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    news.imageUrl,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(Icons.image_not_supported, color: Colors.grey, size: 60),
                title: Text(news.title, style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  news.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[400]),
                ),
                trailing: Icon(Icons.arrow_forward, color: Colors.amber[300]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailScreen(
                        newsId: news.id,
                        newsService: _newsService,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Future<bool> _isUserActive() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isActive') ?? false;
  }

  void _showActivationDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            localizations.accountNotActivated,
            style: TextStyle(color: Colors.amber[300]),
          ),
          content: Text(
            localizations.activateAccountPrompt,
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                localizations.ok,
                style: TextStyle(color: Colors.amber[300]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.black),
        label: Text(
          text,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );
  }
}
