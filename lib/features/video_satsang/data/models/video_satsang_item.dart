class VideoSatsangItem {
  final String id;
  final String title;
  final String description;
  final String youtubeVideoId;
  final String? thumbnailUrl;
  final int durationSeconds;
  final DateTime? createdAt;

  VideoSatsangItem({
    required this.id,
    required this.title,
    required this.description,
    required this.youtubeVideoId,
    this.thumbnailUrl,
    this.durationSeconds = 0,
    this.createdAt,
  });

  factory VideoSatsangItem.fromJson(Map<String, dynamic> json) {
    return VideoSatsangItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      youtubeVideoId: json['youtubeVideoId'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'youtubeVideoId': youtubeVideoId,
        'thumbnailUrl': thumbnailUrl,
        'durationSeconds': durationSeconds,
        'createdAt': createdAt?.toIso8601String(),
      };

  String get youtubeWatchUrl => 'https://www.youtube.com/watch?v=$youtubeVideoId';
  String get youtubeEmbedUrl => 'https://www.youtube.com/embed/$youtubeVideoId';
  String get thumbnailUrlDefault => 'https://img.youtube.com/vi/$youtubeVideoId/hqdefault.jpg';
}
