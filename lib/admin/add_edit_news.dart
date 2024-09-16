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
  final TextEditingController _imageUrlController = TextEditingController(); // Controlador para la URL de la imagen
  late NewsService _newsService;

  @override
  void initState() {
    super.initState();
    _newsService = NewsService(widget.token);
    if (widget.isEditing && widget.news != null) {
      _titleController.text = widget.news!.title;
      _contentController.text = widget.news!.content;
      _imageUrlController.text = widget.news!.imageUrl ?? ''; // Cargar la URL si existe
    }
  }

  Future<void> _saveNews() async {
    if (widget.isEditing && widget.news != null) {
      await _newsService.editNews(
        widget.news!.id,
        _titleController.text,
        _contentController.text,
        _imageUrlController.text, // Usar la URL ingresada
      );
    } else {
      await _newsService.addNews(
        _titleController.text,
        _contentController.text,
        _imageUrlController.text, // Usar la URL ingresada
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
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: 'URL de la Imagen'),
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
