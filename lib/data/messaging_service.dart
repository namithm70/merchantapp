import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/message_entry.dart';
import '../models/message_thread.dart';
import '../models/offer_state.dart';
import 'app_config.dart';
import 'notification_service.dart';

class MessagingService {
  MessagingService._();

  static final MessagingService instance = MessagingService._();

  final ValueNotifier<List<MessageThread>> threads = ValueNotifier<List<MessageThread>>([]);
  final ValueNotifier<int> messageTick = ValueNotifier<int>(0);
  final Map<String, List<MessageEntry>> _messages = {};
  final Map<String, List<DateTime>> _rateLimits = {};
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  Future<void> init() async {
    await _loadThreads();
    _connectSocket();
  }

  Future<void> _loadThreads() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.apiBaseUrl}/threads'))
          .timeout(const Duration(seconds: 3));
      final data = jsonDecode(response.body) as List<dynamic>;
      threads.value = data.map((item) => MessageThread.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      threads.value = [];
    }
  }

  Future<List<MessageEntry>> loadMessages(String threadId) async {
    if (_messages.containsKey(threadId)) {
      return _messages[threadId]!;
    }
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.apiBaseUrl}/threads/$threadId/messages'))
          .timeout(const Duration(seconds: 3));
      final data = jsonDecode(response.body) as List<dynamic>;
      final list = data.map((item) => MessageEntry.fromJson(item as Map<String, dynamic>)).toList();
      _messages[threadId] = list;
      return list;
    } catch (_) {
      _messages[threadId] = [];
      return [];
    }
  }

  void _connectSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(AppConfig.wsUrl));
      _subscription = _channel!.stream.listen(
        _handleSocketEvent,
        onError: (_) => _reconnect(),
        onDone: _reconnect,
      );
    } catch (_) {
      _reconnect();
    }
  }

  void _reconnect() {
    _subscription?.cancel();
    _subscription = null;
    Future.delayed(const Duration(seconds: 2), _connectSocket);
  }

  void _handleSocketEvent(dynamic event) {
    final payload = jsonDecode(event as String) as Map<String, dynamic>;
    final type = payload['type'] as String?;
    if (type == 'message') {
      final message = MessageEntry.fromJson(payload['payload'] as Map<String, dynamic>);
      _messages[message.threadId] = [...(_messages[message.threadId] ?? []), message];
      _updateThreadPreview(message);
      messageTick.value += 1;
      if (message.sender == 'seller') {
        NotificationService.instance.showMessage(
          title: 'New message',
          body: message.body ?? 'Attachment received',
        );
      }
    }
    if (type == 'offer') {
      final data = payload['payload'] as Map<String, dynamic>;
      final threadId = data['threadId'] as String;
      final offer = OfferState.fromJson(data['offer'] as Map<String, dynamic>);
      _updateOffer(threadId, offer);
    }
  }

  void _updateThreadPreview(MessageEntry message) {
    final updated = threads.value.map((thread) {
      if (thread.id != message.threadId) return thread;
      return thread.copyWith(
        preview: message.body ?? 'Attachment',
        lastMessageAt: message.sentAt,
        unreadCount: message.sender == 'seller' ? thread.unreadCount + 1 : thread.unreadCount,
      );
    }).toList();
    threads.value = updated;
  }

  void _updateOffer(String threadId, OfferState? offer) {
    final updated = threads.value.map((thread) {
      if (thread.id != threadId) return thread;
      return thread.copyWith(offerState: offer);
    }).toList();
    threads.value = updated;
  }

  List<MessageEntry> cachedMessages(String threadId) {
    return _messages[threadId] ?? [];
  }

  bool canSendMessage(String threadId) {
    final now = DateTime.now();
    final list = _rateLimits[threadId] ?? [];
    list.removeWhere((time) => now.difference(time).inSeconds > 60);
    return list.length < 5;
  }

  void recordSend(String threadId) {
    final list = _rateLimits[threadId] ?? [];
    list.add(DateTime.now());
    _rateLimits[threadId] = list;
  }

  Future<MessageEntry?> sendMessage({
    required String threadId,
    required String sender,
    String? body,
    String? imagePath,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/threads/$threadId/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sender': sender,
        'body': body,
        'imagePath': imagePath,
      }),
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final message = MessageEntry.fromJson(json);
    _messages[threadId] = [...(_messages[threadId] ?? []), message];
    _updateThreadPreview(message);
    messageTick.value += 1;
    return message;
  }

  void markRead(String threadId) {
    final updated = threads.value.map((thread) {
      if (thread.id != threadId) return thread;
      return thread.copyWith(unreadCount: 0);
    }).toList();
    threads.value = updated;
  }

  Future<void> toggleBlock(String threadId, bool blocked) async {
    await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/threads/$threadId/block'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'blocked': blocked}),
    );
    final updated = threads.value.map((thread) {
      if (thread.id != threadId) return thread;
      return thread.copyWith(blocked: blocked);
    }).toList();
    threads.value = updated;
  }

  Future<void> reportThread(String threadId) async {
    await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/threads/$threadId/report'),
      headers: {'Content-Type': 'application/json'},
    );
    final updated = threads.value.map((thread) {
      if (thread.id != threadId) return thread;
      return thread.copyWith(reported: true);
    }).toList();
    threads.value = updated;
  }

  OfferState? refreshOfferState(String threadId) {
    final thread = threads.value.firstWhere((item) => item.id == threadId);
    final offer = thread.offerState;
    if (offer == null || offer.status == OfferStatus.none) return offer;
    if (offer.isActive && DateTime.now().isAfter(offer.expiresAt)) {
      final expired = offer.copyWith(status: OfferStatus.expired);
      _updateOffer(threadId, expired);
      return expired;
    }
    return offer;
  }

  Future<void> updateOffer(String threadId, OfferState offer) async {
    await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/threads/$threadId/offer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(offer.toJson()),
    );
    _updateOffer(threadId, offer);
  }
}
