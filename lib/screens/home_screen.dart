import 'package:flutter/material.dart';
import '../data/local_store.dart';
import '../data/mock_data.dart';
import '../models/listing.dart';
import '../widgets/app_background.dart';
import '../widgets/listing_card.dart';
import '../widgets/metric_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/staggered_fade_in.dart';
import 'listing_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _conditionFilter = 'All';

  static const List<String> _conditions = [
    'All',
    'New',
    'Like New',
    'Good',
    'Fair',
    'For Parts',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 100),
                  child: _HeroHeader(theme: theme),
                ),
                const SizedBox(height: 24),
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 220),
                  child: SectionHeader(
                    title: 'Categories',
                    subtitle: 'Filter by condition, distance, and verified sellers.',
                    actionLabel: 'View all',
                    onAction: () {},
                  ),
                ),
                const SizedBox(height: 12),
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 260),
                  child: SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return Chip(label: Text(categories[index]));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 280),
                  child: Row(
                    children: [
                      Text('Condition', style: theme.textTheme.titleSmall),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _conditions.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final condition = _conditions[index];
                              final selected = condition == _conditionFilter;
                              return FilterChip(
                                selected: selected,
                                label: Text(condition),
                                onSelected: (_) {
                                  setState(() => _conditionFilter = condition);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 300),
                  child: SectionHeader(
                    title: 'Trending near you',
                    subtitle: 'High demand listings with payment protection.',
                  ),
                ),
                const SizedBox(height: 14),
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 340),
                  child: ValueListenableBuilder(
                    valueListenable: LocalStore.instance.publishedListings,
                    builder: (context, value, child) {
                      final listings = _filteredListings();
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = _columnsForWidth(constraints.maxWidth);
                          final ratio = _cardAspectRatioForColumns(columns);
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: listings.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: ratio,
                            ),
                            itemBuilder: (context, index) {
                              final listing = listings[index];
                              return ListingCard(
                                listing: listing,
                                onTap: () => _openListing(context, listing),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 420),
                  child: SectionHeader(
                    title: 'Trust and protection',
                    subtitle: 'Built-in safeguards across every transaction.',
                  ),
                ),
                const SizedBox(height: 14),
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 460),
                  child: Column(
                    children: const [
                      MetricTile(
                        icon: Icons.verified_user,
                        title: 'Seller verification',
                        subtitle: 'Identity checks and trust badges for top sellers.',
                      ),
                      SizedBox(height: 12),
                      MetricTile(
                        icon: Icons.shield,
                        title: 'Payment protection',
                        subtitle: 'Funds held until pickup or delivery confirmed.',
                      ),
                      SizedBox(height: 12),
                      MetricTile(
                        icon: Icons.gavel,
                        title: 'Dispute resolution',
                        subtitle: 'Evidence upload and admin-led outcomes.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 520),
                  child: SectionHeader(
                    title: 'Local pickup playbook',
                    subtitle: 'Coordinate safe, fast exchanges with built-in guidance.',
                  ),
                ),
                const SizedBox(height: 12),
                StaggeredFadeIn(
                  delay: const Duration(milliseconds: 560),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.handshake, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pick up in under 24 hours',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(
                                'Share availability, agree on a location, and confirm completion.',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _columnsForWidth(double width) {
    if (width >= 1100) {
      return 3;
    }
    if (width >= 760) {
      return 2;
    }
    return 1;
  }

  double _cardAspectRatioForColumns(int columns) {
    if (columns == 1) {
      return 1.18;
    }
    if (columns == 2) {
      return 0.95;
    }
    return 0.82;
  }

  List<Listing> _filteredListings() {
    final listings = LocalStore.instance.combinedListings();
    if (_conditionFilter == 'All') return listings;
    return listings.where((listing) => listing.condition == _conditionFilter).toList();
  }

  void _openListing(BuildContext context, Listing listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(listing: listing),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find your next verified deal.',
                style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'AI pricing, protected payments, and local pickup in one flow.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 18),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search listings or categories',
                  prefixIcon: const Icon(Icons.search),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _QuickAction(
                    icon: Icons.tune,
                    label: 'Filters',
                    onTap: () {},
                  ),
                  _QuickAction(
                    icon: Icons.flash_on,
                    label: 'Hot offers',
                    onTap: () {},
                  ),
                  _QuickAction(
                    icon: Icons.shield,
                    label: 'Protected',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
