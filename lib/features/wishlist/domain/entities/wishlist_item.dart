// lib/features/wishlist/domain/entities/wishlist_item.dart
import 'package:equatable/equatable.dart';

class WishlistItem extends Equatable {
  final String userId;
  final String productId;
  final DateTime addedAt;

  const WishlistItem({
    required this.userId,
    required this.productId,
    required this.addedAt,
  });

  @override
  List<Object?> get props => [userId, productId, addedAt];
}