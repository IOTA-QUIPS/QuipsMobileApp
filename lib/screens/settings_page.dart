import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedTheme = 'Light';

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;
    var localeProvider = Provider.of<LocaleProvider>(context);
    Locale currentLocale = localeProvider.locale ?? Locale('en');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(localizations.settingsTitle),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSwitchTile(
              title: localizations.enableNotifications,
              icon: Icons.notifications,
              onChanged: (value) {
                // Acción para cambiar el estado de las notificaciones
              },
            ),
            SizedBox(height: 16),
            _buildDropdownTile(
              title: localizations.changeTheme,
              icon: Icons.brightness_6,
              value: _selectedTheme,
              items: ['Light', 'Dark'],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTheme = newValue;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            _buildDropdownTile(
              title: localizations.selectLanguage,
              icon: Icons.language,
              value: currentLocale,
              items: [
                Locale('en'),
                Locale('es'),
              ],
              itemLabels: ['English', 'Español'],
              onChanged: (Locale? newLocale) {
                if (newLocale != null && newLocale != currentLocale) {
                  localeProvider.setLocale(newLocale);
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        value: true,
        onChanged: onChanged,
        activeColor: Colors.amber[300],
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey[800],
        secondary: Icon(icon, color: Colors.amber[300], size: 30),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildDropdownTile<T>({
    required String title,
    required IconData icon,
    required T value,
    required List<T> items,
    List<String>? itemLabels,
    required ValueChanged<T?> onChanged,
  }) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.amber[300], size: 30),
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        trailing: DropdownButton<T>(
          dropdownColor: Colors.grey[900],
          iconEnabledColor: Colors.amber[300],
          value: value,
          items: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabels != null ? itemLabels[index] : item.toString(),
                style: TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
