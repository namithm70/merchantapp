import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../models/message_entry.dart';
import '../models/message_thread.dart';
import '../models/offer_state.dart';

const List<String> categories = [
  'Electronics',
  'Home',
  'Outdoor',
  'Fashion',
  'Auto',
  'Collectibles',
];

class ForecastPoint {
  const ForecastPoint({required this.label, required this.score, required this.delta});

  final String label;
  final int score;
  final int delta;
}

class LogisticsLane {
  const LogisticsLane({
    required this.route,
    required this.eta,
    required this.savings,
    required this.carbonScore,
  });

  final String route;
  final String eta;
  final String savings;
  final int carbonScore;
}

const List<Listing> sampleListings = [
  Listing(
    id: 'l-001',
    title: 'Studio Monitor Pair',
    category: 'Electronics',
    condition: 'Like New',
    price: 420,
    location: 'Austin, TX',
    sellerName: 'Nina Patel',
    verifiedSeller: true,
    rating: 4.8,
    sustainabilityScore: 86,
    demandIndex: 82,
    aiPriceLow: 390,
    aiPriceHigh: 450,
    shippingAvailable: true,
    pickupAvailable: true,
    crossBorderEligible: false,
    escrowAvailable: true,
    icon: Icons.speaker,
    accentColor: Color(0xFF2A9D8F),
  ),
  Listing(
    id: 'l-002',
    title: 'Minimalist Bike',
    category: 'Outdoor',
    condition: 'Good',
    price: 280,
    location: 'Portland, OR',
    sellerName: 'Kai Morgan',
    verifiedSeller: true,
    rating: 4.6,
    sustainabilityScore: 92,
    demandIndex: 74,
    aiPriceLow: 250,
    aiPriceHigh: 320,
    shippingAvailable: false,
    pickupAvailable: true,
    crossBorderEligible: false,
    escrowAvailable: false,
    icon: Icons.directions_bike,
    accentColor: Color(0xFFE9C46A),
  ),
  Listing(
    id: 'l-003',
    title: 'Analog Camera Kit',
    category: 'Collectibles',
    condition: 'Good',
    price: 510,
    location: 'New York, NY',
    sellerName: 'Marta Diaz',
    verifiedSeller: true,
    rating: 4.9,
    sustainabilityScore: 79,
    demandIndex: 88,
    aiPriceLow: 480,
    aiPriceHigh: 560,
    shippingAvailable: true,
    pickupAvailable: false,
    crossBorderEligible: true,
    escrowAvailable: true,
    icon: Icons.photo_camera,
    accentColor: Color(0xFF264653),
  ),
  Listing(
    id: 'l-004',
    title: 'Leather Weekend Bag',
    category: 'Fashion',
    condition: 'Like New',
    price: 190,
    location: 'Chicago, IL',
    sellerName: 'Evan Brooks',
    verifiedSeller: false,
    rating: 4.4,
    sustainabilityScore: 71,
    demandIndex: 66,
    aiPriceLow: 170,
    aiPriceHigh: 220,
    shippingAvailable: true,
    pickupAvailable: true,
    crossBorderEligible: true,
    escrowAvailable: false,
    icon: Icons.work_outline,
    accentColor: Color(0xFFE76F51),
  ),
  Listing(
    id: 'l-005',
    title: 'Smart Espresso Setup',
    category: 'Home',
    condition: 'New',
    price: 860,
    location: 'Seattle, WA',
    sellerName: 'Priya Shah',
    verifiedSeller: true,
    rating: 5.0,
    sustainabilityScore: 64,
    demandIndex: 91,
    aiPriceLow: 820,
    aiPriceHigh: 900,
    shippingAvailable: true,
    pickupAvailable: true,
    crossBorderEligible: false,
    escrowAvailable: true,
    icon: Icons.coffee,
    accentColor: Color(0xFF3D5A80),
  ),
  Listing(
    id: 'l-006',
    title: 'Restored Coupe Wheels',
    category: 'Auto',
    condition: 'Fair',
    price: 360,
    location: 'Denver, CO',
    sellerName: 'Avery Chen',
    verifiedSeller: false,
    rating: 4.1,
    sustainabilityScore: 58,
    demandIndex: 61,
    aiPriceLow: 310,
    aiPriceHigh: 380,
    shippingAvailable: false,
    pickupAvailable: true,
    crossBorderEligible: false,
    escrowAvailable: false,
    icon: Icons.tire_repair,
    accentColor: Color(0xFF8E9AAF),
  ),
];

final List<MessageThread> seedThreads = [
  MessageThread(
    id: 't-100',
    listingTitle: 'Studio Monitor Pair',
    preview: 'Would you take 395 if I pick up today?',
    unreadCount: 2,
    sellerName: 'Nina Patel',
    lastMessageAt: DateTime.now().subtract(const Duration(minutes: 4)),
    blocked: false,
    reported: false,
    offerState: OfferState(
      amount: 395,
      status: OfferStatus.pending,
      expiresAt: DateTime.now().add(const Duration(hours: 20)),
      lastUpdatedBy: 'buyer',
    ),
  ),
  MessageThread(
    id: 't-101',
    listingTitle: 'Analog Camera Kit',
    preview: 'Tracking shows delivery tomorrow morning.',
    unreadCount: 0,
    sellerName: 'Marta Diaz',
    lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
    blocked: false,
    reported: false,
    offerState: OfferState(
      amount: 510,
      status: OfferStatus.accepted,
      expiresAt: DateTime.now(),
      lastUpdatedBy: 'seller',
    ),
  ),
  MessageThread(
    id: 't-102',
    listingTitle: 'Leather Weekend Bag',
    preview: 'I can do 180 with escrow.',
    unreadCount: 1,
    sellerName: 'Evan Brooks',
    lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
    blocked: false,
    reported: false,
    offerState: OfferState(
      amount: 180,
      status: OfferStatus.countered,
      expiresAt: DateTime.now().add(const Duration(hours: 10)),
      lastUpdatedBy: 'seller',
    ),
  ),
];

final Map<String, List<MessageEntry>> seedMessages = {
  't-100': [
    MessageEntry(
      id: 'm-100',
      threadId: 't-100',
      sender: 'buyer',
      body: 'Would you take 395 if I pick up today?',
      imagePath: null,
      sentAt: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
  ],
  't-101': [
    MessageEntry(
      id: 'm-101',
      threadId: 't-101',
      sender: 'seller',
      body: 'Tracking shows delivery tomorrow morning.',
      imagePath: null,
      sentAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ],
  't-102': [
    MessageEntry(
      id: 'm-102',
      threadId: 't-102',
      sender: 'seller',
      body: 'I can do 180 with escrow.',
      imagePath: null,
      sentAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ],
};

const List<String> advancedSignals = [
  'Pricing suggestions calibrated to 30-day comps.',
  'Image recognition draft creation for fast listing.',
  'Fraud scoring with payout holds on risk spikes.',
  'Demand forecasts by category and metro area.',
  'Shipping labels auto-generated with tracking.',
  'Cross-border duties and restriction checks.',
  'Buyer credit line options via partner.',
  'Escrow release tied to delivery confirmation.',
  'Logistics optimization for batch fulfillment.',
  'Sustainability scores based on resale impact.',
];

const List<ForecastPoint> demandForecast = [
  ForecastPoint(label: 'Audio gear', score: 82, delta: 6),
  ForecastPoint(label: 'Bikes', score: 71, delta: 3),
  ForecastPoint(label: 'Cameras', score: 88, delta: 9),
  ForecastPoint(label: 'Home goods', score: 64, delta: -2),
];

const List<LogisticsLane> logisticsLanes = [
  LogisticsLane(route: 'Austin → Dallas', eta: '1-2 days', savings: '14%', carbonScore: 78),
  LogisticsLane(route: 'Seattle → Portland', eta: '1 day', savings: '11%', carbonScore: 83),
  LogisticsLane(route: 'NYC → Boston', eta: '2 days', savings: '9%', carbonScore: 76),
];
