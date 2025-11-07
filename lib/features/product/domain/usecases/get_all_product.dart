// lib/features/product/domain/usecases/get_all_product.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/repositories/product_repository.dart';

class GetAllProduct {
  final ProductRepository productRepository;
  const GetAllProduct(this.productRepository);

  Future<Either<Failure, List<Product>>> execute(int page) {
    return productRepository.getAllProduct(page);
  }
}
