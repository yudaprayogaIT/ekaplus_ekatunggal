
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


  // REPOSITORY
  myinjection.registerLazySingleton<TypeRepository>(
    () => TypeRepositoryImplementation(
      typeRemoteDatasource: myinjection(),
    ),
  );


  // DATA SOURCE
  myinjection.registerLazySingleton<TypeRemoteDatasource>(
    () => TypeRemoteDatasourceImplementation(
      client: myinjection(),
    ),
  );

}
