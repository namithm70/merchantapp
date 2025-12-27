import 'package:flutter/material.dart';

import '../widgets/app_background.dart';

class PickupScheduleScreen extends StatefulWidget {
  const PickupScheduleScreen({super.key, required this.listingTitle, required this.location});

  final String listingTitle;
  final String location;

  @override
  State<PickupScheduleScreen> createState() => _PickupScheduleScreenState();
}

class _PickupScheduleScreenState extends State<PickupScheduleScreen> {
  DateTime? _date;
  TimeOfDay? _time;
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.location;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 14)),
    );
    if (selected == null) return;
    setState(() => _date = selected);
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selected == null) return;
    setState(() => _time = selected);
  }

  void _confirm() {
    if (_date == null || _time == null || _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a date, time, and location.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pickup request sent to seller.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = _date == null
        ? 'Select date'
        : '${_date!.month}/${_date!.day}/${_date!.year}';
    final timeLabel = _time == null
        ? 'Select time'
        : _time!.format(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Schedule pickup')),
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Text(
                  widget.listingTitle,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Coordinate a safe pickup time and location.',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _pickDate,
                        child: Text(dateLabel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _pickTime,
                        child: Text(timeLabel),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Pickup location *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes for seller',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Meet in a public place and confirm pickup in-app.',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _confirm,
                  child: const Text('Send pickup request'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
