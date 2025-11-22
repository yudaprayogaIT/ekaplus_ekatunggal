// lib/features/wishlist/data/datasources/wishlist_local_datasource.dart
import 'package:ekaplus_ekatunggal/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

abstract class WishlistLocalDataSource {
  Future<List<WishlistItemModel>> getWishlist(String userId);
  Future<void> addToWishlist(String userId, String productId);
  Future<void> removeFromWishlist(String userId, String productId);
  Future<bool> isInWishlist(String userId, String productId);
  Future<void> clearWishlist(String userId);

  Future<int> bulkDeleteWishlist(String userId, List<String> productIds);
}

class WishlistLocalDataSourceImpl implements WishlistLocalDataSource {
  static const String _keyPrefix = 'wishlist_';

  String _getUserKey(String userId) => '$_keyPrefix$userId';

  @override
  Future<List<WishlistItemModel>> getWishlist(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(userId);
      final jsonString = prefs.getString(key);

      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => WishlistItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error loading wishlist: $e');
      return [];
    }
  }

  @override
  Future<void> addToWishlist(String userId, String productId) async {
    try {
      final wishlist = await getWishlist(userId);

      // Check if already exists
      final exists = wishlist.any((item) => item.productId == productId);
      if (exists) {
        print('⚠️ Product already in wishlist: $productId');
        return;
      }

      // Add new item
      final newItem = WishlistItemModel(
        userId: userId,
        productId: productId,
        addedAt: DateTime.now(),
      );

      wishlist.add(newItem);

      // Save
      await _saveWishlist(userId, wishlist);
      print('✅ Added to wishlist: $productId');
    } catch (e) {
      print('❌ Error adding to wishlist: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeFromWishlist(String userId, String productId) async {
    try {
      final wishlist = await getWishlist(userId);
      wishlist.removeWhere((item) => item.productId == productId);

      await _saveWishlist(userId, wishlist);
      print('✅ Removed from wishlist: $productId');
    } catch (e) {
      print('❌ Error removing from wishlist: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isInWishlist(String userId, String productId) async {
    try {
      final wishlist = await getWishlist(userId);
      return wishlist.any((item) => item.productId == productId);
    } catch (e) {
      print('❌ Error checking wishlist: $e');
      return false;
    }
  }

  @override
  Future<void> clearWishlist(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserKey(userId);
      await prefs.remove(key);
      print('✅ Wishlist cleared for user: $userId');
    } catch (e) {
      print('❌ Error clearing wishlist: $e');
      rethrow;
    }
  }

  @override
  Future<int> bulkDeleteWishlist(String userId, List<String> productIds) async {
    try {
      final wishlist = await getWishlist(userId);
      final initialCount = wishlist.length;

      // Remove all items yang ada di productIds
      wishlist.removeWhere((item) => productIds.contains(item.productId));

      final deletedCount = initialCount - wishlist.length;

      // Save updated wishlist
      await _saveWishlist(userId, wishlist);

      print('✅ Bulk deleted $deletedCount items from wishlist');
      return deletedCount;
    } catch (e) {
      print('❌ Error bulk deleting wishlist: $e');
      rethrow;
    }
  }

  Future<void> _saveWishlist(String userId, List<WishlistItemModel> wishlist) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getUserKey(userId);
    final jsonList = wishlist.map((item) => item.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(key, jsonString);
  }
}