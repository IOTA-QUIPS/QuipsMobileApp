import 'package:flutter/material.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  List<String> _selectedUsers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crear Grupo"), backgroundColor: Colors.teal[800]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: "Nombre del grupo",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                final userId = "user_$index";
                final username = "Usuario $index";
                return CheckboxListTile(
                  title: Text(username),
                  value: _selectedUsers.contains(userId),
                  onChanged: (isSelected) {
                    setState(() {
                      isSelected!
                          ? _selectedUsers.add(userId)
                          : _selectedUsers.remove(userId);
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[800]),
              onPressed: () {
                // Crear el grupo con el nombre y los usuarios seleccionados
              },
              child: Text("Crear Grupo"),
            ),
          ),
        ],
      ),
    );
  }
}
