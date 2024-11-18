import 'package:flutter/material.dart';

class GroupInfoPage extends StatelessWidget {
  final String groupId;
  final String groupName;

  GroupInfoPage({required this.groupId, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(groupName)),
      body: Column(
        children: [
          ListTile(title: Text("Nombre del Grupo: $groupName")),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Simulación de lista de participantes
              itemBuilder: (context, index) {
                final participantName = "Miembro $index";
                return ListTile(
                  title: Text(participantName),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navegar a pantalla de agregar miembro o quitar miembro
            },
            child: Text("Gestionar Miembros"),
          ),
        ],
      ),
    );
  }
}
