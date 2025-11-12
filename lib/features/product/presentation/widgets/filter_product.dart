// lib/features/product/presentation/widgets/filter_product.dart
import 'dart:convert';
import 'package:ekaplus_ekatunggal/constant.dart';
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

      // Jika ada type yang terpilih, buang selected categories yang bukan anak dari type yang dipilih
      if (_selectedTypeIds.isNotEmpty) {
        _selectedCategoryIds = _selectedCategoryIds.where((catId) {
          final cat = allCategories.firstWhere(
            (c) => c.id == catId,
            orElse: () => ItemCategory(id: 0, name: ''),
          );
          final catTypeId = cat.type != null ? (cat.type!['id'] as int?) : null;
          return catTypeId != null && _selectedTypeIds.contains(catTypeId);
        }).toList();
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(left: 20, top: 10, right: 6),
            // decoration: BoxDecoration(
            //   border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            // ),
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
                    child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 5, left: 20, right: 20),
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
                            // Ubah children: allTypes.map... menjadi List.generate
                            children: List.generate(allTypes.length, (index) {
                              final type = allTypes[index];
                              final isSelected = _selectedTypeIds.contains(
                                type.id,
                              );

                              // Buat item checkbox
                              final checkboxItem = _buildCheckboxItem(
                                label: type.name,
                                isSelected: isSelected,
                                onChanged: (value) => _toggleType(type.id),
                              );

                              // Tambahkan Divider setelah item, kecuali jika itu item terakhir
                              if (index < allTypes.length) {
                                return Column(
                                  children: [
                                    checkboxItem,
                                    // Tambahkan Garis Pembatas (Divider) di sini
                                    const Divider(
                                      height: 20,
                                      thickness: 1,
                                      color: Colors.grey,
                                    ),
                                  ],
                                );
                              }

                              return checkboxItem;
                            }),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Kategori Section (grouped by selected types)
                        _buildExpandableSection(
                          title: 'Kategori',
                          isExpanded: _isKategoriExpanded,
                          onToggle: () {
                            setState(() {
                              _isKategoriExpanded = !_isKategoriExpanded;
                            });
                          },
                          child: Column(children: _buildCategoryContent()),
                        ),
                      ],
                    ),
                  ),
          ),

          // Footer Buttons
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilter,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      // side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Hapus',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Terapkan',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
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
                    fontSize: 12,
                    fontFamily: AppFonts.primaryFont,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[const SizedBox(height: 8), child],
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
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontFamily: AppFonts.primaryFont,
                color: isSelected ? Colors.black87 : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          // const SizedBox(width: 12),
          SizedBox(
            width: 16,
            height: 16,
            child: Checkbox(
              value: isSelected,
              onChanged: onChanged,
              activeColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryContent() {
    List<Widget> widgets = [];

    // Filter types yang memiliki kategori, dan urutkan berdasarkan abjad
    final typesWithCategories = allTypes.where((type) {
      return allCategories.any(
        (c) => c.type != null && (c.type!['id'] as int?) == type.id,
      );
    }).toList();

    // Mengurutkan Type berdasarkan nama (abjad)
    // typesWithCategories.sort((a, b) => a.name.compareTo(b.name));

    for (var type in typesWithCategories) {
      // Ambil kategori untuk type ini dan urutkan berdasarkan nama (abjad)
      final categories = allCategories
          .where((c) => c.type != null && (c.type!['id'] as int?) == type.id)
          .toList();

      // Mengurutkan Kategori di dalam Type berdasarkan nama (abjad)
      categories.sort((a, b) => a.name.compareTo(b.name));

      // Label type (Rata Kiri secara default karena parent Column/SingleChildScrollView)
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              type.name,
              style: const TextStyle(
                fontSize: 12, // Dibuat lebih besar sedikit
                fontWeight: FontWeight.w500,
                color: Colors.black87, // Dibuat lebih gelap
              ),
            ),
          ),
        ),
      );

      // Tentukan apakah kategori-kategori di section ini enabled:
      final bool sectionEnabled =
          _selectedTypeIds.isEmpty || _selectedTypeIds.contains(type.id);

      widgets.add(
        Container(
          width: double.infinity,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            children: categories.map((category) {
              final isSelected = _selectedCategoryIds.contains(category.id);
              return _buildCategoryChip(
                label: category.name,
                isSelected: isSelected,
                enabled: sectionEnabled,
                onTap: () {
                  if (sectionEnabled) _toggleCategory(category.id);
                },
              );
            }).toList(),
          ),
        ),
      );
    }

    // Tampilkan kategori tanpa type (jika ada) di bagian "Other" (opsional)
    final uncategorized = allCategories.where((c) => c.type == null).toList();

    // Mengurutkan Kategori "Other" berdasarkan nama (abjad)
    uncategorized.sort((a, b) => a.name.compareTo(b.name));

    if (uncategorized.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(
            'Other',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      );

      final bool sectionEnabled = _selectedTypeIds.isEmpty;

      // <<< Perbaikan juga untuk bagian uncategorized >>>
      widgets.add(
        Container(
          width: double.infinity,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            children: uncategorized.map((category) {
              final isSelected = _selectedCategoryIds.contains(category.id);
              return _buildCategoryChip(
                label: category.name,
                isSelected: isSelected,
                enabled: sectionEnabled,
                onTap: () {
                  if (sectionEnabled) _toggleCategory(category.id);
                },
              );
            }).toList(),
          ),
        ),
      );
    }

    if (widgets.isEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Tidak ada kategori tersedia',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final borderColor = isSelected
        ? const Color(0xFFFDD835)
        : (enabled ? Colors.grey.shade300 : Colors.grey.shade200);

    final bgColor = isSelected ? const Color(0xFFFDD835) : Colors.white;
    final textColor = isSelected ? Colors.black87 : Colors.grey.shade700;

    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );

    // Jika disabled, beri opacity & non-interaktif
    if (!enabled) {
      return Opacity(opacity: 0.5, child: child);
    }

    // enabled -> tappable
    return GestureDetector(onTap: onTap, child: child);
  }
}
