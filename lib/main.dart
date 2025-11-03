// lib/main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/routes/my_router.dart';
import 'constant.dart';

void main() {
  runApp(const EkaplusApp());
}

class EkaplusApp extends StatelessWidget {
  const EkaplusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ekaplus Ekatunggal',
      debugShowCheckedModeBanner: false,
      routerConfig: MyRouter.router,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: AppFonts.primaryFont,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
      ),
    );
  }
}
