class PatrikaIssue {
  final String id;
  final String title;
  final String month;
  final int year;
  final String pdfUrl;
  final String? coverImageUrl;
  final DateTime publishedDate;
  final double price;

  PatrikaIssue({
    required this.id,
    required this.title,
    required this.month,
    required this.year,
    required this.pdfUrl,
    required this.publishedDate,
    required this.price,
    this.coverImageUrl,
  });

  factory PatrikaIssue.fromJson(Map<String, dynamic> json) {
    return PatrikaIssue(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      month: json['month'] ?? '',
      year: json['year'] ?? 0,
      pdfUrl: json['pdfUrl'] ?? '',
      coverImageUrl: json['coverImageUrl'],
      publishedDate: DateTime.parse(json['publishedDate']),
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'month': month,
      'year': year,
      'pdfUrl': pdfUrl,
      'coverImageUrl': coverImageUrl,
      'publishedDate': publishedDate.toIso8601String(),
      'price': price,
    };
  }
}

