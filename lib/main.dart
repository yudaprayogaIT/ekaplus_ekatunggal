// lib/main.dart
import 'package:bloc/bloc.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/cubit/connection_status_cubit.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';
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

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp.router(
  //     title: 'Ekaplus Ekatunggal',
  //     debugShowCheckedModeBanner: false,
  //     routerConfig: MyRouter.router,
  // theme: ThemeData(
  //   primaryColor: AppColors.primaryColor,
  //   scaffoldBackgroundColor: AppColors.background,
  //   fontFamily: AppFonts.primaryFont,
  //   colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
  // ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ConnectionCubit()..startMonitoringConnection(),
        ),
        BlocProvider(create: (context) => myinjection<TypeBloc>()),
        BlocProvider(create: (context) => myinjection<CategoryBloc>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocListener<ConnectionCubit, ConnectionStateCubit>(
          listener: (context, state) {
            if (state.status == ConnectionStatus.offline) {
              ScaffoldMessenger.of(context).clearSnackBars();
              if (ScaffoldMessenger.of(context).mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Tidak ada koneksi internet',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(days: 365),
                  ),
                );
              }
            } else if (state.status == ConnectionStatus.low) {
              if (ScaffoldMessenger.of(context).mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Koneksi internet tidak stabil',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.orange,
                    duration: Duration(days: 365),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).clearSnackBars();
            }
          },
          child: Scaffold(
            body: MaterialApp.router(
              theme: ThemeData(
                primaryColor: AppColors.primaryColor,
                scaffoldBackgroundColor: AppColors.background,
                fontFamily: AppFonts.primaryFont,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primaryColor,
                ),
              ),
              debugShowCheckedModeBanner: false,
              routerConfig: MyRouter().router,
            ),
          ),
        ),
      ),
    );
  }
}
