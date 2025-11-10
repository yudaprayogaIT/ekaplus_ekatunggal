// lib/features/category/presentation/pages/category_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/pages/product_detail_page.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryId;
  final String? categoryName; // Optional, untuk tampil langsung tanpa fetch

  const CategoryDetailPage({
    Key? key,
    required this.categoryId,
    this.categoryName,
  }) : super(key: key);

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  List<SubCategory> _subCategories = [];
  int _selectedSubIndex = 0;
  List<List<String>> _filters = [];
  bool _loadingSub = true;
  String? _lastLoadedCategoryId;

  @override
  void initState() {
    super.initState();
    _lastLoadedCategoryId = widget.categoryId;
    // Fetch category detail
    context.read<CategoryBloc>().add(
      CategoryEventGetDetailCategory(widget.categoryId),
    );
    // Fetch subcategories
    _loadSubCategories();
    // Load products
    _loadProducts();
  }

  Future<void> _loadSubCategories() async {
    try {
      setState(() => _loadingSub = true);
      final categoryBloc = context.read<CategoryBloc>();

      // Jika CategoryBloc menyediakan helper (getSubCategory) gunakan, jika tidak fallback
      // Kita bungkus try/catch untuk keamanan.
      final response = await categoryBloc.getSubCategory(widget.categoryId);

      setState(() {
        _subCategories = response.subCategory ?? [];
        _filters = response.filters ?? [];
      });

      // Load products untuk subcategory pertama (opsional)
      if (_filters.isNotEmpty) {
        _loadProducts();
      }
    } catch (e) {
      // Kalau gagal, biarkan _subCategories tetap kosong dan tampilkan pesan ringan
      // debugPrint('Error load subcategories: $e');
    } finally {
      setState(() => _loadingSub = false);
    }
  }

  void _loadProducts() {
    // request ulang semua produk ke ProductBloc
    // (ProductBloc akan men-return ProductStateLoadedAllProduct)
    context.read<ProductBloc>().add(const ProductEventGetAllProducts(1));
  }

  void _selectSubCategory(int index) {
    setState(() {
      _selectedSubIndex = index;
      for (int i = 0; i < _subCategories.length; i++) {
        _subCategories[i].status = (i == index);
      }
    });
    _loadProducts();
  }

  // Helper: resolve category name (widget param atau dari CategoryBloc state)
  String? _resolvedCategoryName() {
    if (widget.categoryName != null && widget.categoryName!.isNotEmpty) {
      return widget.categoryName;
    }
    final state = context.read<CategoryBloc>().state;
    if (state is CategoryStateLoadedCategory) {
      return state.detailCategory.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar dengan kategori banner
          _buildSliverAppBar(),

          // Sub Categories Chips
          if (!_loadingSub && _subCategories.isNotEmpty)
            SliverToBoxAdapter(child: _buildSubCategoriesChips())
          else if (_loadingSub)
            const SliverToBoxAdapter(
              child: SizedBox(height: 12),
            ),

          // Products Grid
          _buildProductsGrid(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        String categoryName = widget.categoryName ?? 'Kategori';
        String? categoryImage; // gunakan IMAGE bukan ICON
        String? categoryDescription;

        if (state is CategoryStateLoadedCategory) {
          categoryName = state.detailCategory.name;
          categoryImage = state.detailCategory.image;
          categoryDescription = state.detailCategory.description;
        }

        return SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          backgroundColor: const Color(0xFFB71C1C),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              categoryName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFB71C1C).withOpacity(0.7),
                        const Color(0xFFB71C1C),
                      ],
                    ),
                  ),
                ),

                // Category Image sebagai Background
                if (categoryImage != null && categoryImage.isNotEmpty)
                  _buildCategoryBannerImage(categoryImage)
                else
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 60),
                      child: const Icon(
                        Icons.category,
                        size: 80,
                        color: Colors.white54,
                      ),
                    ),
                  ),

                // Description at bottom
                if (categoryDescription != null && categoryDescription.isNotEmpty)
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                      child: Text(
                        categoryDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 12,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryBannerImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: const Color(0xFFB71C1C).withOpacity(0.3),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: const Color(0xFFB71C1C).withOpacity(0.3),
          child: const Center(
            child:
                Icon(Icons.image_not_supported, size: 60, color: Colors.white54),
          ),
        ),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFB71C1C).withOpacity(0.3),
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 60, color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildSubCategoriesChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Kategori',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _subCategories.length,
              itemBuilder: (context, index) {
                final subCat = _subCategories[index];
                final isSelected = subCat.status;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      subCat.name,
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _selectSubCategory(index);
                      }
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color(0xFFB71C1C),
                    checkmarkColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color:
                            isSelected ? const Color(0xFFB71C1C) : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductStateLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ProductStateError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProducts,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is ProductStateLoadedAllProduct) {
          final products = state.allProduct;

          final resolvedName = _resolvedCategoryName();
          final filteredProducts = products.where((p) {
            if (resolvedName == null) return false;
            return p.category?.name.toLowerCase().trim() ==
                resolvedName.toLowerCase().trim();
          }).toList();

          if (filteredProducts.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada produk dalam kategori ini',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kategori: ${resolvedName ?? widget.categoryName ?? "-"}',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = filteredProducts[index];
                return _buildProductCard(product);
              }, childCount: filteredProducts.length),
            ),
          );
        }

        return const SliverFillRemaining(
          child: Center(child: Text('Tidak ada data')),
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final firstVariant = product.variants.isNotEmpty ? product.variants[0] : null;

    return GestureDetector(
      onTap: () async {
        // TUTUP modal jika halaman ini mungkin dibuka dari modal (umumnya sudah bukan modal)
        // AWAIT navigation sehingga saat kembali kita bisa me-refresh produk
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productId: product.id.toString()),
          ),
        );
        // Saat kembali ke halaman category, reload products (refresh filter)
        _loadProducts();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: firstVariant?.image != null && firstVariant!.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: firstVariant.image.startsWith('http')
                              ? firstVariant.image
                              : 'https://your-domain.com${firstVariant.image}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (c, u) => Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (ctx, url, err) {
                            // fallback asset
                            try {
                              final assetPath = 'assets${firstVariant.image}';
                              return Image.asset(
                                assetPath,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            } catch (_) {
                              return const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              );
                            }
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category?.name ?? '',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${product.variants.length} Varian',
                          style: TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontSize: 11,
                            color: const Color(0xFFB71C1C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (product.isHotDeals)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'HOT',
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
