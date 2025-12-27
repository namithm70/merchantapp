import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/listing.dart';
import '../models/listing_draft.dart';
import '../models/message_entry.dart';
import '../models/message_thread.dart';
import '../models/offer_state.dart';
import 'mock_data.dart';

class LocalStore {
  LocalStore._();

  static final LocalStore instance = LocalStore._();

  static const _draftKey = 'draft_listing';
  static const _publishedKey = 'published_listings';
  static const _threadsKey = 'message_threads';
  static const _messagesKey = 'message_entries';
  static const _rateLimitKey = 'thread_rate_limits';

  SharedPreferences? _prefs;

  final ValueNotifier<ListingDraft?> draft = ValueNotifier<ListingDraft?>(null);
  final ValueNotifier<List<ListingDraft>> publishedListings = ValueNotifier<List<ListingDraft>>([]);
  final ValueNotifier<List<MessageThread>> threads = ValueNotifier<List<MessageThread>>([]);

  final Map<String, List<MessageEntry>> _messages = {};
  final Map<String, List<DateTime>> _rateLimits = {};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadDraft();
    _loadPublished();
    _loadThreads();
    _loadMessages();
    _loadRateLimits();
  }

  void _loadDraft() {
    final raw = _prefs?.getString(_draftKey);
    if (raw == null) return;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    draft.value = ListingDraft.fromJson(json);
  }

  void saveDraft(ListingDraft? value) {
    draft.value = value;
    if (value == null) {
      _prefs?.remove(_draftKey);
    } else {
      _prefs?.setString(_draftKey, jsonEncode(value.toJson()));
    }
  }

  void _loadPublished() {
    final raw = _prefs?.getString(_publishedKey);
    if (raw == null) return;
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    publishedListings.value = list.map(ListingDraft.fromJson).toList();
  }

  void publishListing(ListingDraft listing) {
    final updated = [...publishedListings.value, listing];
    publishedListings.value = updated;
    _prefs?.setString(_publishedKey, jsonEncode(updated.map((item) => item.toJson()).toList()));
  }

  void _loadThreads() {
    final raw = _prefs?.getString(_threadsKey);
    if (raw == null) {
      threads.value = seedThreads;
      _persistThreads();
      return;
    }
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    threads.value = list.map(MessageThread.fromJson).toList();
  }

  void _persistThreads() {
    _prefs?.setString(_threadsKey, jsonEncode(threads.value.map((thread) => thread.toJson()).toList()));
  }

  void updateThread(MessageThread thread) {
    final updated = threads.value.map((item) => item.id == thread.id ? thread : item).toList();
    threads.value = updated;
    _persistThreads();
  }

  void _loadMessages() {
    final raw = _prefs?.getString(_messagesKey);
    if (raw == null) {
      _messages.addAll(seedMessages);
      _persistMessages();
      return;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    decoded.forEach((key, value) {
      final list = (value as List).cast<Map<String, dynamic>>();
      _messages[key] = list.map(MessageEntry.fromJson).toList();
    });
  }

  void _persistMessages() {
    final jsonMap = _messages.map((key, value) => MapEntry(key, value.map((item) => item.toJson()).toList()));
    _prefs?.setString(_messagesKey, jsonEncode(jsonMap));
  }

  void _loadRateLimits() {
    final raw = _prefs?.getString(_rateLimitKey);
    if (raw == null) return;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    decoded.forEach((key, value) {
      final list = (value as List)
          .map((entry) => DateTime.tryParse(entry as String? ?? '') ?? DateTime.now())
          .toList();
      _rateLimits[key] = list;
    });
  }

  void _persistRateLimits() {
    final jsonMap = _rateLimits.map(
      (key, value) => MapEntry(key, value.map((item) => item.toIso8601String()).toList()),
    );
    _prefs?.setString(_rateLimitKey, jsonEncode(jsonMap));
  }

  List<MessageEntry> messagesForThread(String threadId) {
    final messages = _messages[threadId] ?? [];
    messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return messages;
  }

  bool canSendMessage(String threadId) {
    final now = DateTime.now();
    final list = _rateLimits[threadId] ?? [];
    list.removeWhere((time) => now.difference(time).inSeconds > 60);
    return list.length < 5;
  }

  void recordMessageSend(String threadId) {
    final list = _rateLimits[threadId] ?? [];
    list.add(DateTime.now());
    _rateLimits[threadId] = list;
    _persistRateLimits();
  }

  void addMessage(MessageEntry message, {bool incrementUnread = false}) {
    final list = _messages[message.threadId] ?? [];
    list.add(message);
    _messages[message.threadId] = list;
    _persistMessages();

    final thread = threads.value.firstWhere((item) => item.id == message.threadId);
    final updatedThread = thread.copyWith(
      preview: message.body ?? 'Attachment',
      lastMessageAt: message.sentAt,
      unreadCount: incrementUnread ? thread.unreadCount + 1 : thread.unreadCount,
    );
    updateThread(updatedThread);
  }

  void markThreadRead(String threadId) {
    final thread = threads.value.firstWhere((item) => item.id == threadId);
    updateThread(thread.copyWith(unreadCount: 0));
  }

  void toggleBlock(String threadId) {
    final thread = threads.value.firstWhere((item) => item.id == threadId);
    updateThread(thread.copyWith(blocked: !thread.blocked));
  }

  void reportThread(String threadId) {
    final thread = threads.value.firstWhere((item) => item.id == threadId);
    updateThread(thread.copyWith(reported: true));
  }

  OfferState? refreshOfferState(String threadId) {
    final thread = threads.value.firstWhere((item) => item.id == threadId);
    final offer = thread.offerState;
    if (offer == null || offer.status == OfferStatus.none) return offer;
    if (offer.isActive && DateTime.now().isAfter(offer.expiresAt)) {
      final expired = offer.copyWith(status: OfferStatus.expired);
      updateThread(thread.copyWith(offerState: expired));
      return expired;
    }
    return offer;
  }

  void updateOffer(String threadId, OfferState offer) {
    final thread = threads.value.firstWhere((item) => item.id == threadId);
    updateThread(thread.copyWith(offerState: offer));
  }

  List<Listing> combinedListings() {
    final drafted = publishedListings.value.map(_toListing).toList();
    return [...drafted, ...sampleListings];
  }

  Listing _toListing(ListingDraft draft) {
    final icon = _iconForCategory(draft.category);
    final accent = _colorForCategory(draft.category);
    return Listing(
      id: 'local-${draft.createdAt.millisecondsSinceEpoch}',
      title: draft.title,
      category: draft.category,
      condition: draft.condition,
      price: draft.price ?? 0,
      location: draft.location,
      sellerName: 'You',
      verifiedSeller: true,
      rating: 4.9,
      sustainabilityScore: 80,
      demandIndex: 75,
      aiPriceLow: (draft.price ?? 0) * 0.9,
      aiPriceHigh: (draft.price ?? 0) * 1.1,
      shippingAvailable: draft.shipping,
      pickupAvailable: draft.pickup,
      crossBorderEligible: draft.crossBorder,
      escrowAvailable: draft.escrow,
      icon: icon,
      accentColor: accent,
    );
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.speaker;
      case 'outdoor':
        return Icons.directions_bike;
      case 'fashion':
        return Icons.work_outline;
      case 'home':
        return Icons.coffee;
      case 'auto':
        return Icons.tire_repair;
      default:
        return Icons.inventory_2;
    }
  }

  Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return const Color(0xFF2A9D8F);
      case 'outdoor':
        return const Color(0xFFE9C46A);
      case 'fashion':
        return const Color(0xFFE76F51);
      case 'home':
        return const Color(0xFF3D5A80);
      case 'auto':
        return const Color(0xFF8E9AAF);
      default:
        return const Color(0xFF7F8C8D);
    }
  }
}
