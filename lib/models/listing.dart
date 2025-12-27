import 'package:flutter/material.dart';

class Listing {
  const Listing({
    required this.id,
    required this.title,
    required this.category,
    required this.condition,
    required this.price,
    required this.location,
    required this.sellerName,
    required this.verifiedSeller,
    required this.rating,
    required this.sustainabilityScore,
    required this.demandIndex,
    required this.aiPriceLow,
    required this.aiPriceHigh,
    required this.shippingAvailable,
    required this.pickupAvailable,
    required this.crossBorderEligible,
    required this.escrowAvailable,
    required this.icon,
    required this.accentColor,
  });

  final String id;
  final String title;
  final String category;
  final String condition;
  final double price;
  final String location;
  final String sellerName;
  final bool verifiedSeller;
  final double rating;
  final int sustainabilityScore;
  final int demandIndex;
  final double aiPriceLow;
  final double aiPriceHigh;
  final bool shippingAvailable;
  final bool pickupAvailable;
  final bool crossBorderEligible;
  final bool escrowAvailable;
  final IconData icon;
  final Color accentColor;
}
