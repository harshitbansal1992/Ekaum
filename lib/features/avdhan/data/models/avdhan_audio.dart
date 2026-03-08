class AvdhanAudio {
  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final int duration; // in seconds

  AvdhanAudio({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    this.thumbnailUrl,
    required this.createdAt,
    required this.duration,
  });

  factory AvdhanAudio.fromJson(Map<String, dynamic> json) {
    return AvdhanAudio(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      audioUrl: (json['audioUrl'] ?? '').toString().replaceAll('localhost', '192.168.0.106'),
      thumbnailUrl: json['thumbnailUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      duration: json['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'audioUrl': audioUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt.toIso8601String(),
      'duration': duration,
    };
  }
}

