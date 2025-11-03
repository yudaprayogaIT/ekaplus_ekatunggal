// lib/features/category/presentation/pages/category.dart
import 'package:flutter/material.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import '../../data/category_repository.dart';
import '../../data/models/category_item.dart';

class CategoryPage extends StatefulWidget {
  final String? initialCategory;
  const CategoryPage({super.key, this.initialCategory});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late final CategoryRepository _repo;
  late Future<List<CategoryItem>> _futureItems;

  @override
  void initState() {
    super.initState();
    _repo = CategoryRepository();
    _futureItems = _repo.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialCategory ?? 'Semua Produk', style: TextStyle(fontFamily: AppFonts.primaryFont)),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: FutureBuilder<List<CategoryItem>>(
        future: _futureItems,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data'));
          }

          final items = snap.data!;
          final Map<String, List<CategoryItem>> grouped = {};
          for (final it in items) {
            grouped.putIfAbsent(it.type, () => []).add(it);
          }

          final keys = grouped.keys.toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // filter / selector
                const SizedBox(height: 6),
                Text('Kategori', style: TextStyle(fontFamily: AppFonts.primaryFont, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 6)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.initialCategory ?? 'Pilih Kategori', style: TextStyle(fontFamily: AppFonts.primaryFont)),
                      const Icon(Icons.keyboard_arrow_down)
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // sections
                for (final key in keys) ...[
                  Text(key, style: TextStyle(fontFamily: AppFonts.primaryFont, fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 6)],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: grouped[key]!.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, idx) {
                        final it = grouped[key]![idx];
                        return ListTile(
                          onTap: () {
                            // nanti navigasi ke halaman detail kategori / list produk
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Buka ${it.name} (stub)')));
                          },
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: it.image.isNotEmpty
                                  ? Image.asset(it.image, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.category))
                                  : const Icon(Icons.category),
                            ),
                          ),
                          title: Text(it.name, style: TextStyle(fontFamily: AppFonts.primaryFont, fontWeight: FontWeight.w600)),
                          subtitle: Text(it.desc, style: TextStyle(fontFamily: AppFonts.primaryFont, fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
