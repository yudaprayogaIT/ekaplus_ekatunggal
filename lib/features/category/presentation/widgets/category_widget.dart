// lib/features/category/presentation/widgets/category_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/bloc/category_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryModalWidget extends StatefulWidget {
  const CategoryModalWidget({Key? key}) : super(key: key);

  @override
  State<CategoryModalWidget> createState() => _CategoryModalWidgetState();
}

class _CategoryModalWidgetState extends State<CategoryModalWidget> {
  final DraggableScrollableController _dragController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    // Load data categories saat modal dibuka
    context.read<CategoryBloc>().add(const CategoryEventGetAllCategories(1));
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _dragController,
      initialChildSize: 0.85,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.3, 0.85, 0.95],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag indicator (draggable area)
              GestureDetector(
                onVerticalDragUpdate: (details) {
                  // Hitung perubahan posisi relatif terhadap tinggi layar
                  final screenHeight = MediaQuery.of(context).size.height;
                  final delta = -details.delta.dy / screenHeight;

                  // Update size dengan menambahkan delta
                  final currentSize = _dragController.size;
                  final newSize = (currentSize + delta).clamp(0.3, 0.95);

                  _dragController.jumpTo(newSize);
                },
                onVerticalDragEnd: (details) {
                  // Snap ke posisi terdekat saat drag selesai
                  final currentSize = _dragController.size;
                  final snapSizes = [0.3, 0.85, 0.95];

                  // Cari snap size terdekat
                  double closestSnap = snapSizes[0];
                  double minDistance = (currentSize - closestSnap).abs();

                  for (final snap in snapSizes) {
                    final distance = (currentSize - snap).abs();
                    if (distance < minDistance) {
                      minDistance = distance;
                      closestSnap = snap;
                    }
                  }

                  // Animate ke snap position
                  _dragController.animateTo(
                    closestSnap,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                },
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Header dengan judul dan kategori
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Semua Produk',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kategori',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.grey.shade300),
              const SizedBox(height: 8),

              // List Categories (scrollable dengan controller dari DraggableScrollableSheet)
              Expanded(
                child: BlocBuilder<CategoryBloc, CategoryState>(
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
                      final filteredCategories = allCategories;

                      // Group by type
                      final Map<String, List<Category>> grouped = {};
                      for (final cat in filteredCategories) {
                        final typeName = cat.type?.name ?? 'Lainnya';
                        grouped.putIfAbsent(typeName, () => []).add(cat);
                      }

                      final typeKeys = grouped.keys.toList();

                      if (typeKeys.isEmpty) {
                        return const Center(child: Text('Tidak ada kategori'));
                      }

                      return ListView.builder(
                        controller:
                            scrollController, // Penting: gunakan scrollController dari DraggableScrollableSheet
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        itemCount: typeKeys.length,
                        itemBuilder: (context, typeIndex) {
                          final typeName = typeKeys[typeIndex];
                          final categories = grouped[typeName]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Type Header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Text(
                                  typeName,
                                  style: TextStyle(
                                    fontFamily: AppFonts.primaryFont,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              // Category Items
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.black.withOpacity(0.04),
                                  //     blurRadius: 8,
                                  //     offset: const Offset(0, 2),
                                  //   ),
                                  // ],
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: categories.length,
                                  // separatorBuilder: (_, __) => Divider(
                                  //   height: 1,
                                  //   color: Colors.grey.shade200,
                                  // ),
                                  itemBuilder: (context, catIndex) {
                                    final category = categories[catIndex];
                                    return _buildCategoryItem(category);
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      );
                    }

                    return const Center(child: Text('Tidak ada data'));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(Category category) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Membuka kategori: ${category.name}'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            // Icon/Image Container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: _buildCategoryImage(category)),
            ),
            const SizedBox(width: 12),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category.description ?? '',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 12,
                      color: AppColors.grayColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryImage(Category category) {
    final String? imgPath = category.image;

    if (imgPath == null || imgPath.isEmpty) {
      return const Icon(Icons.category, size: 28, color: Colors.black54);
    }

    if (imgPath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imgPath,
        fit: BoxFit.contain,
        width: 32,
        height: 32,
        placeholder: (context, url) => const SizedBox(
          width: 20,
          height: 20,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) =>
            const Icon(Icons.broken_image, size: 28),
      );
    }

    if (!imgPath.toLowerCase().endsWith('.svg')) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          imgPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.category, size: 28),
        ),
      );
    }

    return const Icon(Icons.image, size: 28);
  }
}

// Helper function untuk show modal (UPDATED)
void showCategoryModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true, // 👈 Bisa ditutup dengan klik di luar
    enableDrag: true, // 👈 Bisa di-drag untuk menutup
    builder: (context) => GestureDetector(
      onTap: () => Navigator.pop(context), // 👈 Tutup saat tap di area kosong
      behavior: HitTestBehavior.opaque,
      child: GestureDetector(
        onTap: () {}, // 👈 Prevent tap dari propagate ke parent
        child: const CategoryModalWidget(),
      ),
    ),
  );
}

// 🎨 Alternatif dengan animasi custom yang lebih smooth
void showCategoryModalWithCustomAnimation(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierLabel: 'Kategori',
    barrierDismissible: true, // 👈 Klik di luar untuk menutup
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return const SizedBox.shrink(); // Placeholder
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      // Animasi slide dari bawah + fade in
      final slideAnimation =
          Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic, // 👈 Curve yang lebih smooth
            ),
          );

      final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        ),
      );

      // Animasi scale sedikit untuk efek "pop"
      final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack, // 👈 Efek "bounce" halus
        ),
      );

      return SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                alignment: Alignment.bottomCenter,
                child: const CategoryModalWidget(),
              ),
            ),
          ),
        ),
      );
    },
  );
}
