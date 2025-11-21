// lib/features/wishlist/domain/usecases/get_wishlist.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/repositories/wishlist_repository.dart';

class GetWishlist {
  final WishlistRepository repository;

  GetWishlist(this.repository);

  Future<Either<Failure, List<WishlistItem>>> call(String userId) async {
    return await repository.getWishlist(userId);
  }
}