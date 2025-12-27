import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/local_store.dart';
import '../data/pricing_service.dart';
import '../models/listing_draft.dart';
import '../widgets/app_background.dart';
import '../widgets/feature_card.dart';
import '../widgets/section_header.dart';
import '../widgets/staggered_fade_in.dart';
import 'bulk_import_screen.dart';
import 'listing_preview_screen.dart';
import 'seller_verification_screen.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();

  Timer? _draftTimer;
  Timer? _pricingTimer;
  String _condition = 'Like New';
  bool _shipping = true;
  bool _pickup = true;
  bool _autoShipping = true;
  bool _crossBorder = false;
  bool _escrow = true;
  String? _imagePath;
  DateTime _createdAt = DateTime.now();
  PricingSuggestion? _pricing;
  bool _pricingLoading = false;

  @override
  void initState() {
    super.initState();
    final draft = LocalStore.instance.draft.value;
    if (draft != null) {
      _titleController.text = draft.title;
      _categoryController.text = draft.category;
      _priceController.text = draft.price?.toStringAsFixed(0) ?? '';
      _locationController.text = draft.location;
      _condition = draft.condition.isNotEmpty ? draft.condition : _condition;
      _shipping = draft.shipping;
      _pickup = draft.pickup;
      _crossBorder = draft.crossBorder;
      _escrow = draft.escrow;
      _imagePath = draft.imagePath;
      _createdAt = draft.createdAt;
    }

    _titleController.addListener(_scheduleDraftSave);
    _categoryController.addListener(_scheduleDraftSave);
    _priceController.addListener(_scheduleDraftSave);
    _locationController.addListener(_scheduleDraftSave);

    _categoryController.addListener(_schedulePricingFetch);
    _priceController.addListener(_schedulePricingFetch);
    _schedulePricingFetch();
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    _pricingTimer?.cancel();
    _saveDraft();
    _titleController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _scheduleDraftSave() {
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 400), _saveDraft);
  }

  void _schedulePricingFetch() {
    _pricingTimer?.cancel();
    _pricingTimer = Timer(const Duration(milliseconds: 500), _fetchPricing);
  }

  Future<void> _fetchPricing() async {
    final category = _categoryController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    if (category.isEmpty) return;
    setState(() => _pricingLoading = true);
    final suggestion = await PricingService.instance.fetchSuggestion(
      category: category,
      condition: _condition,
      price: price,
    );
    if (!mounted) return;
    setState(() {
      _pricing = suggestion;
      _pricingLoading = false;
    });
  }

  void _saveDraft() {
    final draft = _buildDraft();
    LocalStore.instance.saveDraft(draft);
  }

  ListingDraft _buildDraft() {
    return ListingDraft(
      title: _titleController.text.trim(),
      category: _categoryController.text.trim(),
      condition: _condition,
      price: double.tryParse(_priceController.text.trim()),
      location: _locationController.text.trim(),
      imagePath: _imagePath,
      shipping: _shipping,
      pickup: _pickup,
      crossBorder: _crossBorder,
      escrow: _escrow,
      createdAt: _createdAt,
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;
    setState(() => _imagePath = image.path);
    _saveDraft();
  }

  void _openPreview() {
    final draft = _buildDraft();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingPreviewScreen(draft: draft),
      ),
    );
  }

  void _publish() {
    final draft = _buildDraft();
    if (!_formKey.currentState!.validate() || !draft.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete all required fields and add at least one photo.')),
      );
      return;
    }
    LocalStore.instance.publishListing(draft);
    LocalStore.instance.saveDraft(null);
    _formKey.currentState!.reset();
    _titleController.clear();
    _categoryController.clear();
    _priceController.clear();
    _locationController.clear();
    setState(() {
      _imagePath = null;
      _condition = 'Like New';
      _shipping = true;
      _pickup = true;
      _autoShipping = true;
      _crossBorder = false;
      _escrow = true;
      _createdAt = DateTime.now();
      _pricing = null;
      _pricingLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Listing published.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Create listing'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline)),
        ],
      ),
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            bottom: false,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  StaggeredFadeIn(
                    child: SectionHeader(
                      title: 'Easy listing creation',
                      subtitle: 'Guided fields with AI pricing and image recognition.',
                      actionLabel: 'Preview',
                      onAction: _openPreview,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StaggeredFadeIn(
                    delay: const Duration(milliseconds: 120),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Title *'),
                          validator: (value) =>
                              value == null || value.trim().isEmpty ? 'Title is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _categoryController,
                          decoration: const InputDecoration(labelText: 'Category *'),
                          validator: (value) =>
                              value == null || value.trim().isEmpty ? 'Category is required' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownMenu<String>(
                          label: const Text('Condition rating *'),
                          initialSelection: _condition,
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(value: 'New', label: 'New'),
                            DropdownMenuEntry(value: 'Like New', label: 'Like New'),
                            DropdownMenuEntry(value: 'Good', label: 'Good'),
                            DropdownMenuEntry(value: 'Fair', label: 'Fair'),
                            DropdownMenuEntry(value: 'For Parts', label: 'For Parts'),
                          ],
                          onSelected: (value) {
                            if (value == null) return;
                            setState(() => _condition = value);
                            _saveDraft();
                            _schedulePricingFetch();
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Price *', prefixText: '\$'),
                          validator: (value) {
                            final parsed = double.tryParse(value ?? '');
                            if (parsed == null || parsed <= 0) return 'Enter a valid price';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(labelText: 'Location *'),
                          validator: (value) =>
                              value == null || value.trim().isEmpty ? 'Location is required' : null,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.auto_awesome),
                                label: const Text('Auto-fill from image'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_imagePath != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(
                              File(_imagePath!),
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.08)),
                            ),
                            child: Center(
                              child: Text(
                                'Add at least one photo',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        FeatureCard(
                          icon: Icons.image_search,
                          title: 'Image recognition listing',
                          subtitle: 'Auto-detect category, brand, and condition from photos.',
                          tag: 'Fast',
                          actionLabel: 'Scan',
                          onAction: _pickImage,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  StaggeredFadeIn(
                    delay: const Duration(milliseconds: 220),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI pricing suggestion',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          if (_pricingLoading)
                            Text('Fetching pricing insight...',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54))
                          else if (_pricing != null)
                            Text(
                              'Based on comps, list between \$${_pricing!.low.toStringAsFixed(0)} - \$${_pricing!.high.toStringAsFixed(0)}.',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                            )
                          else
                            Text(
                              'Add a category to see AI pricing.',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                            ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _SuggestionPill(
                                  label: _pricing != null
                                      ? 'Confidence ${(_pricing!.confidence * 100).round()}%'
                                      : 'Demand 78/100'),
                              const SizedBox(width: 8),
                              _SuggestionPill(label: _pricing != null ? 'Factors ${_pricing!.factors.length}' : 'Top comps: 5'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  StaggeredFadeIn(
                    delay: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Offer shipping'),
                          subtitle: const Text('Enable automated shipping labels and tracking.'),
                          value: _shipping,
                          onChanged: (value) {
                            setState(() => _shipping = value);
                            _saveDraft();
                          },
                        ),
                        SwitchListTile(
                          title: const Text('Automated shipping integration'),
                          subtitle: const Text('Auto-generate labels with carrier tracking.'),
                          value: _autoShipping,
                          onChanged: _shipping
                              ? (value) {
                                  setState(() => _autoShipping = value);
                                  _saveDraft();
                                }
                              : null,
                        ),
                        SwitchListTile(
                          title: const Text('Offer local pickup'),
                          subtitle: const Text('Coordinate pickup time and location in-app.'),
                          value: _pickup,
                          onChanged: (value) {
                            setState(() => _pickup = value);
                            _saveDraft();
                          },
                        ),
                        SwitchListTile(
                          title: const Text('Enable cross-border trade'),
                          subtitle: const Text('Estimate duties and verify restricted items.'),
                          value: _crossBorder,
                          onChanged: (value) {
                            setState(() => _crossBorder = value);
                            _saveDraft();
                          },
                        ),
                        SwitchListTile(
                          title: const Text('Escrow service option'),
                          subtitle: const Text('Hold funds until delivery confirmation.'),
                          value: _escrow,
                          onChanged: (value) {
                            setState(() => _escrow = value);
                            _saveDraft();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  StaggeredFadeIn(
                    delay: const Duration(milliseconds: 360),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Seller verification',
                                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Text(
                                  'Complete ID verification to unlock boosted visibility.',
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SellerVerificationScreen()),
                              );
                            },
                            child: const Text('Verify'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  StaggeredFadeIn(
                    delay: const Duration(milliseconds: 420),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.colorScheme.tertiary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.upload_file),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Bulk listing import',
                                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Text(
                                  'Upload a CSV and map fields to create listings in minutes.',
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const BulkImportScreen()),
                              );
                            },
                            child: const Text('Upload'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  StaggeredFadeIn(
                    delay: const Duration(milliseconds: 470),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sustainability scoring preview',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text(
                            'Higher scores boost discovery for eco-conscious buyers.',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: 0.78,
                              minHeight: 8,
                              backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.12),
                              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Projected score: 78/100',
                              style: theme.textTheme.labelMedium?.copyWith(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  StaggeredFadeIn(
                    delay: const Duration(milliseconds: 520),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _openPreview,
                            child: const Text('Preview listing'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _publish,
                            child: const Text('Publish listing'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionPill extends StatelessWidget {
  const _SuggestionPill({required this.label});

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
