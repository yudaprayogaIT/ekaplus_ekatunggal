// lib/core/routes/my_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ekaplus_ekatunggal/features/home/presentation/pages/home_page.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/pages/category.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/bottom_nav.dart';

class MyRouter {
  GoRouter get router => GoRouter(
        initialLocation: "/",
        routes: [
          ShellRoute(
            builder: (context, state, child) {
              return AppShell(
                currentPath: state.matchedLocation,
                child: child,
              );
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
                name: 'favorites',
                path: '/favorites',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Favorites (placeholder)')),
                ),
              ),
              GoRoute(
                name: 'profile',
                path: '/profile',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Profile (placeholder)')),
                ),
              ),
            ],
          ),
          // Route tanpa bottom nav (jika diperlukan)
          // GoRoute(
          //   name: 'promoDetail',
          //   path: '/promo/:id',
          //   builder: (context, state) {
          //     final id = state.pathParameters['id'];
          //     return Scaffold(
          //       appBar: AppBar(title: Text('Promo $id')),
          //       body: Center(child: Text('Detail promo: $id')),
          //     );
          //   },
          // ),
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
  
  const AppShell({
    required this.child,
    required this.currentPath,
    super.key,
  });

  int _locationToIndex(String path) {
    if (path.startsWith('/category')) return 1;
    if (path.startsWith('/favorites')) return 2;
    if (path.startsWith('/profile')) return 3;
    return 0;
  }

  static const List<String> _routeNames = [
    'home',
    'category',
    'favorites',
    'profile'
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _locationToIndex(currentPath);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (i) {
          if (i == currentIndex) return;
          final name = _routeNames[i];
          context.goNamed(name);
        },
      ),
    );
  }
}