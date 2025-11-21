// lib/features/wishlist/data/models/wishlist_item_model.dart

import 'package:ekaplus_ekatunggal/features/wishlist/domain/entities/wishlist_item.dart';

class WishlistItemModel extends WishlistItem {
  const WishlistItemModel({
    required super.userId,
    required super.productId,
    required super.addedAt,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productId': productId,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory WishlistItemModel.fromEntity(WishlistItem item) {
    return WishlistItemModel(
      userId: item.userId,
      productId: item.productId,
      addedAt: item.addedAt,
    );
  }
}