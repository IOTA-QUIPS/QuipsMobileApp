import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Importa las localizaciones
import 'package:provider/provider.dart'; // Importa Provider para cambiar el idioma
import '../providers/locale_provider.dart'; // Importa LocaleProvider

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Estado para controlar el tema seleccionado
  String _selectedTheme = 'Light';  // Establecemos un valor predeterminado que coincida con las opciones del menú

  @override
  Widget build(BuildContext context) {
    // Accede a las traducciones desde el archivo de localización
    var localizations = AppLocalizations.of(context)!;
    var localeProvider = Provider.of<LocaleProvider>(context);  // Accede a LocaleProvider
    Locale currentLocale = localeProvider.locale ?? Locale('en');  // Idioma actual

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsTitle), // Usa la cadena localizada para el título
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(localizations.enableNotifications), // Texto localizado para "Habilitar Notificaciones"
            value: true, // Puedes manejar este estado con un State o Provider
            onChanged: (value) {
              // Acción para cambiar el estado de las notificaciones
            },
          ),
          ListTile(
            title: Text(localizations.changeTheme), // Texto localizado para "Cambiar Tema"
            trailing: DropdownButton<String>(
              value: _selectedTheme, // Tema seleccionado, que debe coincidir con los valores de las opciones
              items: <String>[
                'Light', // Valor de "Light"
                'Dark'   // Valor de "Dark"
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTheme = newValue; // Actualiza el tema seleccionado
                  });
                }
              },
            ),
          ),
          ListTile(
            title: Text(localizations.selectLanguage), // Texto localizado para "Seleccionar Idioma"
            trailing: DropdownButton<Locale>(
              value: currentLocale,  // Idioma actual
              items: [
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: Locale('es'),
                  child: Text('Español'),
                ),
              ],
              onChanged: (Locale? newLocale) {
                if (newLocale != null && newLocale != currentLocale) {
                  localeProvider.setLocale(newLocale);  // Cambiar el idioma dinámicamente
                  setState(() {
                    // Actualiza la interfaz para reflejar el nuevo idioma
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
