// lib/core/routes/my_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ekaplus_ekatunggal/features/home/presentation/pages/home_page.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/pages/category.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/bottom_nav.dart';

class MyRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      ShellRoute(
        // gunakan state.uri (bukan state.location)
        builder: (BuildContext context, GoRouterState state, Widget child) {
          // ambil path dari Uri, misal "/promo/123" -> "/promo/123"
          final currentPath = state.uri.path;
          return AppShell(child: child, currentPath: currentPath);
        },
        routes: <RouteBase>[
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
          // GoRoute(
          //   name: 'promoDetail',
          //   path: '/promo/:id',
          //   builder: (context, state) {
          //     final id = state.params['id'];
          //     return Scaffold(
          //       appBar: AppBar(title: Text('Promo $id')),
          //       body: Center(child: Text('Detail promo: $id')),
          //     );
          //   },
          // ),
        ],
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
    if (path.startsWith('/favorites')) return 2;
    if (path.startsWith('/profile')) return 3;
    return 0;
  }

  static const List<String> _routeNames = ['home', 'category', 'favorites', 'profile'];

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
          GoRouter.of(context).goNamed(name);
        },
      ),
    );
  }
}
