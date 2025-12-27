import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistStore {
  WishlistStore._();

  static final WishlistStore instance = WishlistStore._();

  static const _key = 'wishlist_ids';

  final ValueNotifier<Set<String>> wishlist = ValueNotifier<Set<String>>(<String>{});
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_key);
    if (raw == null) return;
    final list = (jsonDecode(raw) as List).cast<String>();
    wishlist.value = Set<String>.from(list);
  }

  bool contains(String id) => wishlist.value.contains(id);

  Future<void> toggle(String id) async {
    final updated = Set<String>.from(wishlist.value);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    wishlist.value = updated;
    await _prefs?.setString(_key, jsonEncode(updated.toList()));
  }
}
