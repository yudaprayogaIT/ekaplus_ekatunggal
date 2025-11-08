// lib/features/product/presentation/widgets/section_with_products.dart
import 'dart:convert';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:ekaplus_ekatunggal/features/product/data/models/product_model.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/product_card.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';

class SectionWithProducts extends StatefulWidget {
  final String title;
  final String? subtitle;
  final int showCount;
  final bool hotDealsOnly;

  /// hotDealsOnly: jika true -> tampilkan hanya yang isHotDeals == true (urut id asc/oldest)
  /// jika false -> tampilkan semua produk (urut id desc/newest)
  const SectionWithProducts({
    Key? key,
    this.title = 'Yang Baru Dari Kami',
    this.subtitle,
    this.showCount = 6,
    this.hotDealsOnly = false,
  }) : super(key: key);

  @override
  State<SectionWithProducts> createState() => _SectionWithProductsState();
}

class _SectionWithProductsState extends State<SectionWithProducts> {
  late Future<List<ProductModel>> _futureProducts;
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  List<_CategoryItem> _categories = [];
  int? _selectedCategoryId; // null = show semua

  @override
  void initState() {
    super.initState();
    _futureProducts = _loadProductsFromAssets();
  }

  Future<List<ProductModel>> _loadProductsFromAssets() async {
    final body = await rootBundle.loadString('assets/data/products.json');
    final dynamic decoded = jsonDecode(body);
    final List<dynamic> list = decoded is List ? decoded : (decoded['data'] ?? []);
    final products = ProductModel.fromJsonList(list);
    // simpan ke state-ready lists (tidak langsung setState di init)
    _allProducts = products;
    _buildCategoryList();
    _applyFiltersAndSort();
    return products;
  }

  void _buildCategoryList() {
    final Map<int, String> map = {};
    for (var p in _allProducts) {
      final cat = p.category;
      if (cat != null) {
        map.putIfAbsent(cat.id, () => cat.name);
      }
    }
    _categories = map.entries
        .map((e) => _CategoryItem(id: e.key, name: e.value))
        .toList();
  }

  void _applyFiltersAndSort() {
    // start from all products
    List<ProductModel> results = List<ProductModel>.from(_allProducts);

    // filter hot deals if requested
    if (widget.hotDealsOnly) {
      results = results.where((p) => p.isHotDeals == true).toList();
      // sort by id ascending (oldest first)
      results.sort((a, b) => a.id.compareTo(b.id));
    } else {
      // not hot deals mode -> show all but sort newest first (id desc)
      results.sort((a, b) => b.id.compareTo(a.id));
    }

    // apply category filter if selected
    if (_selectedCategoryId != null) {
      results = results.where((p) => p.category?.id == _selectedCategoryId).toList();
    }

    _filteredProducts = results;
  }

  void _onCategoryTap(int categoryId) {
    setState(() {
      if (_selectedCategoryId == categoryId) {
        // toggle off
        _selectedCategoryId = null;
      } else {
        _selectedCategoryId = categoryId;
      }
      _applyFiltersAndSort();
    });
  }

  String _normalizeImagePathFromVariant(Product p) {
    try {
      if (p.variants.isNotEmpty) {
        final v = p.variants.first;
        final raw = (v as dynamic).image ?? '';
        if (raw is String && raw.isNotEmpty) {
          // remove any leading slashes and prefix with assets/
          final normalized = raw.replaceFirst(RegExp(r'^/+'), '');
          if (normalized.startsWith('assets/')) return normalized;
          return 'assets/$normalized';
        }
      }
    } catch (_) {}
    return ''; // fallback
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: _futureProducts,
      builder: (context, snapshot) {
        // Loading
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

        // Data ready: use _filteredProducts (already computed in init)
        // but ensure we recompute if _allProducts was empty earlier
        if (_allProducts.isEmpty) {
          final products = snapshot.data ?? [];
          _allProducts = products;
          _buildCategoryList();
          _applyFiltersAndSort();
        }

        // guard: still empty
        if (_filteredProducts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    InkWell(onTap: () {}, child: const Text('Lihat Semua', style: TextStyle(fontSize: 13, color: Colors.grey))),
                  ],
                ),
                const SizedBox(height: 8),
                // categories (still show)
                _buildCategoryChips(),
                const SizedBox(height: 16),
                const Text('Belum ada produk untuk kriteria ini.'),
              ],
            ),
          );
        }

        // take showCount after filtering and sorting
        final displayList = _filteredProducts.take(widget.showCount).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header: title + lihat semua
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: AppFonts.primaryFont),
                  ),
                  InkWell(
                    onTap: () {
                      // TODO: navigate to all products page
                    },
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),

              if (widget.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(widget.subtitle!, style: const TextStyle(color: AppColors.grayColor, fontSize: 11, fontWeight: FontWeight.w500)),
              ],

              const SizedBox(height: 10),

              // category chips
              _buildCategoryChips(),

              const SizedBox(height: 12),

              // horizontal product list
              SizedBox(
                height: 260,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  itemCount: displayList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 20),
                  itemBuilder: (context, index) {
                    final p = displayList[index];
                    // ProductCard expects Product entity; our ProductModel extends Product so it's fine
                    return ProductCard(
                      product: p,
                      width: 176,
                      onTap: () {
                        // TODO: buka detail product (dispatch bloc / navigate)
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
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1, // +1 for 'All' chip
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.transparent : Colors.grey.shade300),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.14),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
