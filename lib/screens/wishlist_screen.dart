import 'package:flutter/material.dart';
import '../data/local_store.dart';
import '../data/wishlist_store.dart';
import '../widgets/app_background.dart';
import '../widgets/feature_card.dart';
import '../widgets/listing_card.dart';
import '../widgets/section_header.dart';
import 'listing_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_active_outlined)),
        ],
      ),
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            bottom: false,
            child: ValueListenableBuilder<Set<String>>(
              valueListenable: WishlistStore.instance.wishlist,
              builder: (context, wishlist, child) {
                final listings = LocalStore.instance.combinedListings();
                final favorites = listings.where((listing) => wishlist.contains(listing.id)).toList();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    SectionHeader(
                      title: 'Saved listings',
                      subtitle: 'Track price changes and availability updates.',
                    ),
                    const SizedBox(height: 16),
                    if (favorites.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'No saved listings yet. Tap the heart icon to save items.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                        ),
                      )
                    else
                      ...favorites.map(
                        (listing) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ListingCard(
                            listing: listing,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ListingDetailScreen(listing: listing),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    FeatureCard(
                      icon: Icons.auto_graph,
                      title: 'Predictive demand alert',
                      subtitle: 'Saved items are forecasted to rise next week.',
                      tag: 'Hot',
                      actionLabel: 'Review',
                      onAction: () {},
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_active),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Enable price drop alerts to move fast on new deals.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                            ),
                          ),
                          TextButton(onPressed: () {}, child: const Text('Enable')),
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
}
