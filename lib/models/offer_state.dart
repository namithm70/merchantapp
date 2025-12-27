enum OfferStatus {
  none,
  pending,
  countered,
  accepted,
  declined,
  expired,
}

class OfferState {
  const OfferState({
    required this.amount,
    required this.status,
    required this.expiresAt,
    required this.lastUpdatedBy,
  });

  final double amount;
  final OfferStatus status;
  final DateTime expiresAt;
  final String lastUpdatedBy;

  bool get isActive => status == OfferStatus.pending || status == OfferStatus.countered;

  OfferState copyWith({
    double? amount,
    OfferStatus? status,
    DateTime? expiresAt,
    String? lastUpdatedBy,
  }) {
    return OfferState(
      amount: amount ?? this.amount,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'status': status.name,
      'expiresAt': expiresAt.toIso8601String(),
      'lastUpdatedBy': lastUpdatedBy,
    };
  }

  static OfferState? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return OfferState(
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: OfferStatus.values.firstWhere(
        (value) => value.name == (json['status'] as String? ?? ''),
        orElse: () => OfferStatus.none,
      ),
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '') ?? DateTime.now(),
      lastUpdatedBy: (json['lastUpdatedBy'] as String?) ?? 'buyer',
    );
  }
}
