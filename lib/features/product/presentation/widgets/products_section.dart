// lib/features/product/presentation/widgets/products_section.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProductsSection extends StatefulWidget {
  final String title;
  final String? subtitle;
  final int showCount;
  final bool hotDealsOnly;
  final bool isLoggedIn;

  const ProductsSection({
    Key? key,
    this.title = 'Yang Baru Dari Kami',
    this.subtitle,
    this.showCount = 6,
    this.hotDealsOnly = false,
    this.isLoggedIn = false,
  }) : super(key: key);

  @override
  State<ProductsSection> createState() => _ProductsSectionState();
}

class _ProductsSectionState extends State<ProductsSection> {
  List<_CategoryItem> _categories = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // 🔥 NO NEED TO LOAD: ProductBloc is Singleton and already loaded in main.dart
    // Just check if we need to trigger load (only if state is Initial and no cache)
    final productBloc = context.read<ProductBloc>();
    
    if (productBloc.state is ProductInitial && !productBloc.hasCachedData) {
      _loadProducts();
    } else if (productBloc.state is ProductInitial && productBloc.hasCachedData) {
      // Trigger cached data emission
      productBloc.add(const ProductEventGetAllProducts());
    }
  }

  void _loadProducts() {
    if (widget.hotDealsOnly) {
      context.read<ProductBloc>().add(const ProductEventGetHotDeals());
    } else {
      context.read<ProductBloc>().add(const ProductEventGetAllProducts());
    }
  }

  void _buildCategoryList(List products) {
    final Map<int, String> map = {};
    for (var p in products) {
      final cat = p.itemCategory;
      if (cat != null) {
        map.putIfAbsent(cat.id, () => cat.name);
      }
    }
    _categories = map.entries
        .map((e) => _CategoryItem(id: e.key, name: e.value))
        .toList();
  }

  List _filterProducts(List products) {
    List results = List.from(products);

    // Filter by hot deals
    if (widget.hotDealsOnly) {
      results = results.where((p) => p.isHotDeals == true).toList();
      results.sort((a, b) => a.id.compareTo(b.id));
    } else {
      results.sort((a, b) => b.id.compareTo(a.id));
    }

    // Filter by category
    if (_selectedCategoryId != null) {
      results = results
          .where((p) => p.itemCategory?.id == _selectedCategoryId)
          .toList();
    }

    return results;
  }

  void _onCategoryTap(int categoryId) {
    setState(() {
      if (_selectedCategoryId == categoryId) {
        _selectedCategoryId = null;
      } else {
        _selectedCategoryId = categoryId;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthSessionCubit, AuthSessionState>(
      builder: (context, authState) {
        final isLoggedIn = authState is AuthSessionAuthenticated;

        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, productState) {
            // Loading state
            if (productState is ProductLoading) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SizedBox(
                  height: 200,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            // Error state
            if (productState is ProductError) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Gagal memuat produk: ${productState.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Force refresh (bypass cache)
                        context.read<ProductBloc>().add(
                          const ProductEventRefreshProducts(),
                        );
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            // Loaded state
            if (productState is ProductLoaded) {
              final allProducts = productState.products;

              // Build category list (hanya sekali)
              if (_categories.isEmpty && allProducts.isNotEmpty) {
                _buildCategoryList(allProducts);
              }

              // Filter products
              final filteredProducts = _filterProducts(allProducts);

              // Empty state
              if (filteredProducts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
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
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'Belum ada produk untuk kriteria ini.',
                          style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Display products
              final displayList = filteredProducts.take(widget.showCount).toList();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
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
                          final product = displayList[index];
                          return ProductCard(
                            product: product,
                            width: 176,
                            showWishlistButton: isLoggedIn,
                            onTap: () {
                              context.pushNamed(
                                'productDetail',
                                pathParameters: {'id': product.id.toString()},
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            // Initial/Unknown state
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
            context.pushNamed(
              'productsHighlight',
              extra: {
                'hotDealsOnly': widget.hotDealsOnly,
                'title': widget.hotDealsOnly ? 'Produk Terlaris' : 'Produk Terbaru',
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
                });
              },
            );
          }
          final category = _categories[index - 1];
          final bool selected = _selectedCategoryId == category.id;
          return _CategoryChip(
            label: category.name,
            selected: selected,
            onTap: () => _onCategoryTap(category.id),
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
          color: selected ? AppColors.secondaryColor : AppColors.whiteColor,
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