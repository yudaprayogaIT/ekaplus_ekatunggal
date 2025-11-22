// lib/features/wishlist/domain/repositories/wishlist_repository.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/entities/wishlist_item.dart';

abstract class WishlistRepository {
  Future<Either<Failure, List<WishlistItem>>> getWishlist(String userId);
  Future<Either<Failure, void>> addToWishlist(String userId, String productId);
  Future<Either<Failure, void>> removeFromWishlist(String userId, String productId);
  Future<Either<Failure, bool>> isInWishlist(String userId, String productId);
  Future<Either<Failure, void>> clearWishlist(String userId);

  Future<Either<Failure, int>> bulkDeleteWishlist(String userId, List<String> productIds);
}