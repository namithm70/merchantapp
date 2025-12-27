import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/app_background.dart';

class DisputeIntakeScreen extends StatefulWidget {
  const DisputeIntakeScreen({super.key});

  @override
  State<DisputeIntakeScreen> createState() => _DisputeIntakeScreenState();
}

class _DisputeIntakeScreenState extends State<DisputeIntakeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderController = TextEditingController();
  final _detailsController = TextEditingController();
  String _issueType = 'Item not as described';
  String? _evidencePath;

  @override
  void dispose() {
    _orderController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _pickEvidence() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;
    setState(() => _evidencePath = image.path);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dispute submitted. We will review within 48 hours.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Dispute intake')),
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
                  Text(
                    'Tell us what happened',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add details and evidence so we can resolve the issue quickly.',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _orderController,
                    decoration: const InputDecoration(labelText: 'Order or listing ID *'),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Order or listing ID required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownMenu<String>(
                    initialSelection: _issueType,
                    label: const Text('Issue type *'),
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 'Item not as described', label: 'Item not as described'),
                      DropdownMenuEntry(value: 'Item not received', label: 'Item not received'),
                      DropdownMenuEntry(value: 'Payment issue', label: 'Payment issue'),
                      DropdownMenuEntry(value: 'Other', label: 'Other'),
                    ],
                    onSelected: (value) {
                      if (value == null) return;
                      setState(() => _issueType = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _detailsController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Details *',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Please add details' : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _pickEvidence,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Add evidence'),
                  ),
                  const SizedBox(height: 12),
                  if (_evidencePath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        File(_evidencePath!),
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        'Attach photos, receipts, or chat logs for faster resolution.',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                    ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Submit dispute'),
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
