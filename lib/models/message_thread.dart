import 'offer_state.dart';

class MessageThread {
  const MessageThread({
    required this.id,
    required this.listingTitle,
    required this.preview,
    required this.unreadCount,
    required this.sellerName,
    required this.lastMessageAt,
    required this.blocked,
    required this.reported,
    required this.offerState,
  });

  final String id;
  final String listingTitle;
  final String preview;
  final int unreadCount;
  final String sellerName;
  final DateTime lastMessageAt;
  final bool blocked;
  final bool reported;
  final OfferState? offerState;

  MessageThread copyWith({
    String? preview,
    int? unreadCount,
    DateTime? lastMessageAt,
    bool? blocked,
    bool? reported,
    OfferState? offerState,
  }) {
    return MessageThread(
      id: id,
      listingTitle: listingTitle,
      preview: preview ?? this.preview,
      unreadCount: unreadCount ?? this.unreadCount,
      sellerName: sellerName,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      blocked: blocked ?? this.blocked,
      reported: reported ?? this.reported,
      offerState: offerState ?? this.offerState,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listingTitle': listingTitle,
      'preview': preview,
      'unreadCount': unreadCount,
      'sellerName': sellerName,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'blocked': blocked,
      'reported': reported,
      'offerState': offerState?.toJson(),
    };
  }

  static MessageThread fromJson(Map<String, dynamic> json) {
    return MessageThread(
      id: json['id'] as String? ?? '',
      listingTitle: json['listingTitle'] as String? ?? '',
      preview: json['preview'] as String? ?? '',
      unreadCount: json['unreadCount'] as int? ?? 0,
      sellerName: json['sellerName'] as String? ?? '',
      lastMessageAt: DateTime.tryParse(json['lastMessageAt'] as String? ?? '') ?? DateTime.now(),
      blocked: json['blocked'] as bool? ?? false,
      reported: json['reported'] as bool? ?? false,
      offerState: OfferState.fromJson(json['offerState'] as Map<String, dynamic>?),
    );
  }
}
