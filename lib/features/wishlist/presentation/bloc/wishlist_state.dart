// lib/features/wishlist/presentation/bloc/wishlist_state.dart
import 'package:equatable/equatable.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/entities/wishlist_item.dart';

abstract class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoaded extends WishlistState {
  final List<WishlistItem> items;
  final Map<String, bool> statusMap; // productId -> isInWishlist

  const WishlistLoaded({
    required this.items,
    this.statusMap = const {},
  });

  @override
  List<Object?> get props => [items, statusMap];

  // Helper to check if product is in wishlist
  bool isInWishlist(String productId) {
    return statusMap[productId] ?? items.any((item) => item.productId == productId);
  }

  WishlistLoaded copyWith({
    List<WishlistItem>? items,
    Map<String, bool>? statusMap,
  }) {
    return WishlistLoaded(
      items: items ?? this.items,
      statusMap: statusMap ?? this.statusMap,
    );
  }
}

class WishlistError extends WishlistState {
  final String message;

  const WishlistError(this.message);

  @override
  List<Object?> get props => [message];
}

class WishlistToggled extends WishlistState {
  final bool isInWishlist;
  final String productId;

  const WishlistToggled({
    required this.isInWishlist,
    required this.productId,
  });

  @override
  List<Object?> get props => [isInWishlist, productId];
}