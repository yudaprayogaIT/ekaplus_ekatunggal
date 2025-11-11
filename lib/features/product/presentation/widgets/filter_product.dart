// lib/features/product/presentation/widgets/filter_product.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ItemType {
  final int id;
  final String name;
  final String? image;
  final int disabled;

  ItemType({
    required this.id,
    required this.name,
    this.image,
    this.disabled = 0,
  });

  factory ItemType.fromJson(Map<String, dynamic> json) {
    return ItemType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'],
      disabled: json['disabled'] ?? 0,
    );
  }
}

class ItemCategory {
  final int id;
  final String name;
  final String? icon;
  final Map<String, dynamic>? type;
  final int disabled;

  ItemCategory({
    required this.id,
    required this.name,
    this.icon,
    this.type,
    this.disabled = 0,
  });

  factory ItemCategory.fromJson(Map<String, dynamic> json) {
    return ItemCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'],
      type: json['type'],
      disabled: json['disabled'] ?? 0,
    );
  }
}

class FilterProduct extends StatefulWidget {
  final List<int> selectedTypeIds;
  final List<int> selectedCategoryIds;
  final Function(List<int> typeIds, List<int> categoryIds) onApplyFilter;

  const FilterProduct({
    Key? key,
    this.selectedTypeIds = const [],
    this.selectedCategoryIds = const [],
    required this.onApplyFilter,
  }) : super(key: key);

  @override
  State<FilterProduct> createState() => _FilterProductState();
}

class _FilterProductState extends State<FilterProduct> {
  List<ItemType> allTypes = [];
  List<ItemCategory> allCategories = [];
  
  List<int> _selectedTypeIds = [];
  List<int> _selectedCategoryIds = [];
  
  bool _isTypeExpanded = true;
  bool _isKategoriExpanded = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedTypeIds = List.from(widget.selectedTypeIds);
    _selectedCategoryIds = List.from(widget.selectedCategoryIds);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load Item Types
      final String typesJson = await rootBundle.loadString(
        'assets/data/itemType.json',
      );
      final List<dynamic> typesData = jsonDecode(typesJson);
      allTypes = typesData
          .map((json) => ItemType.fromJson(json))
          .where((type) => type.disabled == 0)
          .toList();

      // Load Item Categories
      final String categoriesJson = await rootBundle.loadString(
        'assets/data/itemCategories.json',
      );
      final List<dynamic> categoriesData = jsonDecode(categoriesJson);
      allCategories = categoriesData
          .map((json) => ItemCategory.fromJson(json))
          .where((cat) => cat.disabled == 0)
          .toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading filter data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleType(int typeId) {
    setState(() {
      if (_selectedTypeIds.contains(typeId)) {
        _selectedTypeIds.remove(typeId);
      } else {
        _selectedTypeIds.add(typeId);
      }
    });
  }

  void _toggleCategory(int categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  void _resetFilter() {
    setState(() {
      _selectedTypeIds.clear();
      _selectedCategoryIds.clear();
    });
  }

  void _applyFilter() {
    widget.onApplyFilter(_selectedTypeIds, _selectedCategoryIds);
    Navigator.pop(context);
  }

  List<ItemCategory> _getCategoriesForType(int typeId) {
    return allCategories.where((cat) {
      return cat.type != null && cat.type!['id'] == typeId;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFB71C1C),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type Section
                        _buildExpandableSection(
                          title: 'Type',
                          isExpanded: _isTypeExpanded,
                          onToggle: () {
                            setState(() {
                              _isTypeExpanded = !_isTypeExpanded;
                            });
                          },
                          child: Column(
                            children: allTypes.map((type) {
                              final isSelected = _selectedTypeIds.contains(type.id);
                              return _buildCheckboxItem(
                                label: type.name,
                                isSelected: isSelected,
                                onChanged: (value) => _toggleType(type.id),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Kategori Section (grouped by selected types)
                        _buildExpandableSection(
                          title: 'Kategori',
                          isExpanded: _isKategoriExpanded,
                          onToggle: () {
                            setState(() {
                              _isKategoriExpanded = !_isKategoriExpanded;
                            });
                          },
                          child: Column(
                            children: _buildCategoryContent(),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Footer Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilter,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Hapus',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDD835),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Terapkan',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          child,
        ],
      ],
    );
  }

  Widget _buildCheckboxItem({
    required String label,
    required bool isSelected,
    required Function(bool?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isSelected,
              onChanged: onChanged,
              activeColor: const Color(0xFFB71C1C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.black87 : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryContent() {
    List<Widget> widgets = [];

    // Jika tidak ada type yang dipilih, tampilkan semua kategori
    if (_selectedTypeIds.isEmpty) {
      for (var category in allCategories) {
        widgets.add(
          _buildCategoryChip(
            label: category.name,
            isSelected: _selectedCategoryIds.contains(category.id),
            onTap: () => _toggleCategory(category.id),
          ),
        );
      }
    } else {
      // Tampilkan kategori berdasarkan type yang dipilih
      for (var typeId in _selectedTypeIds) {
        final type = allTypes.firstWhere(
          (t) => t.id == typeId,
          orElse: () => ItemType(id: 0, name: ''),
        );
        
        if (type.id == 0) continue;

        final categories = _getCategoriesForType(typeId);
        
        if (categories.isNotEmpty) {
          // Type label
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Text(
                type.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          );

          // Category chips
          widgets.add(
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
                return _buildCategoryChip(
                  label: category.name,
                  isSelected: _selectedCategoryIds.contains(category.id),
                  onTap: () => _toggleCategory(category.id),
                );
              }).toList(),
            ),
          );
        }
      }
    }

    if (widgets.isEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Tidak ada kategori tersedia',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDD835) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFDD835) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}