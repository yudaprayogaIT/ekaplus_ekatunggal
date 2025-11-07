// lib/features/product/domain/repositories/product_repository.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getAllProduct(int page);
  Future<Either<Failure, Product>> getProduct(String id);
}
