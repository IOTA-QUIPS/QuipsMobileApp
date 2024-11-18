import 'package:intl/intl.dart'; // Asegúrate de importar intl para el formateo de fechas

class News {
  final int id;
  final String title;
  final String content;
  final DateTime publishedAt;
  final String imageUrl;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
    required this.imageUrl,
  });

  // Constructor para crear un objeto News a partir de un JSON
  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      publishedAt: DateTime.parse(json['publishedAt']),
      imageUrl: json['imageUrl'],
    );
  }

  // Método para convertir un objeto News en un JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'publishedAt': publishedAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  // Propiedad para obtener la fecha formateada
  String get formattedPublishedAt {
    return DateFormat('d \'de\' MMMM \'de\' yyyy, h:mm a', 'es_ES').format(publishedAt);
  }
}
