// lib/features/wishlist/presentation/bloc/wishlist_event.dart
import 'package:equatable/equatable.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWishlist extends WishlistEvent {
  final String userId;

  const LoadWishlist(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ToggleWishlistItem extends WishlistEvent {
  final String userId;
  final String productId;

  const ToggleWishlistItem({
    required this.userId,
    required this.productId,
  });

  @override
  List<Object?> get props => [userId, productId];
}

class CheckWishlistStatus extends WishlistEvent {
  final String userId;
  final String productId;

  const CheckWishlistStatus({
    required this.userId,
    required this.productId,
  });

  @override
  List<Object?> get props => [userId, productId];
}