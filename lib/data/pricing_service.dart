import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_config.dart';

class PricingSuggestion {
  const PricingSuggestion({
    required this.low,
    required this.high,
    required this.confidence,
    required this.factors,
  });

  final double low;
  final double high;
  final double confidence;
  final List<String> factors;
}

class PricingService {
  PricingService._();

  static final PricingService instance = PricingService._();

  Future<PricingSuggestion?> fetchSuggestion({
    required String category,
    required String condition,
    required double? price,
  }) async {
    if (category.trim().isEmpty) return null;
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/pricing'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'category': category,
        'condition': condition,
        'price': price,
      }),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return PricingSuggestion(
      low: (data['low'] as num).toDouble(),
      high: (data['high'] as num).toDouble(),
      confidence: (data['confidence'] as num).toDouble(),
      factors: (data['factors'] as List).map((item) => item.toString()).toList(),
    );
  }
}
