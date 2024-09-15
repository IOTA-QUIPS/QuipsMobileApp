class News {
  final int id;
  final String title;
  final String content;
  final DateTime publishedAt;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
  });

  // Constructor para crear un objeto News a partir de un JSON
  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      publishedAt: DateTime.parse(json['publishedAt']),
    );
  }

  // Método para convertir un objeto News en un JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'publishedAt': publishedAt.toIso8601String(),
    };
  }
}
