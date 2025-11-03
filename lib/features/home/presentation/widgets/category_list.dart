// lib/features/home/presentation/widgets/category_list.dart
import 'package:flutter/material.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/pages/category.dart';
import 'package:ekaplus_ekatunggal/features/category/data/category_repository.dart';
import 'package:ekaplus_ekatunggal/features/category/data/models/category_item.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = CategoryRepository();

    return FutureBuilder<List<CategoryItem>>(
      future: repo.loadAll(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
          );
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = snap.data!;
        // group by type, keep first image as icon for that type
        final Map<String, CategoryItem> representative = {};
        for (final it in items) {
          if (!representative.containsKey(it.type)) {
            representative[it.type] = it;
          }
        }

        final types = representative.entries.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Temukan Produk Yang Anda Cari',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                scrollDirection: Axis.horizontal,
                itemCount: types.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, idx) {
                  final entry = types[idx];
                  final typeLabel = entry.key;
                  final iconItem = entry.value;
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CategoryPage(
                                initialCategory: typeLabel,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 6)],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: iconItem.image.isNotEmpty
                                ? Image.asset(
                                    iconItem.image,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Icon(Icons.category, color: AppColors.primaryColor),
                                  )
                                : Icon(Icons.category, color: AppColors.primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 82,
                        child: Text(
                          typeLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, fontFamily: AppFonts.primaryFont),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CategoryPage()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  textStyle: TextStyle(fontFamily: AppFonts.primaryFont, fontWeight: FontWeight.w600),
                ),
                child: const Text('Lihat Semua'),
              ),
            ),
          ],
        );
      },
    );
  }
}
