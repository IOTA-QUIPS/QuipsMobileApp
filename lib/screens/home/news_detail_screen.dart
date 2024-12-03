import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/news_model.dart';
import '../../services/news_service.dart';

class NewsDetailScreen extends StatelessWidget {
  final int newsId;
  final NewsService newsService;

  NewsDetailScreen({required this.newsId, required this.newsService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de la Noticia'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<News?>(
        future: newsService.getNewsById(newsId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar la noticia'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Noticia no encontrada'));
          }

          final news = snapshot.data!;
          return _buildNewsContent(context, news);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd MMMM yyyy, hh:mm a');
    return formatter.format(date);
  }

  Widget _buildNewsContent(BuildContext context, News news) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de la noticia
          if (news.imageUrl.isNotEmpty)
            Image.network(
              news.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250,
            )
          else
            Container(
              color: Colors.grey[300],
              width: double.infinity,
              height: 250,
              child: Icon(Icons.image, size: 100, color: Colors.grey[600]),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título de la noticia
                Text(
                  news.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
                SizedBox(height: 8),
                // Fecha de publicación
                Text(
                  'Publicado el: ${_formatDate(news.publishedAt)}',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(height: 16),
                // Contenido de la noticia
                Text(
                  news.content,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
