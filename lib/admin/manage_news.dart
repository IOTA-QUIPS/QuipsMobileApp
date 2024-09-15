import 'package:flutter/material.dart';
import '../model/news_model.dart';
import '../services/news_service.dart';
import 'add_edit_news.dart';

class ManageNews extends StatefulWidget {
  final String token;

  ManageNews(this.token);

  @override
  _ManageNewsState createState() => _ManageNewsState();
}

class _ManageNewsState extends State<ManageNews> {
  late NewsService _newsService;
  late Future<List<News>> _newsList;

  @override
  void initState() {
    super.initState();
    _newsService = NewsService(widget.token);
    _newsList = _newsService.getAllNews();
  }

  void _refreshNewsList() {
    setState(() {
      _newsList = _newsService.getAllNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar Noticias'),
      ),
      body: FutureBuilder<List<News>>(
        future: _newsList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar noticias'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay noticias disponibles'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final news = snapshot.data![index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(news.title, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(news.content),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditNews(
                                token: widget.token,
                                news: news,
                                isEditing: true,
                                onSave: _refreshNewsList,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _newsService.deleteNews(news.id);
                          _refreshNewsList();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditNews(
                token: widget.token,
                isEditing: false,
                onSave: _refreshNewsList,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
