class NewsItem {
  final String title;
  final String description;
  final String source;
  final String date;
  final String? url;

  NewsItem({
    required this.title,
    required this.description,
    required this.source,
    required this.date,
    this.url,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'],
      description: json['description'],
      source: json['source'],
      date: json['date'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'source': source,
      'date': date,
      'url': url,
    };
  }
} 