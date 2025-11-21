// lib/features/product/presentation/pages/product_page.dart

import 'dart:convert';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/filter_product.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/product_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProductPage extends StatefulWidget {
  final String? categoryName;
  final int? categoryId;

  const ProductPage({Key? key, this.categoryName, this.categoryId})
      : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final TextEditingController _searchController = TextEditingController();
  List<int> _selectedTypeIds = [];
  List<int> _selectedCategoryIds = [];

  Map<int, String> _typeNames = {};
  Map<int, String> _categoryNames = {};
  Map<int, List<int>> _categoryIdsByType = {};

  Category? _initialCategory;
  String _pageTitle = 'Produk';
  int? _lockedTypeId;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const ProductEventGetAllProducts(1));
    _loadFilterData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialCategory == null) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is Category) {
        _initialCategory = args;
        _pageTitle = args.name;

        _selectedCategoryIds = [args.id];

        if (args.type?.id != null) {
          _selectedTypeIds = [args.type!.id];
          _lockedTypeId = args.type!.id;
        }

        setState(() {});
      } else if (widget.categoryName != null) {
        _pageTitle = widget.categoryName!;
        if (widget.categoryId != null) {
          _selectedCategoryIds = [widget.categoryId!];
        }
        setState(() {});
      }
    }
  }

  Future<void> _loadFilterData() async {
    try {
      final String typesJson = await rootBundle.loadString(
        'assets/data/itemType.json',
      );
      final List<dynamic> typesData = jsonDecode(typesJson);
      for (var type in typesData) {
        final int id = (type['id'] ?? 0) is int
            ? type['id'] as int
            : int.parse((type['id'] ?? '0').toString());
        _typeNames[id] = type['name'] ?? '';
      }

      final String categoriesJson = await rootBundle.loadString(
        'assets/data/itemCategories.json',
      );
      final List<dynamic> categoriesData = jsonDecode(categoriesJson);
      for (var category in categoriesData) {
        final int catId = (category['id'] ?? 0) is int
            ? category['id'] as int
            : int.parse((category['id'] ?? '0').toString());
        _categoryNames[catId] = category['name'] ?? '';

        if (category['type'] != null && category['type']['id'] != null) {
          final int typeId = (category['type']['id'] ?? 0) is int
              ? category['type']['id'] as int
              : int.parse((category['type']['id'] ?? '0').toString());
          _categoryIdsByType.putIfAbsent(typeId, () => []);
          _categoryIdsByType[typeId]!.add(catId);
        }
      }

      setState(() {});
    } catch (e) {
      print('Error loading filter data: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _removeTypeFilter(int typeId) {
    if (_lockedTypeId != null && typeId == _lockedTypeId) {
      return;
    }

    setState(() {
      _selectedTypeIds.remove(typeId);
    });
  }

  void _loadProducts() {
    context.read<ProductBloc>().add(const ProductEventGetAllProducts(1));
  }

  void _removeCategoryFilter(int categoryId) {
    setState(() {
      _selectedCategoryIds.remove(categoryId);
    });
  }

  void _clearAllFilters() {
    setState(() {
      if (_lockedTypeId != null) {
        _selectedTypeIds = [_lockedTypeId!];
      } else {
        _selectedTypeIds.clear();
      }
      _selectedCategoryIds.clear();
      _searchController.clear();
    });
  }

  List<Product> _filterProducts(List<Product> products) {
    List<Product> filtered = products;

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((p) {
        final nameMatch = p.name.toLowerCase().contains(query);
        final typeMatch = (p.type?.name.toLowerCase().contains(query) ?? false);
        final itemCatMatch =
            (p.itemCategory?.name.toLowerCase().contains(query) ?? false);
        return nameMatch || typeMatch || itemCatMatch;
      }).toList();
    }

    List<int> categoryFilterIds = [];

    if (_selectedCategoryIds.isNotEmpty) {
      categoryFilterIds = List.from(_selectedCategoryIds);
    } else if (_selectedTypeIds.isNotEmpty) {
      final Set<int> allowed = {};
      for (final t in _selectedTypeIds) {
        final list = _categoryIdsByType[t];
        if (list != null && list.isNotEmpty) {
          allowed.addAll(list);
        }
      }
      categoryFilterIds = allowed.toList();
    }

    if (categoryFilterIds.isNotEmpty) {
      filtered = filtered.where((p) {
        final catId = p.itemCategory == null ? null : p.itemCategory!.id;
        if (catId == null) return false;
        return categoryFilterIds.contains(catId);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: _pageTitle),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.grayColor),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Cari',
                        hintStyle: TextStyle(
                          color: AppColors.grayColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        suffixIcon: Icon(
                          FontAwesomeIcons.magnifyingGlass,
                          color: Colors.grey.shade600,
                          size: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 45,
                  width: 45,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _showFilterBottomSheet(context),
                        child: Image.asset(
                          'assets/icons/filter.png',
                          width: 24,
                          height: 24,
                          color: Colors.black,
                        ),
                      ),
                      if (_selectedTypeIds.isNotEmpty ||
                          _selectedCategoryIds.isNotEmpty)
                        const Positioned(
                          right: 8,
                          top: 8,
                          child: CircleAvatar(
                            radius: 4,
                            backgroundColor: AppColors.primaryColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_selectedTypeIds.isNotEmpty || _selectedCategoryIds.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Aktif',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: _clearAllFilters,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Hapus Semua',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    'Type',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _selectedTypeIds.isEmpty
                      ? const Text('-', style: TextStyle(color: Colors.black54))
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedTypeIds.map((typeId) {
                            final isLocked =
                                _lockedTypeId != null &&
                                typeId == _lockedTypeId;
                            return _buildFilterChip(
                              label: _typeNames[typeId] ?? 'Type $typeId',
                              onRemove: isLocked
                                  ? null
                                  : () => _removeTypeFilter(typeId),
                              isLocked: isLocked,
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 12),

                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _selectedCategoryIds.isEmpty
                      ? const Text('-', style: TextStyle(color: Colors.black54))
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedCategoryIds.map((categoryId) {
                            return _buildFilterChip(
                              label:
                                  _categoryNames[categoryId] ??
                                  'Kategori $categoryId',
                              onRemove: () => _removeCategoryFilter(categoryId),
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                // ✅ PERUBAHAN: ProductLoading (bukan ProductStateLoading)
                if (state is ProductLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
                  );
                }

                // ✅ PERUBAHAN: ProductError (bukan ProductStateError)
                if (state is ProductError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ProductBloc>().add(
                              const ProductEventGetAllProducts(1),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB71C1C),
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                // ✅ PERUBAHAN: ProductLoaded (bukan ProductStateLoadedAllProduct)
                // ✅ PERUBAHAN: state.products (bukan state.allProduct)
                if (state is ProductLoaded) {
                  final filteredProducts = _filterProducts(state.products);

                  if (filteredProducts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada produk ditemukan',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          if (_selectedTypeIds.isNotEmpty ||
                              _selectedCategoryIds.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: TextButton(
                                onPressed: _clearAllFilters,
                                child: const Text(
                                  'Hapus Filter',
                                  style: TextStyle(color: Color(0xFFB71C1C)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          context.pushNamed(
                            'productDetail',
                            pathParameters: {'id': product.id.toString()},
                          ).then((_) => _loadProducts());
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    VoidCallback? onRemove,
    bool isLocked = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return FilterProduct(
          selectedTypeIds: _selectedTypeIds,
          selectedCategoryIds: _selectedCategoryIds,
          lockedTypeId: _lockedTypeId,
          onApplyFilter: (typeIds, categoryIds) {
            setState(() {
              _selectedTypeIds = typeIds;
              _selectedCategoryIds = categoryIds;
            });
          },
        );
      },
    );
  }
}