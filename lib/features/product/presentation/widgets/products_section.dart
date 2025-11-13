// lib/features/product/presentation/widgets/product_section.dart
import 'dart:convert';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✅ TAMBAHKAN
import 'package:ekaplus_ekatunggal/features/product/data/models/product_model.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/product_card.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';

class ProductsSection extends StatefulWidget {
  final String title;
  final String? subtitle;
  final int showCount;
  final bool hotDealsOnly;

  const ProductsSection({
    Key? key,
    this.title = 'Yang Baru Dari Kami',
    this.subtitle,
    this.showCount = 6,
    this.hotDealsOnly = false,
  }) : super(key: key);

  @override
  State<ProductsSection> createState() => _ProductsSectionState();
}

class _ProductsSectionState extends State<ProductsSection> {
  late Future<List<ProductModel>> _futureProducts;
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  List<_CategoryItem> _categories = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _futureProducts = _loadProductsFromAssets();
  }

  Future<List<ProductModel>> _loadProductsFromAssets() async {
    final body = await rootBundle.loadString('assets/data/products.json');
    final dynamic decoded = jsonDecode(body);
    final List<dynamic> list = decoded is List
        ? decoded
        : (decoded['data'] ?? []);
    final products = ProductModel.fromJsonList(list);
    _allProducts = products;
    _buildCategoryList();
    _applyFiltersAndSort();
    return products;
  }

  void _buildCategoryList() {
    final Map<int, String> map = {};
    for (var p in _allProducts) {
      final cat = p.itemCategory;
      if (cat != null) {
        map.putIfAbsent(cat.id, () => cat.name);
      }
    }
    _categories = map.entries
        .map((e) => _CategoryItem(id: e.key, name: e.value))
        .toList();
  }

  void _applyFiltersAndSort() {
    List<ProductModel> results = List<ProductModel>.from(_allProducts);

    if (widget.hotDealsOnly) {
      results = results.where((p) => p.isHotDeals == true).toList();
      results.sort((a, b) => a.id.compareTo(b.id));
    } else {
      results.sort((a, b) => b.id.compareTo(a.id));
    }

    if (_selectedCategoryId != null) {
      results = results
          .where((p) => p.itemCategory?.id == _selectedCategoryId)
          .toList();
    }

    _filteredProducts = results;
  }

  void _onCategoryTap(int categoryId) {
    setState(() {
      if (_selectedCategoryId == categoryId) {
        _selectedCategoryId = null;
      } else {
        _selectedCategoryId = categoryId;
      }
      _applyFiltersAndSort();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: _futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('Gagal memuat produk: ${snapshot.error}'),
          );
        }

        if (_allProducts.isEmpty) {
          final products = snapshot.data ?? [];
          _allProducts = products;
          _buildCategoryList();
          _applyFiltersAndSort();
        }

        if (_filteredProducts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // ✅ PERBAIKAN: Gunakan GoRouter
                        context.pushNamed(
                          'productsHighlight',
                          extra: {
                            'hotDealsOnly': widget.hotDealsOnly,
                            'title': widget.hotDealsOnly
                                ? 'Produk Terlaris'
                                : 'Produk Terbaru',
                            'headerTitle': widget.hotDealsOnly
                                ? 'Jangan Kehabisan Produk Terlaris 🤩'
                                : 'Yang Baru Dari Kami 🔥',
                            'headerSubTitle': widget.hotDealsOnly
                                ? 'Siapa cepat, dia dapat, sikaaat ...'
                                : 'Yang baru - baru, dijamin menarik !!!',
                          },
                        );
                      },
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: const TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _buildCategoryChips(),
                const SizedBox(height: 16),
                SizedBox(
                  height: 260,
                  child: ListView.custom(
                    scrollDirection: Axis.horizontal,
                    childrenDelegate: SliverChildListDelegate([
                      const Text('Belum ada produk untuk kriteria ini.'),
                    ]),
                  ),
                ),
              ],
            ),
          );
        }

        final displayList = _filteredProducts.take(widget.showCount).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.primaryFont,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // ✅ PERBAIKAN: Gunakan GoRouter
                      context.pushNamed(
                        'productsHighlight',
                        extra: {
                          'hotDealsOnly': widget.hotDealsOnly,
                          'title': widget.hotDealsOnly
                              ? 'Produk Terlaris'
                              : 'Produk Terbaru',
                          'headerTitle': widget.hotDealsOnly
                              ? 'Jangan Kehabisan Produk Terlaris 🤩'
                              : 'Yang Baru Dari Kami 🔥',
                          'headerSubTitle': widget.hotDealsOnly
                              ? 'Siapa cepat, dia dapat, sikaaat ...'
                              : 'Yang baru - baru, dijamin menarik !!!',
                        },
                      );
                    },
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              if (widget.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.subtitle!,
                  style: const TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const SizedBox(height: 10),

              _buildCategoryChips(),

              const SizedBox(height: 12),

              SizedBox(
                height: 280,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  itemCount: displayList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 20),
                  itemBuilder: (context, index) {
                    final p = displayList[index];
                    return ProductCard(
                      product: p,
                      width: 176,
                      onTap: () {
                        // ✅ PERBAIKAN: Gunakan GoRouter
                        context.pushNamed(
                          'productDetail',
                          pathParameters: {'id': p.id.toString()},
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChips() {
    if (_categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final bool selected = _selectedCategoryId == null;
            return _CategoryChip(
              label: 'Semua',
              selected: selected,
              onTap: () {
                setState(() {
                  _selectedCategoryId = null;
                  _applyFiltersAndSort();
                });
              },
            );
          }
          final c = _categories[index - 1];
          final bool selected = _selectedCategoryId == c.id;
          return _CategoryChip(
            label: c.name,
            selected: selected,
            onTap: () => _onCategoryTap(c.id),
          );
        },
      ),
    );
  }
}

class _CategoryItem {
  final int id;
  final String name;
  _CategoryItem({required this.id, required this.name});
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.grey.shade300,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.14),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.black87,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}