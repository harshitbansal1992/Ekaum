import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/favourite_item.dart';

const String _prefsKey = 'user_favourites';

class FavouritesNotifier extends StateNotifier<List<FavouriteItem>> {
  FavouritesNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr == null) return;
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      state = list
          .map((e) => FavouriteItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      state = [];
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = state.map((e) => e.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(list));
  }

  Future<void> add(FavouriteItem item) async {
    if (state.any((e) => e.uniqueKey == item.uniqueKey)) return;
    state = [...state, item];
    await _save();
  }

  Future<void> remove(String type, String id) async {
    state = state.where((e) => !(e.type == type && e.id == id)).toList();
    await _save();
  }

  Future<void> toggle(FavouriteItem item) async {
    final exists = state.any((e) => e.uniqueKey == item.uniqueKey);
    if (exists) {
      await remove(item.type, item.id);
    } else {
      await add(item);
    }
  }

  bool isFavourite(String type, String id) =>
      state.any((e) => e.type == type && e.id == id);
}

final favouritesProvider =
    StateNotifierProvider<FavouritesNotifier, List<FavouriteItem>>((ref) {
  return FavouritesNotifier();
});
