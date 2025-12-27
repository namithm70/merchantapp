class MessageEntry {
  const MessageEntry({
    required this.id,
    required this.threadId,
    required this.sender,
    required this.body,
    required this.imagePath,
    required this.sentAt,
  });

  final String id;
  final String threadId;
  final String sender;
  final String? body;
  final String? imagePath;
  final DateTime sentAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'threadId': threadId,
      'sender': sender,
      'body': body,
      'imagePath': imagePath,
      'sentAt': sentAt.toIso8601String(),
    };
  }

  static MessageEntry fromJson(Map<String, dynamic> json) {
    return MessageEntry(
      id: json['id'] as String? ?? '',
      threadId: json['threadId'] as String? ?? '',
      sender: json['sender'] as String? ?? 'buyer',
      body: json['body'] as String?,
      imagePath: json['imagePath'] as String?,
      sentAt: DateTime.tryParse(json['sentAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
