// lib/features/category/presentation/pages/category_detail_page.dart
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/pages/product_detail_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryId;
  final String? categoryName; // optional prefill
  final String? categoryTitle;
  final String? categorySubtitle;

  const CategoryDetailPage({
    Key? key,
    required this.categoryId,
    this.categoryName,
    this.categoryTitle,
    this.categorySubtitle,
  }) : super(key: key);

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  List<SubCategory> _subCategories = [];
  int _selectedSubIndex = 0;
  List<List<String>> _filters = [];
  bool _loadingSub = true;

  // local resolved texts (updated from bloc listener)
  String? _resolvedCategoryTitle;
  String? _resolvedCategorySubtitle;

  @override
  void initState() {
    super.initState();

    // init from incoming params
    _resolvedCategoryTitle = widget.categoryTitle;
    _resolvedCategorySubtitle = widget.categorySubtitle;

    // request detail & lists
    context.read<CategoryBloc>().add(
      CategoryEventGetDetailCategory(widget.categoryId),
    );

    // load subcategories & products
    _loadSubCategories();
    _loadProducts();
  }

  Future<void> _loadSubCategories() async {
    setState(() => _loadingSub = true);
    try {
      final categoryBloc = context.read<CategoryBloc>();
      // jika CategoryBloc punya helper getSubCategory (async), gunakan itu
      final response = await categoryBloc.getSubCategory(widget.categoryId);

      setState(() {
        _subCategories = response.subCategory ?? [];
        _filters = response.filters ?? [];

        // set default selected subcategory (first) jika tersedia
        if (_subCategories.isNotEmpty) {
          _selectedSubIndex = 0;
          for (int i = 0; i < _subCategories.length; i++) {
            _subCategories[i].status = (i == 0);
          }
        }
      });

      // jika ada filter/subcategory, reload products sesuai kebutuhan
      if (_filters.isNotEmpty || _subCategories.isNotEmpty) {
        _loadProducts();
      }
    } catch (e) {
      // ignore, biarkan kosong; UI akan menampilkan fallback
    } finally {
      setState(() => _loadingSub = false);
    }
  }

  void _loadProducts() {
    // saat ini kita fetch all products (ProductBloc akan handle caching/pagination)
    context.read<ProductBloc>().add(const ProductEventGetAllProducts(1));
  }

  // fallback resolver for category name used in product filtering
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
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryStateLoadedCategory) {
          // update local title/subtitle if available
          setState(() {
            _resolvedCategoryTitle =
                state.detailCategory.title ?? _resolvedCategoryTitle;
            _resolvedCategorySubtitle =
                state.detailCategory.subtitle ?? _resolvedCategorySubtitle;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),

            // Sub categories / title block
            if (!_loadingSub &&
                (_subCategories.isNotEmpty ||
                    (_resolvedCategoryTitle != null &&
                        _resolvedCategoryTitle!.isNotEmpty)))
              SliverToBoxAdapter(child: _buildSubCategoriesChips())
            else if (_loadingSub)
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Products grid
            _buildProductsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        String categoryName = widget.categoryName ?? 'Kategori';
        String? categoryImage;
        // String? categoryDescription;

        if (state is CategoryStateLoadedCategory) {
          categoryName = state.detailCategory.name;
          categoryImage = state.detailCategory.image;
          // categoryDescription = state.detailCategory.description;
        }

        return SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(
            icon: const Icon(
              FontAwesomeIcons.arrowLeft,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              categoryName,
              style: const TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xffffffff),
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
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
                // if (categoryDescription != null && categoryDescription.isNotEmpty)
                //   Positioned(
                //     bottom: 60,
                //     left: 0,
                //     right: 0,
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(
                //         horizontal: 32,
                //         vertical: 8,
                //       ),
                //       child: Text(
                //         categoryDescription,
                //         textAlign: TextAlign.center,
                //         style: TextStyle(
                //           fontFamily: AppFonts.primaryFont,
                //           fontSize: 12,
                //           color: Colors.white,
                //           shadows: [
                //             Shadow(
                //               color: Colors.black.withOpacity(0.5),
                //               blurRadius: 4,
                //             ),
                //           ],
                //         ),
                //         maxLines: 2,
                //         overflow: TextOverflow.ellipsis,
                //       ),
                //     ),
                //   ),
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
        fit: BoxFit.fill,
        placeholder: (context, url) => Container(
          color: const Color(0xFFB71C1C).withOpacity(0.3),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: const Color(0xFFB71C1C).withOpacity(0.3),
          child: const Center(
            child: Icon(Icons.image_not_supported, size: 60, color: Colors.white54),
          ),
        ),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.fill,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFB71C1C).withOpacity(0.3),
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 60, color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildSubCategoriesChips() {
    final displayTitle = _resolvedCategoryTitle ?? widget.categoryTitle;
    final displaySubtitle = _resolvedCategorySubtitle ?? widget.categorySubtitle;

    if (_subCategories.isEmpty && (displayTitle == null || displayTitle.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (displayTitle != null && displayTitle.isNotEmpty)
            Text(
              displayTitle,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          if (displaySubtitle != null && displaySubtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                displaySubtitle,
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
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
          return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        }

        if (state is ProductStateError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, style: TextStyle(fontFamily: AppFonts.primaryFont, color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadProducts, child: const Text('Coba Lagi')),
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
            return p.category?.name.toLowerCase().trim() == resolvedName.toLowerCase().trim();
          }).toList();

          if (filteredProducts.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('Belum ada produk dalam kategori ini', style: TextStyle(fontFamily: AppFonts.primaryFont, fontSize: 16, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Text('Kategori: ${resolvedName ?? widget.categoryName ?? "-"}', style: TextStyle(fontFamily: AppFonts.primaryFont, fontSize: 12, color: Colors.grey[500])),
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
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = filteredProducts[index];
                  return ProductCard(
                    product: product,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(productId: product.id.toString()),
                        ),
                      );
                      // refresh products after returning
                      _loadProducts();
                    },
                  );
                },
                childCount: filteredProducts.length,
              ),
            ),
          );
        }

        return const SliverFillRemaining(child: Center(child: Text('Tidak ada data')));
      },
    );
  }
}
