// // // lib/features/category/data/category_repository.dart
// // import 'package:flutter/services.dart' show rootBundle;
// // import 'models/category_item.dart';

// // class CategoryRepository {
// //   final String assetPath;

// //   CategoryRepository({this.assetPath = 'assets/data/itemCategories.json'});

// //   Future<List<CategoryItem>> loadAll() async {
// //     final jsonStr = await rootBundle.loadString(assetPath);
// //     return CategoryItem.listFromJsonString(jsonStr);
// //   }
// // }

// // lib/features/category/data/repositories/category_repository.dart
// import 'package:dartz/dartz.dart';
// import 'package:ekaplus_ekatunggal/core/error/failure.dart';
// import 'package:ekaplus_ekatunggal/features/category/data/datasources/category_remote_datasource.dart';
// import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';
// import 'package:ekaplus_ekatunggal/features/category/domain/repositories/category_repository.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// // import 'package:ekaplus_ekatunggal/features/category/domain/usecases/get_all_category.dart';

// class CategoryRepositoryImplementation extends CategoryRepository {
//   final CategoryRemoteDatasource categoryRemoteDatasource;

//   CategoryRepositoryImplementation({
//     required this.categoryRemoteDatasource,
//   });

//   @override
//   Future<Either<Failure, List<Category>>> getAllCategory(int page) async {
//     try {
//       //  Check Internet
//       final List<ConnectivityResult> connectivityResult =
//           await (Connectivity().checkConnectivity());
//       if (connectivityResult.contains(ConnectivityResult.none)) {
//         throw "No Connnection";
//       } else {
//         List<Category> result =
//             await categoryRemoteDatasource.getAllCategory(page);

//         return Right(result);
//       }
//     } catch (e) {
//       return Left(Failure());
//     }
//   }

//   @override
//   Future<Either<Failure, Category>> getCategory(String id) async {
//     try {
//       final List<ConnectivityResult> connectivityResult =
//           await (Connectivity().checkConnectivity());
//       if (connectivityResult.contains(ConnectivityResult.none)) {
//         throw "No Connnection";
//       } else {
//         Category result = await categoryRemoteDatasource.getCategory(id);
//         return Right(result);
//       }
//     } catch (e) {
//       return Left(Failure());
//     }
//   }
// }
