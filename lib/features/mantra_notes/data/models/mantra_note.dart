/// Model for a user-stored mantra note (heading + description)
class MantraNote {
  final String id;
  final String heading;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MantraNote({
    required this.id,
    required this.heading,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory MantraNote.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }
    return MantraNote(
      id: json['id'] as String,
      heading: json['heading'] as String,
      description: (json['description'] as String?) ?? '',
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'heading': heading,
        'description': description,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
