import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/news_model.dart';

class NewsService {
  final String apiUrl = 'http://10.0.2.2:8080/api/news';
  final String token;

  NewsService(this.token);

  // Obtener todas las noticias
  Future<List<News>> getAllNews() async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> newsJson = json.decode(response.body);
      return newsJson.map((json) => News.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las noticias');
    }
  }

  // Agregar una nueva noticia (solo admin)
  Future<void> addNews(String title, String content) async {
    final response = await http.post(
      Uri.parse('$apiUrl/add'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'title': title, 'content': content}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al agregar la noticia');
    }
  }

  // Editar una noticia existente (solo admin)
  Future<void> editNews(int id, String title, String content) async {
    final response = await http.put(
      Uri.parse('$apiUrl/edit/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'title': title, 'content': content}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al editar la noticia');
    }
  }

  // Eliminar una noticia (solo admin)
  Future<void> deleteNews(int id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/delete/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la noticia');
    }
  }
}
