import 'package:flutter/material.dart';

import '../data/local_store.dart';
import '../models/listing_draft.dart';
import '../widgets/app_background.dart';

class BulkImportScreen extends StatefulWidget {
  const BulkImportScreen({super.key});

  @override
  State<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends State<BulkImportScreen> {
  final _controller = TextEditingController();
  List<_CsvRow> _rows = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _parseCsv() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final lines = text.split(RegExp(r'\r?\n')).where((line) => line.trim().isNotEmpty).toList();
    if (lines.length < 2) {
      setState(() {
        _rows = [
          const _CsvRow.error('CSV needs a header row and at least one data row.'),
        ];
      });
      return;
    }
    final headers = lines.first.split(',').map((h) => h.trim().toLowerCase()).toList();
    final required = ['title', 'category', 'condition', 'price', 'location'];
    final missing = required.where((key) => !headers.contains(key)).toList();
    if (missing.isNotEmpty) {
      setState(() {
        _rows = [
          _CsvRow.error('Missing headers: ${missing.join(', ')}'),
        ];
      });
      return;
    }

    final mappedRows = <_CsvRow>[];
    for (var i = 1; i < lines.length; i++) {
      final values = lines[i].split(',').map((v) => v.trim()).toList();
      if (values.length < headers.length) {
        mappedRows.add(_CsvRow.error('Row ${i + 1}: Missing columns.'));
        continue;
      }
      final rowMap = <String, String>{};
      for (var j = 0; j < headers.length; j++) {
        rowMap[headers[j]] = values[j];
      }
      final price = double.tryParse(rowMap['price'] ?? '');
      if (price == null || price <= 0) {
        mappedRows.add(_CsvRow.error('Row ${i + 1}: Invalid price.'));
        continue;
      }
      final draft = ListingDraft(
        title: rowMap['title'] ?? '',
        category: rowMap['category'] ?? '',
        condition: rowMap['condition'] ?? '',
        price: price,
        location: rowMap['location'] ?? '',
        imagePath: null,
        shipping: true,
        pickup: true,
        crossBorder: false,
        escrow: true,
        createdAt: DateTime.now().add(Duration(seconds: i)),
      );
      mappedRows.add(_CsvRow.data(draft));
    }

    setState(() => _rows = mappedRows);
  }

  void _import() {
    final valid = _rows.where((row) => row.draft != null).map((row) => row.draft!).toList();
    if (valid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid rows to import.')),
      );
      return;
    }
    for (final draft in valid) {
      LocalStore.instance.publishListing(draft);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imported ${valid.length} listings.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final validCount = _rows.where((row) => row.draft != null).length;
    final errorCount = _rows.where((row) => row.error != null).length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Bulk import')),
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Text(
                  'Paste CSV data',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Required columns: title, category, condition, price, location.',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'CSV',
                    alignLabelWithHint: true,
                    hintText: 'title,category,condition,price,location\nCamera,Collectibles,Good,450,NYC',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _parseCsv,
                        child: const Text('Preview'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _rows.isEmpty ? null : _import,
                        child: const Text('Import'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_rows.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Preview', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(
                          '$validCount valid · $errorCount errors',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                        ),
                        const SizedBox(height: 10),
                        ..._rows.map((row) {
                          if (row.error != null) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(row.error!, style: theme.textTheme.bodySmall?.copyWith(color: Colors.red)),
                            );
                          }
                          final draft = row.draft!;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '${draft.title} · ${draft.category} · \$${draft.price?.toStringAsFixed(0)}',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CsvRow {
  const _CsvRow._({this.draft, this.error});

  final ListingDraft? draft;
  final String? error;

  const _CsvRow.data(ListingDraft draft) : this._(draft: draft);
  const _CsvRow.error(String error) : this._(error: error);
}
