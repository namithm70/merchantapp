import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/messaging_service.dart';
import '../models/message_entry.dart';
import '../models/message_thread.dart';
import '../models/offer_state.dart';
import '../widgets/app_background.dart';

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({super.key, required this.threadId});

  final String threadId;

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final _messageController = TextEditingController();
  late Future<List<MessageEntry>> _messagesFuture;

  @override
  void initState() {
    super.initState();
    MessagingService.instance.markRead(widget.threadId);
    _messagesFuture = MessagingService.instance.loadMessages(widget.threadId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Conversation'),
        actions: [
          IconButton(
            onPressed: _simulateReply,
            icon: const Icon(Icons.bolt),
            tooltip: 'Simulate reply',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenu,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'block', child: Text('Block / Unblock')),
              const PopupMenuItem(value: 'report', child: Text('Report')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            bottom: false,
            child: ValueListenableBuilder<List<MessageThread>>(
              valueListenable: MessagingService.instance.threads,
              builder: (context, threads, child) {
                final thread = threads.firstWhere((item) => item.id == widget.threadId);
                final offer = MessagingService.instance.refreshOfferState(widget.threadId);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(thread.listingTitle,
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text('Seller: ${thread.sellerName}',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54)),
                          if (thread.blocked)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: _Banner(
                                icon: Icons.block,
                                text: 'You blocked this seller. Messaging is disabled.',
                              ),
                            ),
                          if (thread.reported)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: _Banner(
                                icon: Icons.report,
                                text: 'Reported. Trust & Safety will follow up.',
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<List<MessageEntry>>(
                        future: _messagesFuture,
                        builder: (context, snapshot) {
                          return ValueListenableBuilder<int>(
                            valueListenable: MessagingService.instance.messageTick,
                            builder: (context, tick, child) {
                              final messages = MessagingService.instance.cachedMessages(widget.threadId);
                              if (messages.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              return ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                                itemCount: messages.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return _OfferSummary(
                                      offer: offer,
                                      onMakeOffer: () => _showOfferSheet(context, isCounter: false),
                                      onCounter: () => _showOfferSheet(context, isCounter: true),
                                      onAccept: _acceptOffer,
                                    );
                                  }
                                  final message = messages[index - 1];
                                  final isBuyer = message.sender == 'buyer';
                                  return Align(
                                    alignment: isBuyer ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(12),
                                      constraints: const BoxConstraints(maxWidth: 280),
                                      decoration: BoxDecoration(
                                        color: isBuyer
                                            ? theme.colorScheme.primary.withValues(alpha: 0.12)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isBuyer
                                              ? theme.colorScheme.primary.withValues(alpha: 0.2)
                                              : theme.colorScheme.primary.withValues(alpha: 0.08),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            isBuyer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                        children: [
                                          if (message.imagePath != null)
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.file(
                                                File(message.imagePath!),
                                                width: 220,
                                                height: 140,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          if (message.body != null)
                                            Padding(
                                              padding: EdgeInsets.only(top: message.imagePath != null ? 8 : 0),
                                              child: Text(message.body!, style: theme.textTheme.bodyMedium),
                                            ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _formatTime(message.sentAt),
                                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.black45),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    _Composer(
                      controller: _messageController,
                      onSend: thread.blocked ? null : _sendMessage,
                      onAttach: thread.blocked ? null : _attachImage,
                      rateLimited: !MessagingService.instance.canSendMessage(widget.threadId),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMenu(String value) async {
    if (value == 'block') {
      final thread = MessagingService.instance.threads.value.firstWhere((item) => item.id == widget.threadId);
      await MessagingService.instance.toggleBlock(widget.threadId, !thread.blocked);
      return;
    }
    if (value == 'report') {
      await MessagingService.instance.reportThread(widget.threadId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted.')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (!MessagingService.instance.canSendMessage(widget.threadId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Too many messages. Try again in a minute.')),
      );
      return;
    }
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    MessagingService.instance.recordSend(widget.threadId);
    await MessagingService.instance.sendMessage(
      threadId: widget.threadId,
      sender: 'buyer',
      body: text,
    );
    _messageController.clear();
    setState(() {});
  }

  Future<void> _attachImage() async {
    if (!MessagingService.instance.canSendMessage(widget.threadId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Too many messages. Try again in a minute.')),
      );
      return;
    }
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;
    MessagingService.instance.recordSend(widget.threadId);
    await MessagingService.instance.sendMessage(
      threadId: widget.threadId,
      sender: 'buyer',
      imagePath: image.path,
    );
    setState(() {});
  }

  Future<void> _simulateReply() async {
    await MessagingService.instance.sendMessage(
      threadId: widget.threadId,
      sender: 'seller',
      body: 'Thanks! Let me check and confirm shortly.',
    );
    setState(() {});
  }

  void _showOfferSheet(BuildContext context, {required bool isCounter}) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isCounter ? 'Counter offer' : 'Make an offer',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Offer amount',
                  prefixText: '\$',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final value = double.tryParse(controller.text.trim());
                        if (value == null || value <= 0) {
                          return;
                        }
                        _submitOffer(value, isCounter: isCounter);
                        Navigator.pop(context);
                      },
                      child: const Text('Send offer'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitOffer(double amount, {required bool isCounter}) async {
    final status = isCounter ? OfferStatus.countered : OfferStatus.pending;
    final offer = OfferState(
      amount: amount,
      status: status,
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      lastUpdatedBy: 'buyer',
    );
    await MessagingService.instance.updateOffer(widget.threadId, offer);
    await MessagingService.instance.sendMessage(
      threadId: widget.threadId,
      sender: 'buyer',
      body: 'Offer sent: \$${amount.toStringAsFixed(0)}',
    );
    setState(() {});
  }

  Future<void> _acceptOffer() async {
    final offer = MessagingService.instance.refreshOfferState(widget.threadId);
    if (offer == null) return;
    final accepted = offer.copyWith(status: OfferStatus.accepted, expiresAt: DateTime.now());
    await MessagingService.instance.updateOffer(widget.threadId, accepted);
    await MessagingService.instance.sendMessage(
      threadId: widget.threadId,
      sender: 'buyer',
      body: 'Accepted offer: \$${offer.amount.toStringAsFixed(0)}',
    );
    setState(() {});
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.onAttach,
    required this.rateLimited,
  });

  final TextEditingController controller;
  final VoidCallback? onSend;
  final VoidCallback? onAttach;
  final bool rateLimited;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: rateLimited ? null : onAttach,
            icon: const Icon(Icons.attach_file),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !rateLimited && onSend != null,
              decoration: InputDecoration(
                hintText: rateLimited ? 'Slow down to avoid spam...' : 'Type a message',
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: rateLimited ? null : onSend,
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

class _OfferSummary extends StatelessWidget {
  const _OfferSummary({
    required this.offer,
    required this.onMakeOffer,
    required this.onCounter,
    required this.onAccept,
  });

  final OfferState? offer;
  final VoidCallback onMakeOffer;
  final VoidCallback onCounter;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (offer == null || offer!.status == OfferStatus.none) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: OutlinedButton.icon(
          onPressed: onMakeOffer,
          icon: const Icon(Icons.percent),
          label: const Text('Make an offer'),
        ),
      );
    }

    final status = offer!.status;
    final expiresIn = offer!.expiresAt.difference(DateTime.now());
    final expiryLabel = expiresIn.isNegative ? 'Expired' : 'Expires in ${expiresIn.inHours}h';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Offer status', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            '\$${offer!.amount.toStringAsFixed(0)} · ${status.name} · $expiryLabel',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (status == OfferStatus.countered)
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    child: const Text('Accept'),
                  ),
                ),
              if (status == OfferStatus.countered) const SizedBox(width: 8),
              if (status == OfferStatus.countered)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCounter,
                    child: const Text('Counter'),
                  ),
                ),
              if (status == OfferStatus.expired || status == OfferStatus.declined)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onMakeOffer,
                    child: const Text('New offer'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.tertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
