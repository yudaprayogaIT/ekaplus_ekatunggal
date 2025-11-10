// lib/features/category/presentation/pages/category_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryPage extends StatefulWidget {
  final String? initialCategory;
  const CategoryPage({Key? key, this.initialCategory}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> with TickerProviderStateMixin {
  // Track which type is expanded
  String? _expandedType;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(const CategoryEventGetAllCategories(1));
  }

  void _toggleExpand(String typeName) {
    setState(() {
      if (_expandedType == typeName) {
        _expandedType = null;
      } else {
        _expandedType = typeName;
      }
    });
  }

  String _shortTitleForType(String type) {
    final l = type.toLowerCase();
    if (l.contains('material')) return 'Material Springbed & Sofa';
    if (l.contains('furniture')) return 'Furniture';
    if (l.contains('sofa')) return 'Material Sofa';
    if (l.contains('mesin')) return 'Mesin & Spare Part';
    return type.split(' ').first._capitalize();
  }

  void _onCategoryTap(Category category) {
    // TODO: Navigate to product list with category filter
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membuka kategori: ${category.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Kategori',
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        toolbarHeight: 80,
        elevation: 0,
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryStateLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryStateError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  color: Colors.red,
                ),
              ),
            );
          }

          if (state is CategoryStateLoadedAllCategory) {
            final allCategories = state.allCategory;

            if (allCategories.isEmpty) {
              return const Center(child: Text('Belum ada kategori'));
            }

            // Group by type
            final Map<String, List<Category>> grouped = {};
            for (final cat in allCategories) {
              final typeName = cat.type?.name ?? 'Lainnya';
              grouped.putIfAbsent(typeName, () => []).add(cat);
            }

            // Ordered types (Material first, then Furniture, then others)
            final List<String> orderedTypes = [];
            if (grouped.keys.any((k) => k.toLowerCase().contains('material'))) {
              final k = grouped.keys.firstWhere((k) => k.toLowerCase().contains('material'));
              orderedTypes.add(k);
            }
            if (grouped.keys.any((k) => k.toLowerCase().contains('furniture'))) {
              final k = grouped.keys.firstWhere((k) => k.toLowerCase().contains('furniture'));
              orderedTypes.add(k);
            }
            if (grouped.keys.any((k) => k.toLowerCase().contains('sofa'))) {
              final k = grouped.keys.firstWhere((k) => k.toLowerCase().contains('sofa'));
              if (!orderedTypes.contains(k)) orderedTypes.add(k);
            }
            for (var k in grouped.keys) {
              if (!orderedTypes.contains(k)) orderedTypes.add(k);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                children: orderedTypes.map((typeName) {
                  final categories = grouped[typeName]!;
                  final isExpanded = _expandedType == typeName;

                  // Content widget (collapsed horizontal OR expanded grid)
                  final Widget content = isExpanded
                      ? Container(
                          key: ValueKey('expanded-$typeName'),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: categories.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.68,
                            ),
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              return GestureDetector(
                                onTap: () => _onCategoryTap(cat),
                                child: _CategoryTile(category: cat),
                              );
                            },
                          ),
                        )
                      : SizedBox(
                          key: ValueKey('collapsed-$typeName'),
                          height: 170,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: categories.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              return _CategoryTile(
                                category: cat,
                                width: 120,
                                onTap: () => _onCategoryTap(cat),
                              );
                            },
                          ),
                        );

                  // Animated wrapper for smooth transitions
                  final animated = ClipRect(
                    child: AnimatedSize(
                      key: ValueKey('size-$typeName'),
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeInOut,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 60),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          final offsetAnim = Tween<Offset>(
                            begin: Offset(0, isExpanded ? -0.02 : 0.0),
                            end: Offset.zero,
                          ).animate(animation);

                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(position: offsetAnim, child: child),
                          );
                        },
                        child: content,
                      ),
                    ),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row: Title + Lihat Semua button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _shortTitleForType(typeName),
                                style: TextStyle(
                                  fontFamily: AppFonts.primaryFont,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _toggleExpand(typeName),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                isExpanded ? 'Sembunyikan' : 'Lihat Semua',
                                style: TextStyle(
                                  fontFamily: AppFonts.primaryFont,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Animated content
                      animated,

                      const SizedBox(height: 18),
                    ],
                  );
                }).toList(),
              ),
            );
          }

          return const Center(child: Text('Tidak ada data'));
        },
      ),
    );
  }
}

/// Category tile dengan gambar full + label overlay di bawah
class _CategoryTile extends StatelessWidget {
  final Category category;
  final double? width;
  final VoidCallback? onTap;

  const _CategoryTile({
    required this.category,
    this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tileWidth = width ?? double.infinity;
    final tileHeight = width != null ? (width! / 0.68) : 180.0;

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: tileWidth,
        height: tileHeight,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.loose,
          children: [
            // Image background (full cover)
            _buildCategoryImage(category),

            // Bottom red label overlay
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            // Subtle gradient above label for better readability
            Positioned(
              left: 0,
              right: 0,
              bottom: 50,
              height: 36,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return SizedBox(
        width: width,
        child: GestureDetector(
          onTap: onTap,
          child: card,
        ),
      );
    } else {
      return SizedBox(width: width, child: card);
    }
  }

  Widget _buildCategoryImage(Category category) {
    final String? iconPath = category.icon;

    // No image - show placeholder
    if (iconPath == null || iconPath.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.category, size: 48, color: Colors.black38),
        ),
      );
    }

    // Network image (http/https)
    if (iconPath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: iconPath,
        fit: BoxFit.contain,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.broken_image, size: 48, color: Colors.black38),
          ),
        ),
      );
    }

    // Local asset image (png, jpg, webp)
    if (!iconPath.toLowerCase().endsWith('.svg')) {
      return Image.asset(
        iconPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.broken_image, size: 48, color: Colors.black38),
          ),
        ),
      );
    }

    // SVG fallback (requires flutter_svg package)
    // If you have flutter_svg installed, uncomment:
    // return SvgPicture.asset(
    //   iconPath,
    //   fit: BoxFit.cover,
    // );
    
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, size: 48, color: Colors.black38),
      ),
    );
  }
}

// Extension helper for capitalize
extension _Cap on String {
  String _capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}