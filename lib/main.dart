import 'package:flutter/material.dart';
import 'app/marketplace_app.dart';
import 'data/local_store.dart';
import 'data/messaging_service.dart';
import 'data/notification_service.dart';
import 'data/wishlist_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStore.instance.init();
  await WishlistStore.instance.init();
  runApp(const MarketplaceApp());

  Future(() async {
    await NotificationService.instance.init();
    await MessagingService.instance.init();
  });
}
