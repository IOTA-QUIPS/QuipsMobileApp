import 'package:flutter/material.dart';
import '../model/news_model.dart';
import '../services/news_service.dart';

class AddEditNews extends StatefulWidget {
  final String token;
  final News? news;
  final bool isEditing;
  final VoidCallback onSave;

  AddEditNews({required this.token, this.news, required this.isEditing, required this.onSave});

  @override
  _AddEditNewsState createState() => _AddEditNewsState();
}

class _AddEditNewsState extends State<AddEditNews> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late NewsService _newsService;

  @override
  void initState() {
    super.initState();
    _newsService = NewsService(widget.token);
    if (widget.isEditing && widget.news != null) {
      _titleController.text = widget.news!.title;
      _contentController.text = widget.news!.content;
    }
  }

  Future<void> _saveNews() async {
    if (widget.isEditing && widget.news != null) {
      await _newsService.editNews(
        widget.news!.id,
        _titleController.text,
        _contentController.text,
      );
    } else {
      await _newsService.addNews(
        _titleController.text,
        _contentController.text,
      );
    }
    widget.onSave();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Noticia' : 'Agregar Noticia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Contenido'),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveNews,
              child: Text(widget.isEditing ? 'Guardar Cambios' : 'Agregar Noticia'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
