// lib/main.dart
import 'package:bloc/bloc.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/cubit/connection_status_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/type/presentation/bloc/type_bloc.dart';
import 'package:ekaplus_ekatunggal/injection.dart';
import 'package:ekaplus_ekatunggal/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/routes/my_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();

  Bloc.observer = MyObserver();
  runApp(const EkaplusApp());
}

class EkaplusApp extends StatelessWidget {
  const EkaplusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ConnectionCubit()..startMonitoringConnection(),
        ),
        BlocProvider(create: (context) => myinjection<TypeBloc>()),
        BlocProvider(create: (context) => myinjection<CategoryBloc>()),
        BlocProvider(create: (context) => myinjection<ProductBloc>()),
        BlocProvider(create: (context) => myinjection<AuthBloc>()),
      ],
      child: BlocListener<ConnectionCubit, ConnectionStateCubit>(
        listener: (context, state) {
          // sama seperti kode kamu (Snackbars dsb)
        },
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: MyRouter().router,
          theme: ThemeData(
            primaryColor: AppColors.primaryColor,
            scaffoldBackgroundColor: AppColors.background,
            fontFamily: AppFonts.primaryFont,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
          ),
        ),
      ),
    );
  }
}