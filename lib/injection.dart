
import 'package:ekaplus_ekatunggal/features/category/data/datasources/category_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/category/data/repositories/category_repository_implementation.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/repositories/category_repository.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/usecases/get_all_category.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/usecases/get_category.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/data/datasources/product_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/product/data/repositories/product_repository_implementation.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/repositories/product_repository.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_all_product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_product.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/type/data/datasources/type_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/type/data/repositories/type_repository_implementation.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/repositories/type_repository.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/usecases/get_all_type.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/usecases/get_type.dart';
import 'package:ekaplus_ekatunggal/features/type/presentation/bloc/type_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

var myinjection =
    GetIt.instance; // ini merupakan tempat penampungan semua dependencies

// KITA AKAN MENG-INJECT SEMUA DEPENDENCIES
Future<void> init() async {
  /// GENERAL DEPENDENCIES

  // HTTP
  myinjection.registerLazySingleton(
    () => http.Client(),
  );

  // myinjection.registerLazySingleton<Dio>(() => Dio());

  /// FEATURE - PROFILE
  // BLOC
  myinjection.registerFactory(
    () => TypeBloc(
      getAllType: myinjection(),
      getType: myinjection(),
    ),
  );
  myinjection.registerFactory(
    () => CategoryBloc(
      getAllCategory: myinjection(),
      getCategory: myinjection(),
    ),
  );
  myinjection.registerFactory(
    () => ProductBloc(
      getAllProduct: myinjection(),
      getProduct: myinjection(),
    ),
  );
  

  // USECASE
  myinjection.registerLazySingleton(
    () => GetAllType(
      myinjection(),
    ),
  );
  myinjection.registerLazySingleton(
    () => GetType(
      myinjection(),
    ),
  );
  myinjection.registerLazySingleton(
    () => GetAllCategory(
      myinjection(),
    ),
  );
  myinjection.registerLazySingleton(
    () => GetCategory(
      myinjection(),
    ),
  );
  myinjection.registerLazySingleton(
    () => GetAllProduct(
      myinjection(),
    ),
  );
  myinjection.registerLazySingleton(
    () => GetProduct(
      myinjection(),
    ),
  );


  // REPOSITORY
  myinjection.registerLazySingleton<TypeRepository>(
    () => TypeRepositoryImplementation(
      typeRemoteDatasource: myinjection(),
    ),
  );
  myinjection.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImplementation(
      categoryRemoteDatasource: myinjection(),
    ),
  );
  myinjection.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImplementation(
      productRemoteDatasource: myinjection(),
    ),
  );


  // DATA SOURCE
  myinjection.registerLazySingleton<TypeRemoteDatasource>(
    () => TypeRemoteDatasourceImplementation(
      client: myinjection(),
    ),
  );
  myinjection.registerLazySingleton<CategoryRemoteDatasource>(
    () => CategoryRemoteDatasourceImplementation(
      client: myinjection(),
    ),
  );
  myinjection.registerLazySingleton<ProductRemoteDatasource>(
    () => ProductRemoteDatasourceImplementation(
      client: myinjection(),
    ),
  );

}
