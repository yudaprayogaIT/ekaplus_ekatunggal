// lib/features/wishlist/data/repositories/wishlist_repository_implementation.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/data/datasources/wishlist_local_datasource.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/repositories/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistLocalDataSource localDataSource;

  WishlistRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<WishlistItem>>> getWishlist(String userId) async {
    try {
      final result = await localDataSource.getWishlist(userId);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToWishlist(String userId, String productId) async {
    try {
      await localDataSource.addToWishlist(userId, productId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWishlist(String userId, String productId) async {
    try {
      await localDataSource.removeFromWishlist(userId, productId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isInWishlist(String userId, String productId) async {
    try {
      final result = await localDataSource.isInWishlist(userId, productId);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearWishlist(String userId) async {
    try {
      await localDataSource.clearWishlist(userId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}