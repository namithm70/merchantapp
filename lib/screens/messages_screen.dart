import 'package:flutter/material.dart';

import '../data/messaging_service.dart';
import '../models/message_thread.dart';
import '../models/offer_state.dart';
import '../widgets/app_background.dart';
import '../widgets/feature_card.dart';
import '../widgets/section_header.dart';
import '../widgets/staggered_fade_in.dart';
import 'dispute_intake_screen.dart';
import 'thread_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
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
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    StaggeredFadeIn(
                      child: SectionHeader(
                        title: 'In-app messaging',
                        subtitle: 'Negotiate, share updates, and confirm pickup details.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...threads.map(
                      (thread) => StaggeredFadeIn(
                        delay: Duration(milliseconds: 120 + threads.indexOf(thread) * 80),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ThreadScreen(threadId: thread.id),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.08)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
                                  child: Text(thread.sellerName.substring(0, 1)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(thread.listingTitle,
                                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 6),
                                      Text(thread.preview,
                                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54)),
                                      const SizedBox(height: 6),
                                      if (thread.offerState != null && thread.offerState!.status != OfferStatus.none)
                                        Text(
                                          'Offer: ₹${thread.offerState!.amount.toStringAsFixed(0)} · ${thread.offerState!.status.name}',
                                          style: theme.textTheme.labelSmall?.copyWith(color: Colors.black54),
                                        ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _timeAgo(thread.lastMessageAt),
                                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.black45),
                                    ),
                                    const SizedBox(height: 6),
                                    if (thread.unreadCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.tertiary,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          thread.unreadCount.toString(),
                                          style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    StaggeredFadeIn(
                      delay: const Duration(milliseconds: 420),
                      child: Column(
                        children: [
                          FeatureCard(
                            icon: Icons.percent,
                            title: 'Price negotiation',
                            subtitle: 'Offer, counter, and auto-expire quotes in 24 hours.',
                            tag: 'Live',
                            actionLabel: 'View',
                            onAction: () {},
                          ),
                          const SizedBox(height: 12),
                          FeatureCard(
                            icon: Icons.gavel,
                            title: 'Dispute resolution',
                            subtitle: 'Upload evidence and track SLA timelines in-app.',
                            actionLabel: 'Start',
                            onAction: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const DisputeIntakeScreen()),
                              );
                            },
                          ),
                        ],
                      ),
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

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
