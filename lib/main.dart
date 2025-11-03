import 'package:flutter/material.dart';
import 'core/shared_widgets/bottom_nav.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'constant.dart';

void main() {
  runApp(const EkaplusApp());
}

class EkaplusApp extends StatelessWidget {
  const EkaplusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ekaplus Ekatunggal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: AppFonts.primaryFont,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
      ),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    Center(child: Text('Kategori (placeholder)')),
    Center(child: Text('Favorit (placeholder)')),
    Center(child: Text('Profile (placeholder)')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
