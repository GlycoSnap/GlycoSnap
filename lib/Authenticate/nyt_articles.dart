class Article {
  final String title;
  final String description;
  final String content;
  final String url;

  Article({
    required this.title,
    required this.description,
    required this.content,
    required this.url,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['headline']?['main'] ?? 'No Title',
      description: json['snippet'] ?? 'No Description',
      content: json['lead_paragraph'] ?? 'No Content',
      url: json['web_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'url': url,
    };
  }
}
