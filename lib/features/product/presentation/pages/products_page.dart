// lib/features/product/presentation/pages/products_page.dart
import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/product_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

final GetIt myinjection = GetIt.instance;

class ProductsPage extends StatefulWidget {
  final bool hotDealsOnly;
  final String title;

  const ProductsPage({
    Key? key,
    this.hotDealsOnly = false,
    this.title = 'Products',
  }) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late ProductBloc _bloc;
  List<Product> _allProducts = [];
  List<Product> _displayProducts = [];
  List<_CategoryItem> _categories = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // create a new ProductBloc using GetIt factory
    _bloc = myinjection<ProductBloc>();
    // Dispatch appropriate event
    if (widget.hotDealsOnly) {
      _bloc.add(ProductEventGetHotDeals());
    } else {
      _bloc.add(ProductEventGetAllProducts(1));
    }
  }

  void _buildCategoriesFromProducts() {
    final Map<int, String> map = {};
    for (var p in _allProducts) {
      final cat = p.category;
      if (cat != null) map.putIfAbsent(cat.id, () => cat.name);
    }
    _categories = map.entries
        .map((e) => _CategoryItem(id: e.key, name: e.value))
        .toList();
  }

  void _applyCategoryFilter() {
    // Note: This function is now safely called within setState inside the listener or
    // when a category chip is tapped.
    List<Product> results = List<Product>.from(_allProducts);

    // Filter and sort based on page type
    if (widget.hotDealsOnly) {
      // Hot Deals should already be filtered by the BLoC state, but we ensure sorting
      results = results.where((p) => p.isHotDeals == true).toList();
      results.sort((a, b) => a.id.compareTo(b.id)); // oldest first
    } else {
      // All Products, sort newest first
      results.sort((a, b) => b.id.compareTo(a.id)); // newest first
    }

    // Apply category filter
    if (_selectedCategoryId != null) {
      results = results
          .where((p) => p.category?.id == _selectedCategoryId)
          .toList();
    }

    // ⚠️ PENTING: setState dipanggil HANYA di listener atau saat category chip ditekan!
    // Di sini kita hanya mengupdate _displayProducts.
    _displayProducts = results;
  }

  void _onCategoryTap(int categoryId) {
    setState(() {
      if (_selectedCategoryId == categoryId) {
        _selectedCategoryId = null;
      } else {
        _selectedCategoryId = categoryId;
      }
      _applyCategoryFilter(); // Dipanggil di dalam setState, AMAN.
    });
  }

  @override
  void dispose() {
    // Bloc created by GetIt factory — we should close it to free resources.
    _bloc.close();
    super.dispose();
  }

  Widget _buildCategoryChips() {
    // show 'Semua' + categories from _categories
    if (_categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 30,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final selected = _selectedCategoryId == null;
            return _CategoryChip(
              label: 'Semua',
              selected: selected,
              onTap: () {
                setState(() {
                  _selectedCategoryId = null;
                  _applyCategoryFilter();
                });
              },
            );
          }
          final c = _categories[index - 1];
          final selected = _selectedCategoryId == c.id;
          return _CategoryChip(
            label: c.name,
            selected: selected,
            onTap: () => _onCategoryTap(c.id),
          );
        },
      ),
    );
  }

  Future<void> _refresh() async {
    if (widget.hotDealsOnly) {
      _bloc.add(ProductEventGetHotDeals());
    } else {
      _bloc.add(ProductEventGetAllProducts(1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: CustomAppBar(title: widget.title),
        body: SafeArea(
          child: BlocConsumer<ProductBloc, ProductState>(
            listener: (context, state) {
              // ✅ PERBAIKAN PENTING: Pindahkan logika pembaruan state ke listener
              if (state is ProductStateLoadedHotDeals) {
                setState(() {
                  _allProducts = state.hotDeals;
                  _buildCategoriesFromProducts();
                  _applyCategoryFilter(); // Memperbarui _displayProducts
                });
              } else if (state is ProductStateLoadedAllProduct) {
                setState(() {
                  _allProducts = state.allProduct;
                  _buildCategoriesFromProducts();
                  _applyCategoryFilter(); // Memperbarui _displayProducts
                });
              }
            },
            builder: (context, state) {
              if (state is ProductStateLoading || state is ProductStateEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ProductStateError) {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: Text('Gagal memuat produk: ${state.message}'),
                      ),
                    ],
                  ),
                );
              }

              // ⚠️ Hapus semua logika pembaruan _allProducts dan setState dari sini.
              // Cukup gunakan _displayProducts yang sudah diupdate oleh listener.

              // now build UI using _displayProducts
              return RefreshIndicator(
                onRefresh: _refresh,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // header and subtitle
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // category chips
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _buildCategoryChips(),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),

                    // product grid/list
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      sliver: _displayProducts.isEmpty
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                  ),
                                  child: Text(
                                    'Belum ada produk untuk kriteria ini.',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.72,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final p = _displayProducts[index];
                                return ProductCard(
                                  product: p,
                                  width: double.infinity,
                                  onTap: () {
                                    // navigate to product detail (dispatch event / route)
                                    Navigator.pushNamed(
                                      context,
                                      '/productDetail',
                                      arguments: p.id.toString(),
                                    );
                                  },
                                );
                              }, childCount: _displayProducts.length),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
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
          color: selected ? Theme.of(context).primaryColor : Colors.white,
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
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
