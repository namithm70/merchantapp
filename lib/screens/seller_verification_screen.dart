import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/app_background.dart';

class SellerVerificationScreen extends StatefulWidget {
  const SellerVerificationScreen({super.key});

  @override
  State<SellerVerificationScreen> createState() => _SellerVerificationScreenState();
}

class _SellerVerificationScreenState extends State<SellerVerificationScreen> {
  int _currentStep = 0;
  String? _idPath;
  String? _selfiePath;
  bool _addressConfirmed = false;

  Future<void> _pickImage(bool isId) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;
    setState(() {
      if (isId) {
        _idPath = image.path;
      } else {
        _selfiePath = image.path;
      }
    });
  }

  void _complete() {
    if (_idPath == null || _selfiePath == null || !_addressConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete all steps before submitting.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification submitted. Expect review in 24 hours.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Seller verification')),
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            bottom: false,
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 2) {
                  setState(() => _currentStep += 1);
                } else {
                  _complete();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                }
              },
              controlsBuilder: (context, details) {
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(_currentStep < 2 ? 'Next' : 'Submit'),
                    ),
                    const SizedBox(width: 12),
                    if (_currentStep > 0)
                      OutlinedButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                  ],
                );
              },
              steps: [
                Step(
                  title: const Text('Upload ID'),
                  subtitle: const Text('Government-issued ID'),
                  isActive: _currentStep >= 0,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(true),
                        icon: const Icon(Icons.badge),
                        label: const Text('Upload ID'),
                      ),
                      const SizedBox(height: 12),
                      if (_idPath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(_idPath!),
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Text('No ID uploaded yet.', style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54)),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Selfie verification'),
                  subtitle: const Text('Match ID photo'),
                  isActive: _currentStep >= 1,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(false),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Upload selfie'),
                      ),
                      const SizedBox(height: 12),
                      if (_selfiePath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(_selfiePath!),
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Text('No selfie uploaded yet.', style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54)),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Confirm address'),
                  subtitle: const Text('Billing or pickup address'),
                  isActive: _currentStep >= 2,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        value: _addressConfirmed,
                        onChanged: (value) => setState(() => _addressConfirmed = value ?? false),
                        title: const Text('Address confirmed'),
                        subtitle: const Text('I confirm the address on file is correct.'),
                      ),
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
