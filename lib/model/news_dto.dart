class NewsDTO {
  final Source? source;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  const NewsDTO(
      {required this.source,
      required this.author,
      required this.title,
      required this.description,
      required this.url,
      required this.urlToImage,
      required this.publishedAt,
      required this.content});

  factory NewsDTO.fromJson(Map<String, dynamic> json) {
    return NewsDTO(
        source: Source.fromJSON(json['source']),
        author: json['author'],
        title: json['title'],
        description: json['description'],
        url: json['url'],
        urlToImage: json['urlToImage'],
        publishedAt: json['publishedAt'],
        content: json['content']);
  }
}

class Source {
  final String? id;
  final String? name;

  const Source({required this.id, required this.name});

  factory Source.fromJSON(Map<String, dynamic> json) {
    return Source(id: json['id'], name: json['name']);
  }
}
