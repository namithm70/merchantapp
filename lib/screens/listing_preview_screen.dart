import 'dart:io';

import 'package:flutter/material.dart';

import '../models/listing_draft.dart';
import '../widgets/app_background.dart';

class ListingPreviewScreen extends StatelessWidget {
  const ListingPreviewScreen({super.key, required this.draft});

  final ListingDraft draft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Preview listing'),
      ),
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                if (draft.imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(
                      File(draft.imagePath!),
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.08)),
                    ),
                    child: Center(
                      child: Text(
                        'No photo yet',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(draft.category.isEmpty ? 'Category' : draft.category,
                    style: theme.textTheme.labelMedium?.copyWith(color: Colors.black54)),
                const SizedBox(height: 6),
                Text(
                  draft.title.isEmpty ? 'Listing title' : draft.title,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      draft.price == null ? '₹0' : '₹${draft.price!.toStringAsFixed(0)}',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(draft.condition, style: theme.textTheme.labelSmall),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  draft.location.isEmpty ? 'Location' : draft.location,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 20),
                _PreviewRow(label: 'Shipping', value: draft.shipping ? 'Enabled' : 'Off'),
                _PreviewRow(label: 'Local pickup', value: draft.pickup ? 'Enabled' : 'Off'),
                _PreviewRow(label: 'Cross-border', value: draft.crossBorder ? 'Eligible' : 'Local only'),
                _PreviewRow(label: 'Escrow', value: draft.escrow ? 'Available' : 'Off'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          Text(value, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
