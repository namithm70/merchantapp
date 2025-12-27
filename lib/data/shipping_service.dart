import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_config.dart';

class ShippingRate {
  const ShippingRate({
    required this.carrier,
    required this.eta,
    required this.cost,
  });

  final String carrier;
  final String eta;
  final double cost;
}

class ShippingQuote {
  const ShippingQuote({
    required this.origin,
    required this.destination,
    required this.rates,
  });

  final String origin;
  final String destination;
  final List<ShippingRate> rates;
}

class ShippingService {
  ShippingService._();

  static final ShippingService instance = ShippingService._();

  Future<ShippingQuote> fetchRates({required String origin, required String destination}) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/shipping/rates'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'origin': origin,
        'destination': destination,
      }),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rates = (data['rates'] as List)
        .map((item) => ShippingRate(
              carrier: item['carrier'] as String,
              eta: item['eta'] as String,
              cost: (item['cost'] as num).toDouble(),
            ))
        .toList();
    return ShippingQuote(
      origin: data['origin'] as String,
      destination: data['destination'] as String,
      rates: rates,
    );
  }
}
