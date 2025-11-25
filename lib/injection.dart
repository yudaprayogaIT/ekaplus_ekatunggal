// lib/injection.dart
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/update_profile_picture.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/update_full_name.dart'; // ← ADD
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/request_phone_change.dart'; // ← ADD
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_phone_change.dart'; // ← ADD
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/request_email_change.dart'; // ← ADD
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_email_change.dart'; // ← ADD
import 'package:ekaplus_ekatunggal/features/wishlist/domain/usecases/bulk_delete_wishlist.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

// AUTH
import 'package:ekaplus_ekatunggal/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/repositories/auth_repository_implementation.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/check_phone_exists.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/login_user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/register_user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/request_otp.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_otp.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';

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

// WISHLIST
import 'package:ekaplus_ekatunggal/features/wishlist/data/datasources/wishlist_local_datasource.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/data/repositories/wishlist_repository_implementation.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/usecases/check_wishlist.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/usecases/get_wishlist.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/usecases/toggle_wishlist.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_bloc.dart';

final myinjection = GetIt.instance;

Future<void> init() async {
  print('🚀 Initializing GetIt dependencies...');

  // ============================================
  // CUBIT - Singleton (Global State)
  // ============================================
  myinjection.registerLazySingleton<AuthSessionCubit>(
    () => AuthSessionCubit(),
  );
  print('✅ AuthSessionCubit registered');

  // ============================================
  // GENERAL DEPENDENCIES
  // ============================================
  myinjection.registerLazySingleton(() => http.Client());
  print('✅ HTTP Client registered');

  // ============================================
  // DATA SOURCES
  // ============================================
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

  // 🔥 WISHLIST DataSource
  myinjection.registerLazySingleton<WishlistLocalDataSource>(
    () => WishlistLocalDataSourceImpl(),
  );
  print('✅ WishlistLocalDataSource registered');

  // ============================================
  // REPOSITORIES
  // ============================================
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

  // 🔥 WISHLIST Repository
  myinjection.registerLazySingleton<WishlistRepository>(
    () => WishlistRepositoryImpl(localDataSource: myinjection()),
  );
  print('✅ WishlistRepository registered');

  // ============================================
  // USE CASES
  // ============================================
  
  // Auth UseCases
  myinjection.registerLazySingleton(() => CheckPhoneExists(myinjection()));
  myinjection.registerLazySingleton(() => RequestOtp(myinjection()));
  myinjection.registerLazySingleton(() => VerifyOtp(myinjection()));
  myinjection.registerLazySingleton(() => RegisterUser(myinjection()));
  myinjection.registerLazySingleton(() => LoginUser(myinjection()));
  myinjection.registerLazySingleton(() => UpdateProfilePicture(myinjection()));
  
  // 🔥 Profile Update UseCases
  myinjection.registerLazySingleton(() => UpdateFullName(myinjection()));
  myinjection.registerLazySingleton(() => RequestPhoneChange(myinjection()));
  myinjection.registerLazySingleton(() => VerifyPhoneChange(myinjection()));
  myinjection.registerLazySingleton(() => RequestEmailChange(myinjection()));
  myinjection.registerLazySingleton(() => VerifyEmailChange(myinjection()));
  print('✅ Profile Update UseCases registered');

  // Type UseCases
  myinjection.registerLazySingleton(() => GetAllType(myinjection()));
  myinjection.registerLazySingleton(() => GetType(myinjection()));

  // Category UseCases
  myinjection.registerLazySingleton(() => GetAllCategory(myinjection()));
  myinjection.registerLazySingleton(() => GetCategory(myinjection()));

  // Product UseCases
  myinjection.registerLazySingleton(() => GetAllProduct(myinjection()));
  myinjection.registerLazySingleton(() => GetProduct(myinjection()));
  myinjection.registerLazySingleton(() => GetVariant(myinjection()));
  myinjection.registerLazySingleton(() => GetHotDeals(myinjection()));

  // 🔥 WISHLIST UseCases
  myinjection.registerLazySingleton(() => GetWishlist(myinjection()));
  myinjection.registerLazySingleton(() => ToggleWishlist(myinjection()));
  myinjection.registerLazySingleton(() => CheckWishlist(myinjection()));
  myinjection.registerLazySingleton(() => BulkDeleteWishlist(myinjection()));
  print('✅ Wishlist UseCases registered');

  // ============================================
  // BLOCS (Factory - Created per widget)
  // ============================================
  
  myinjection.registerFactory(
    () => AuthBloc(
      checkPhoneExists: myinjection(),
      requestOtp: myinjection(),
      verifyOtp: myinjection(),
      registerUser: myinjection(),
      loginUser: myinjection(),
      updateProfilePicture: myinjection()
    ),
  );

  myinjection.registerFactory(() => OtpTimerBloc());

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
    () => WishlistBloc(
      getWishlist: myinjection(),
      toggleWishlist: myinjection(),
      checkWishlist: myinjection(),
      bulkDeleteWishlist: myinjection(),
    ),
  );
  print('✅ WishlistBloc registered');

  print('🎉 All dependencies registered successfully!');
}