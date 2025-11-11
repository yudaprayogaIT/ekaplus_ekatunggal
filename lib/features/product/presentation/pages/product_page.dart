// lib/features/product/presentation/pages/product_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/filter_product.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/product_card.dart';

class ProductPage extends StatefulWidget {
  final String? categoryName;
  final int? categoryId;

  const ProductPage({
    Key? key,
    this.categoryName,
    this.categoryId,
  }) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final TextEditingController _searchController = TextEditingController();
  List<int> _selectedTypeIds = [];
  List<int> _selectedCategoryIds = [];

  // Maps untuk menyimpan nama Type dan Category
  Map<int, String> _typeNames = {};
  Map<int, String> _categoryNames = {};

  // tambahan: mapping typeId -> list of categoryIds
  Map<int, List<int>> _categoryIdsByType = {};

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const ProductEventGetAllProducts(1));
    _loadFilterData();
  }

  Future<void> _loadFilterData() async {
    try {
      // Load Type names
      final String typesJson = await rootBundle.loadString('assets/data/itemType.json');
      final List<dynamic> typesData = jsonDecode(typesJson);
      for (var type in typesData) {
        final int id = (type['id'] ?? 0) is int ? type['id'] as int : int.parse((type['id'] ?? '0').toString());
        _typeNames[id] = type['name'] ?? '';
      }

      // Load Category names and build mapping type -> categories
      final String categoriesJson = await rootBundle.loadString('assets/data/itemCategories.json');
      final List<dynamic> categoriesData = jsonDecode(categoriesJson);
      for (var category in categoriesData) {
        final int catId = (category['id'] ?? 0) is int ? category['id'] as int : int.parse((category['id'] ?? '0').toString());
        _categoryNames[catId] = category['name'] ?? '';

        // category may include "type": { "id": X, "name": "..." }
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
      // jika gagal, jangan crash — tampilkan di console
      // ignore: avoid_print
      print('Error loading filter data: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _removeTypeFilter(int typeId) {
    setState(() {
      _selectedTypeIds.remove(typeId);
      // optionally clear categories when removing a type? keep as-is
    });
  }

  void _removeCategoryFilter(int categoryId) {
    setState(() {
      _selectedCategoryIds.remove(categoryId);
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedTypeIds.clear();
      _selectedCategoryIds.clear();
      _searchController.clear();
    });
  }

  List<Product> _filterProducts(List<Product> products) {
    List<Product> filtered = products;

    // Filter by search query (name, type name, itemCategory name)
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((p) {
        final nameMatch = p.name.toLowerCase().contains(query);
        final typeMatch = (p.type?.name.toLowerCase().contains(query) ?? false);
        final itemCatMatch = (p.itemCategory?.name.toLowerCase().contains(query) ?? false);
        return nameMatch || typeMatch || itemCatMatch;
      }).toList();
    }

    // Category filtering logic:
    // 1) if user selected explicit category ids => use them
    // 2) else if user selected type ids => use all categories that belong to those types (from _categoryIdsByType)
    List<int> categoryFilterIds = [];

    if (_selectedCategoryIds.isNotEmpty) {
      categoryFilterIds = List.from(_selectedCategoryIds);
    } else if (_selectedTypeIds.isNotEmpty) {
      // gather categories for selected types
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFB71C1C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName ?? 'Produk',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar dan Filter Button
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Cari',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.tune, color: Colors.grey.shade700),
                        onPressed: () => _showFilterBottomSheet(context),
                      ),
                      if (_selectedTypeIds.isNotEmpty || _selectedCategoryIds.isNotEmpty)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFB71C1C),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Active Filters Display
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
                            color: Color(0xFFB71C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Type Chips
                      ..._selectedTypeIds.map((typeId) {
                        return _buildFilterChip(
                          label: _typeNames[typeId] ?? 'Type $typeId',
                          onRemove: () => _removeTypeFilter(typeId),
                        );
                      }),
                      // Category Chips
                      ..._selectedCategoryIds.map((categoryId) {
                        return _buildFilterChip(
                          label: _categoryNames[categoryId] ?? 'Kategori $categoryId',
                          onRemove: () => _removeCategoryFilter(categoryId),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

          // Product Grid
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductStateLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFB71C1C),
                    ),
                  );
                }

                if (state is ProductStateError) {
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

                if (state is ProductStateLoadedAllProduct) {
                  final filteredProducts = _filterProducts(state.allProduct);

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
                          if (_selectedTypeIds.isNotEmpty || _selectedCategoryIds.isNotEmpty)
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          // Navigate to product detail
                          Navigator.pushNamed(
                            context,
                            '/productDetail',
                            arguments: product.id.toString(),
                          );
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
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFDD835),
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
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.black87,
            ),
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
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return FilterProduct(
              selectedTypeIds: _selectedTypeIds,
              selectedCategoryIds: _selectedCategoryIds,
              onApplyFilter: (typeIds, categoryIds) {
                setState(() {
                  _selectedTypeIds = typeIds;
                  _selectedCategoryIds = categoryIds;
                });
              },
            );
          },
        );
      },
    );
  }
}
