// lib/core/routes/my_router.dart
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/about_page.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/account_page.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/pages/login_page.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/pages/register_form_page.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/pages/register_page.dart';
import 'package:ekaplus_ekatunggal/features/search/presentation/bloc/search_bloc.dart';
import 'package:ekaplus_ekatunggal/features/search/presentation/pages/search_page.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/pages/wishlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ekaplus_ekatunggal/features/home/presentation/pages/home_page.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/pages/category.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/pages/category_detail_page.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/pages/product_page.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/pages/product_detail_page.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/pages/products_highlight_page.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';

import 'package:ekaplus_ekatunggal/core/shared_widgets/bottom_nav.dart';

class MyRouter {
  GoRouter get router => GoRouter(
    // initialLocation: "/",
    initialLocation: "/login",
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(currentPath: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(
            name: 'home',
            path: '/',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            name: 'category',
            path: '/category',
            builder: (context, state) => const CategoryPage(),
          ),
          GoRoute(
            name: 'wishlist',
            path: '/wishlist',
            builder: (context, state) => const WishlistPage(),
          ),
        ],
      ),

      // Routes tanpa bottom nav
      // ============================================
      // AUTH ROUTES
      // ============================================
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const RegisterPage()),
      ),

      GoRoute(
        path: '/otp',
        name: 'otp',
        pageBuilder: (context, state) {
          // Get phone number from extra
          final phoneNumber = state.extra as String? ?? '';

          return MaterialPage(
            key: state.pageKey,
            child: OtpVerificationPage(phoneNumber: phoneNumber),
          );
        },
      ),

      // Register Form route (setelah OTP verified)
      GoRoute(
        path: '/registerForm',
        name: 'registerForm',
        pageBuilder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';

          return MaterialPage(
            key: state.pageKey,
            child: RegisterFormPage(phoneNumber: phoneNumber),
          );
        },
      ),

      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) {
          return LoginPage();
        },
      ),

      GoRoute(
        name: 'account',
        path: '/account',
        builder: (context, state) {
          return AccountPage();
        },
      ),

      GoRoute(
        name: 'about',
        path: '/about',
        builder: (context, state) {
          return AboutPage();
        },
      ),

      GoRoute(
        name: 'search',
        path: '/search',
        builder: (context, state) {
          return BlocProvider(
            create: (context) => SearchBloc(),
            child: const SearchPage(),
          );
        },
      ),

      GoRoute(
        name: 'categoryDetail',
        path: '/category/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return CategoryDetailPage(
            categoryId: id,
            categoryName: extra?['categoryName'],
            categoryTitle: extra?['categoryTitle'],
            categorySubtitle: extra?['categorySubtitle'],
          );
        },
      ),

      GoRoute(
        name: 'productPage',
        path: '/products',
        builder: (context, state) {
          final extra = state.extra as Category?;
          return ProductPage(categoryName: extra?.name, categoryId: extra?.id);
        },
      ),

      GoRoute(
        name: 'productDetail',
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailPage(productId: id);
        },
      ),

      GoRoute(
        name: 'productsHighlight',
        path: '/products-highlight',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ProductsHighlight(
            hotDealsOnly: extra['hotDealsOnly'] ?? false,
            title: extra['title'] ?? 'Products',
            headerTitle: extra['headerTitle'] ?? '',
            headerSubTitle: extra['headerSubTitle'] ?? 'Products',
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text(state.error.toString())),
    ),
  );
}

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const AppShell({required this.child, required this.currentPath, super.key});

  int _locationToIndex(String path) {
    if (path.startsWith('/category')) return 1;
    if (path.startsWith('/wishlist')) return 2;
    if (path.startsWith('/account')) return 3;
    return 0;
  }

  static const List<String> _routeNames = [
    'home',
    'category',
    'wishlist',
    'account',
  ];

  void _refreshPage(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        // Jika HomePage juga pakai BLoC, trigger event di sini
        break;

      case 1: // Category
        // Trigger ulang load categories
        context.read<CategoryBloc>().add(
          const CategoryEventGetAllCategories(1),
        );
        break;

      case 2: // Wishlist
        // Jika Wishlist pakai BLoC, trigger event di sini
        break;

      case 3: // account
        // Jika Account pakai BLoC, trigger event di sini
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _locationToIndex(currentPath);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (i) {
          final name = _routeNames[i];

          if (i == currentIndex) {
            // navigasi ke root route tab
            GoRouter.of(context).goNamed(name);

            // trigger refresh jika perlu
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                _refreshPage(context, i);
              } catch (e) {
                // Ignore errors jika bloc tidak tersedia
              }
            });

            return;
          }

          // tap pada tab berbeda -> pindah normal
          GoRouter.of(context).goNamed(name);
        },
      ),
    );
  }
}
