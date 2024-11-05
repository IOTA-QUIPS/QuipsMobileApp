import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quipsapp/services/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String fullName = "Cargando...";
  String username = "Cargando...";
  String email = "Cargando...";
  String phoneNumber = "Cargando...";
  String accountNumber = "Cargando...";
  String referralCode = "Cargando...";
  double coins = 0.0;
  bool isActive = true;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token != null) {
      final response = await _authService.getUserInfo(token);
      if (response != null && !response.containsKey('error')) {
        setState(() {
          fullName = response['firstName'] + " " + response['lastName'];
          username = response['username'];
          email = response['email'];
          phoneNumber = response['phoneNumber'];
          accountNumber = response['accountNumber'];
          referralCode = response['referralCode'];
          coins = response['coins'];
          isActive = response['active'];
        });
      } else {
        print('Error al cargar los datos del usuario');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(localizations.profile),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoCard(
              icon: Icons.person,
              title: fullName,
              subtitle: localizations.fullName,
            ),
            _buildInfoCard(
              icon: Icons.person_outline,
              title: username,
              subtitle: localizations.username,
            ),
            _buildInfoCard(
              icon: Icons.email,
              title: email,
              subtitle: localizations.email,
            ),
            _buildInfoCard(
              icon: Icons.phone,
              title: phoneNumber,
              subtitle: localizations.phoneNumber,
            ),
            _buildInfoCard(
              icon: Icons.account_balance_wallet,
              title: accountNumber,
              subtitle: localizations.accountNumber,
            ),
            _buildInfoCard(
              icon: Icons.monetization_on,
              title: '\$$coins',
              subtitle: localizations.coins,
            ),
            _buildInfoCard(
              icon: Icons.link,
              title: referralCode,
              subtitle: localizations.referralCode,
              trailing: IconButton(
                icon: Icon(Icons.copy, color: Colors.amber[300]),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: referralCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.copiedToClipboard),
                    ),
                  );
                },
              ),
            ),
            _buildInfoCard(
              icon: isActive ? Icons.check_circle : Icons.error,
              title: isActive ? localizations.active : localizations.inactive,
              subtitle: localizations.accountStatus,
              iconColor: isActive ? Colors.green : Colors.red,
            ),
            SizedBox(height: 20),
            _buildActionButton(
              text: localizations.changePassword,
              color: Colors.blueAccent,
              onPressed: () {
                // Acción para cambiar la contraseña
              },
            ),
            _buildActionButton(
              text: localizations.logOut,
              color: Colors.redAccent,
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('jwtToken');
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color iconColor = Colors.amber,
  }) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 30),
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: color.withOpacity(0.5),
          elevation: 6,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
