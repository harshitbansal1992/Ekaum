/// Represents a user-favourited content item (stored locally)
class FavouriteItem {
  final String type; // avdhan | video_satsang | samagam | patrika | tool
  final String id;
  final String title;
  final String? subtitle;
  /// JSON-serializable extra data for navigation (e.g. audioUrl, route params)
  final Map<String, dynamic>? extra;

  const FavouriteItem({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
    this.extra,
  });

  String get uniqueKey => '${type}_$id';

  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
        'title': title,
        'subtitle': subtitle,
        if (extra != null) 'extra': extra,
      };

  factory FavouriteItem.fromJson(Map<String, dynamic> json) => FavouriteItem(
        type: json['type'] as String,
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String?,
        extra: json['extra'] as Map<String, dynamic>?,
      );
}
