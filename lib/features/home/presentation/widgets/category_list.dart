// lib/features/type/presentation/widgets/type_category_list.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/category/presentation/widgets/category_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/entities/type.dart';
import 'package:ekaplus_ekatunggal/features/type/presentation/bloc/type_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
// Import modal widget
// import 'package:ekaplus_ekatunggal/features/category/presentation/widgets/category_modal_widget.dart';

class TypeCategoryList extends StatelessWidget {
  final int page;

  const TypeCategoryList({Key? key, this.page = 1}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TypeBloc, TypeState>(
      bloc: BlocProvider.of<TypeBloc>(context)..add(TypeEventGetAllTypes(1)),
      builder: (context, state) {
        if (state is TypeStateLoading) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is TypeStateError) {
          return SizedBox(
            height: 120,
            child: Center(
              child: Text(
                state.message,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontFamily: AppFonts.primaryFont,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        if (state is TypeStateLoadedAllType) {
          final types = state.allType;
          final visible = types.length > 5 ? types.sublist(0, 5) : types;

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: AssetImage('assets/images/kategoribg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                // 🔹 Judul section
                const Text(
                  "Temukan Produk Yang Anda Cari",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 115,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final Type item = visible[index];

                      return GestureDetector(
                        onTap: () {
                          // Buka modal category dengan filter type
                          showCategoryModal(context);
                        },
                        child: SizedBox(
                          width: 72,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                child: _buildTypeImage(item),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Button "Lihat Semua"
                GestureDetector(
                  onTap: () {
                    // 🎯 BUKA MODAL CATEGORY
                    showCategoryModal(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTypeImage(Type item) {
    final String? imgPath = item.image;

    if (imgPath == null || imgPath.isEmpty) {
      return const Icon(Icons.category, size: 36);
    }

    // Network image -> gunakan CachedNetworkImage
    if (imgPath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imgPath,
        fit: BoxFit.contain,
        placeholder: (context, url) => const SizedBox(
          width: 24,
          height: 24,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) =>
            const Icon(Icons.broken_image, size: 36),
      );
    }

    // Local asset (png/jpg/webp) -> Image.asset
    if (!imgPath.toLowerCase().endsWith('.svg')) {
      return Image.asset(imgPath, fit: BoxFit.contain);
    }

    // Fallback untuk SVG
    return const Icon(Icons.image, size: 36);
  }
}