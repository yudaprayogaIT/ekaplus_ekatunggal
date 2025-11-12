// lib/core/routes/my_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ekaplus_ekatunggal/features/home/presentation/pages/home_page.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/pages/category.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';
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

  /// Method untuk refresh page berdasarkan index
  void _refreshPage(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        // Jika HomePage juga pakai BLoC, trigger event di sini
        // context.read<HomeBloc>().add(HomeEventRefresh());
        break;
        
      case 1: // Category
        // Trigger ulang load categories
        context.read<CategoryBloc>().add(
          const CategoryEventGetAllCategories(1),
        );
        break;
        
      case 2: // Favorites
        // Jika Favorites pakai BLoC, trigger event di sini
        // context.read<FavoritesBloc>().add(FavoritesEventRefresh());
        break;
        
      case 3: // Profile
        // Jika Profile pakai BLoC, trigger event di sini
        // context.read<ProfileBloc>().add(ProfileEventRefresh());
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
      // 1) navigasi ke root route tab itu
      // Use GoRouter.of(context).go to ensure we call the router directly
      GoRouter.of(context).goNamed(name);

      // 2) setelah navigasi selesai (post-frame) trigger refresh jika perlu
      // gunakan microtask/post frame supaya event diproses setelah route berubah
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _refreshPage(context, i);
        } catch (e) {
          // kalau bloc tidak tersedia di level ini, jangan crash — hanya cetak
          // atau bisa kirim notification agar page sendiri yang menangani refresh
          // debugPrint('Refresh event failed: $e');
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