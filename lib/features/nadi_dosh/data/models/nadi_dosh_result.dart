class NadiDoshResult {
  final bool hasNadiDosh;
  final String nadiType;
  final String description;
  final Map<String, dynamic> details;

  NadiDoshResult({
    required this.hasNadiDosh,
    required this.nadiType,
    required this.description,
    required this.details,
  });

  factory NadiDoshResult.fromJson(Map<String, dynamic> json) {
    return NadiDoshResult(
      hasNadiDosh: json['hasNadiDosh'] ?? false,
      nadiType: json['nadiType'] ?? '',
      description: json['description'] ?? '',
      details: json['details'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasNadiDosh': hasNadiDosh,
      'nadiType': nadiType,
      'description': description,
      'details': details,
    };
  }
}

