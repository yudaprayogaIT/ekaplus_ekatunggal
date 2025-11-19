// lib/injection.dart
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

// AUTH
import 'package:ekaplus_ekatunggal/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/repositories/auth_repository_implementation.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/check_phone_exists.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/register_user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/request_otp.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_otp.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';

// CATEGORY
import 'package:ekaplus_ekatunggal/features/category/data/datasources/category_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/category/data/repositories/category_repository_implementation.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/repositories/category_repository.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/usecases/get_all_category.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/usecases/get_category.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';

// PRODUCT
import 'package:ekaplus_ekatunggal/features/product/data/datasources/product_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/product/data/repositories/product_repository_implementation.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/repositories/product_repository.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_all_product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_hot_deals.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_variant.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';

// TYPE
import 'package:ekaplus_ekatunggal/features/type/data/datasources/type_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/type/data/repositories/type_repository_implementation.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/repositories/type_repository.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/usecases/get_all_type.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/usecases/get_type.dart';
import 'package:ekaplus_ekatunggal/features/type/presentation/bloc/type_bloc.dart';

var myinjection = GetIt.instance;

Future<void> init() async {
  /// --- General deps
  myinjection.registerLazySingleton(() => http.Client());

  /// --- Data sources (low level) - daftar dulu supaya repositori bisa resolve
  myinjection.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  myinjection.registerLazySingleton<TypeRemoteDatasource>(
    () => TypeRemoteDatasourceImplementation(client: myinjection()),
  );

  myinjection.registerLazySingleton<CategoryRemoteDatasource>(
    () => CategoryRemoteDatasourceImplementation(client: myinjection()),
  );

  myinjection.registerLazySingleton<ProductRemoteDatasource>(
    () => ProductRemoteDatasourceImplementation(client: myinjection()),
  );

  /// --- Repositories
  myinjection.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImplementation(localDataSource: myinjection()),
  );

  myinjection.registerLazySingleton<TypeRepository>(
    () => TypeRepositoryImplementation(typeRemoteDatasource: myinjection()),
  );

  myinjection.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImplementation(
      categoryRemoteDatasource: myinjection(),
    ),
  );

  myinjection.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImplementation(productRemoteDatasource: myinjection()),
  );

  /// --- Usecases
  myinjection.registerLazySingleton(() => GetAllType(myinjection()));
  myinjection.registerLazySingleton(() => GetType(myinjection()));
  myinjection.registerLazySingleton(() => GetAllCategory(myinjection()));
  myinjection.registerLazySingleton(() => GetCategory(myinjection()));
  myinjection.registerLazySingleton(() => GetAllProduct(myinjection()));
  myinjection.registerLazySingleton(() => GetProduct(myinjection()));
  myinjection.registerLazySingleton(() => GetVariant(myinjection()));
  myinjection.registerLazySingleton(() => GetHotDeals(myinjection()));
  myinjection.registerLazySingleton(() => CheckPhoneExists(myinjection()));
  myinjection.registerLazySingleton(() => RequestOtp(myinjection()));
  myinjection.registerLazySingleton(() => VerifyOtp(myinjection()));
  myinjection.registerLazySingleton(() => RegisterUser(myinjection()));

  /// --- Blocs / Factories (UI level)
  myinjection.registerFactory(
    () => TypeBloc(getAllType: myinjection(), getType: myinjection()),
  );

  myinjection.registerFactory(
    () => CategoryBloc(getAllCategory: myinjection(), getCategory: myinjection()),
  );

  myinjection.registerFactory(
    () => ProductBloc(
      getAllProduct: myinjection(),
      getProduct: myinjection(),
      getVariant: myinjection(),
      getHotDeals: myinjection(),
    ),
  );

  myinjection.registerFactory(
    () => AuthBloc(
      checkPhoneExists: myinjection(),
      requestOtp: myinjection(),
      verifyOtp: myinjection(),
      registerUser: myinjection(),
    ),
  );

  myinjection.registerFactory(() => OtpTimerBloc());
}