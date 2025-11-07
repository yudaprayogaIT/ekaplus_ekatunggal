// lib/features/product/domain/usecases/get_variant.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/repositories/product_repository.dart';

class GetVariant {
  final ProductRepository productRepository;
  const GetVariant(this.productRepository);

  Future<Either<Failure, VariantEntity?>> execute(String variantId) {
    return productRepository.getVariant(variantId);
  }
}