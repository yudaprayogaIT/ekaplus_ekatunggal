// lib/features/product/data/repositories/product_repository_implementation.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/product/data/datasources/product_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/repositories/product_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_all_product.dart';

class ProductRepositoryImplementation extends ProductRepository {
  final ProductRemoteDatasource productRemoteDatasource;

  ProductRepositoryImplementation({
    required this.productRemoteDatasource,
  });

  @override
  Future<Either<Failure, List<Product>>> getAllProduct(int page) async {
    try {
      //  Check Internet
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        throw "No Connnection";
      } else {
        List<Product> result =
            await productRemoteDatasource.getAllProduct(page);

        return Right(result);
      }
    } catch (e) {
      return Left(Failure());
    }
  }

  @override
  Future<Either<Failure, Product>> getProduct(String id) async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        throw "No Connnection";
      } else {
        Product result = await productRemoteDatasource.getProduct(id);
        return Right(result);
      }
    } catch (e) {
      return Left(Failure());
    }
  }
}
