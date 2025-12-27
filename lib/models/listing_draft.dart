class ListingDraft {
  ListingDraft({
    required this.title,
    required this.category,
    required this.condition,
    required this.price,
    required this.location,
    required this.imagePath,
    required this.shipping,
    required this.pickup,
    required this.crossBorder,
    required this.escrow,
    required this.createdAt,
  });

  final String title;
  final String category;
  final String condition;
  final double? price;
  final String location;
  final String? imagePath;
  final bool shipping;
  final bool pickup;
  final bool crossBorder;
  final bool escrow;
  final DateTime createdAt;

  bool get isValid {
    return title.trim().isNotEmpty &&
        category.trim().isNotEmpty &&
        condition.trim().isNotEmpty &&
        price != null &&
        location.trim().isNotEmpty &&
        imagePath != null;
  }

  ListingDraft copyWith({
    String? title,
    String? category,
    String? condition,
    double? price,
    String? location,
    String? imagePath,
    bool? shipping,
    bool? pickup,
    bool? crossBorder,
    bool? escrow,
    DateTime? createdAt,
  }) {
    return ListingDraft(
      title: title ?? this.title,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      price: price ?? this.price,
      location: location ?? this.location,
      imagePath: imagePath ?? this.imagePath,
      shipping: shipping ?? this.shipping,
      pickup: pickup ?? this.pickup,
      crossBorder: crossBorder ?? this.crossBorder,
      escrow: escrow ?? this.escrow,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'condition': condition,
      'price': price,
      'location': location,
      'imagePath': imagePath,
      'shipping': shipping,
      'pickup': pickup,
      'crossBorder': crossBorder,
      'escrow': escrow,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static ListingDraft fromJson(Map<String, dynamic> json) {
    return ListingDraft(
      title: (json['title'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      condition: (json['condition'] as String?) ?? '',
      price: (json['price'] as num?)?.toDouble(),
      location: (json['location'] as String?) ?? '',
      imagePath: json['imagePath'] as String?,
      shipping: (json['shipping'] as bool?) ?? true,
      pickup: (json['pickup'] as bool?) ?? true,
      crossBorder: (json['crossBorder'] as bool?) ?? false,
      escrow: (json['escrow'] as bool?) ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
