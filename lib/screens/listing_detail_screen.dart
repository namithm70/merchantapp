import 'package:flutter/material.dart';
import '../data/shipping_service.dart';
import '../data/wishlist_store.dart';
import '../models/listing.dart';
import '../widgets/app_background.dart';
import '../widgets/feature_card.dart';
import '../widgets/metric_tile.dart';
import 'pickup_schedule_screen.dart';

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({super.key, required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Listing details'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          ValueListenableBuilder(
            valueListenable: WishlistStore.instance.wishlist,
            builder: (context, wishlist, child) {
              final isSaved = WishlistStore.instance.contains(listing.id);
              return IconButton(
                onPressed: () => WishlistStore.instance.toggle(listing.id),
                icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [listing.accentColor, listing.accentColor.withValues(alpha: 0.2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(listing.icon, size: 90, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(listing.category, style: theme.textTheme.labelMedium?.copyWith(color: Colors.black54)),
                          const SizedBox(height: 6),
                          Text(
                            listing.title,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${listing.price.toStringAsFixed(0)}',
                            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text('Condition: ${listing.condition}',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MetaRow(
                  icon: Icons.place,
                  label: listing.location,
                ),
                _MetaRow(
                  icon: Icons.star,
                  label: '${listing.rating.toStringAsFixed(1)} rating',
                ),
                _MetaRow(
                  icon: Icons.verified,
                  label: listing.verifiedSeller ? 'Verified seller' : 'Seller not verified',
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI price guidance', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(
                        'Suggested range: ₹${listing.aiPriceLow.toStringAsFixed(0)} - ₹${listing.aiPriceHigh.toStringAsFixed(0)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _Badge(label: 'Demand ${listing.demandIndex}/100'),
                          const SizedBox(width: 8),
                          _Badge(label: 'Sustainability ${listing.sustainabilityScore}/100'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatusChip(
                      label: listing.shippingAvailable ? 'Shipping available' : 'Shipping off',
                      icon: Icons.local_shipping,
                      active: listing.shippingAvailable,
                    ),
                    _StatusChip(
                      label: listing.pickupAvailable ? 'Local pickup' : 'Pickup off',
                      icon: Icons.store_mall_directory,
                      active: listing.pickupAvailable,
                    ),
                    _StatusChip(
                      label: listing.crossBorderEligible ? 'Cross-border ok' : 'Local only',
                      icon: Icons.public,
                      active: listing.crossBorderEligible,
                    ),
                    _StatusChip(
                      label: listing.escrowAvailable ? 'Escrow option' : 'No escrow',
                      icon: Icons.lock,
                      active: listing.escrowAvailable,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Payment options', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                FeatureCard(
                  icon: Icons.verified_user,
                  title: 'Payment protection',
                  subtitle: 'Funds are held until delivery or pickup is confirmed.',
                  tag: 'Protected',
                ),
                const SizedBox(height: 12),
                FeatureCard(
                  icon: Icons.lock,
                  title: 'Escrow service integration',
                  subtitle: listing.escrowAvailable
                      ? 'Use third-party escrow with release on confirmation.'
                      : 'Escrow is not available for this listing.',
                  tag: listing.escrowAvailable ? 'Available' : 'Unavailable',
                  actionLabel: 'Details',
                  onAction: () {},
                ),
                const SizedBox(height: 12),
                FeatureCard(
                  icon: Icons.credit_score,
                  title: 'Buyer credit line',
                  subtitle: 'Split payments into 4 installments with instant approval.',
                  tag: 'Instant',
                  actionLabel: 'Check',
                  onAction: () {},
                ),
                const SizedBox(height: 20),
                Text('Shipping and logistics', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                FeatureCard(
                  icon: Icons.local_shipping,
                  title: 'Automated shipping integration',
                  subtitle: listing.shippingAvailable
                      ? 'Generate labels, track delivery, and sync updates.'
                      : 'Shipping is off for this listing.',
                  tag: listing.shippingAvailable ? 'Ready' : 'Off',
                  actionLabel: 'Estimate',
                  onAction: () {},
                ),
                const SizedBox(height: 12),
                FeatureCard(
                  icon: Icons.public,
                  title: 'Cross-border trade',
                  subtitle: listing.crossBorderEligible
                      ? 'Duties, taxes, and restrictions are pre-checked.'
                      : 'Local-only item, cross-border disabled.',
                  tag: listing.crossBorderEligible ? 'Eligible' : 'Local',
                  actionLabel: 'View',
                  onAction: () {},
                ),
                const SizedBox(height: 12),
                if (listing.shippingAvailable)
                  FutureBuilder<ShippingQuote>(
                    future: ShippingService.instance.fetchRates(
                      origin: listing.location,
                      destination: 'Kochi, Kerala',
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 12),
                              Text('Fetching shipping rates...', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        );
                      }
                      final quote = snapshot.data;
                      if (quote == null) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Shipping rates',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            ...quote.rates.map(
                              (rate) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${rate.carrier} · ${rate.eta}',
                                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54)),
                                    Text('₹${rate.cost.toStringAsFixed(2)}',
                                        style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield, color: theme.colorScheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Smart fraud detection active: low risk profile.',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showOfferSheet(context),
                        child: const Text('Make offer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Message seller'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Buy now with protection'),
                ),
                const SizedBox(height: 22),
                Text('Local pickup arrangement',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Propose a time window and confirm pickup in-app.',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PickupScheduleScreen(
                                listingTitle: listing.title,
                                location: listing.location,
                              ),
                            ),
                          );
                        },
                        child: const Text('Schedule'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text('Protection and dispute support',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Column(
                  children: const [
                    MetricTile(
                      icon: Icons.shield,
                      title: 'Payment protection',
                      subtitle: 'Funds are held until delivery or pickup is confirmed.',
                    ),
                    SizedBox(height: 12),
                    MetricTile(
                      icon: Icons.gavel,
                      title: 'Dispute resolution',
                      subtitle: 'Raise an issue with evidence and timeline tracking.',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOfferSheet(BuildContext context) {
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
              Text('Submit an offer', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Offer amount',
                  prefixText: '₹',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
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
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.icon,
    required this.active,
  });

  final String label;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active ? theme.colorScheme.secondary : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: active ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
