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
                  // tampilkan modal bottom sheet yang LOAD DATA sendiri dari assets via CategoryRepository
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) => FractionallySizedBox(
                      heightFactor: 0.85,
                      child: const AllCategoriesModal(), // modal akan fetch sendiri
                    ),
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

/// Modal yang mem-fetch data dari assets/data/ melalui CategoryRepository
class AllCategoriesModal extends StatefulWidget {
  const AllCategoriesModal({super.key});

  @override
  State<AllCategoriesModal> createState() => _AllCategoriesModalState();
}

class _AllCategoriesModalState extends State<AllCategoriesModal> {
  late final Future<List<CategoryItem>> _futureItems;
  final CategoryRepository _repo = CategoryRepository();

  @override
  void initState() {
    super.initState();
    // pastikan CategoryRepository.loadAll() membaca dari assets/data/categories.json
    _futureItems = _repo.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Semua Kategori',
              style: TextStyle(fontFamily: AppFonts.primaryFont, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<CategoryItem>>(
                future: _futureItems,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snap.hasData || snap.data!.isEmpty) {
                    return const Center(child: Text('Tidak ada kategori'));
                  }

                  final items = snap.data!;
                  // group by type (sama seperti di halaman)
                  final Map<String, CategoryItem> representative = {};
                  for (final it in items) {
                    if (!representative.containsKey(it.type)) {
                      representative[it.type] = it;
                    }
                  }
                  final types = representative.entries.toList();

                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 20, top: 4),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.82,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: types.length,
                    itemBuilder: (context, index) {
                      final entry = types[index];
                      final typeLabel = entry.key;
                      final iconItem = entry.value;

                      return GestureDetector(
                        onTap: () {
                          // tutup modal, lalu buka halaman CategoryPage dengan initialCategory
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CategoryPage(initialCategory: typeLabel),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 78,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 6)],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: iconItem.image.isNotEmpty
                                    ? Image.asset(
                                        iconItem.image,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => Icon(Icons.category, color: AppColors.primaryColor),
                                      )
                                    : Icon(Icons.category, color: AppColors.primaryColor),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              typeLabel,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: AppFonts.primaryFont, fontSize: 12),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
