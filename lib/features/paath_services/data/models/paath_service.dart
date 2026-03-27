class PaathService {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool isFamilyService;
  /// 1 = one-time payment, 2-12 = that many installments
  final int installments;

  PaathService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.isFamilyService = false,
    this.installments = 6,
  });

  bool get isOneTime => installments <= 1;

  factory PaathService.fromJson(Map<String, dynamic> json) {
    return PaathService(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      isFamilyService: json['isFamilyService'] as bool? ?? false,
      installments: (json['installments'] as num?)?.toInt() ?? 6,
    );
  }
}

