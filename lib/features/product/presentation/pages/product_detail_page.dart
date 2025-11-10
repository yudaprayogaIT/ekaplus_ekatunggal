// lib/features/product/presentation/pages/product_detail_page.dart

import 'dart:async';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({Key? key, required this.productId})
    : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedVariantIndex = 0;
  Timer? _autoSlideTimer;
  final ScrollController _thumbnailScrollController = ScrollController();

  // ⚙️ CONFIG: Durasi auto-slide dalam detik (ubah sesuai kebutuhan)
  final int _autoSlideDuration = 3;

  @override
  void initState() {
    super.initState();
    // Fetch product detail saat halaman dibuka
    context.read<ProductBloc>().add(
      ProductEventGetDetailProduct(widget.productId),
    );
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel(); // Batalkan timer saat widget dispose
    _thumbnailScrollController.dispose(); // Dispose scroll controller
    super.dispose();
  }

  void _startAutoSlide(int variantsLength) {
    _autoSlideTimer?.cancel(); // Cancel timer sebelumnya jika ada

    _autoSlideTimer = Timer.periodic(Duration(seconds: _autoSlideDuration), (
      timer,
    ) {
      if (mounted) {
        setState(() {
          _selectedVariantIndex = (_selectedVariantIndex + 1) % variantsLength;
          // Panggil fungsi scroll di sini agar auto-slide juga menggeser thumbnail
          _scrollToSelectedThumbnail(_selectedVariantIndex);
        });
      }
    });
  }

  void _stopAutoSlide() {
    _autoSlideTimer?.cancel();
  }

  void _selectVariant(int index, int variantsLength) {
    setState(() {
      _selectedVariantIndex = index;
    });
    // Scroll thumbnail ke posisi yang dipilih
    _scrollToSelectedThumbnail(index);
    // Restart timer setelah user manual select
    _startAutoSlide(variantsLength);
  }

  // 🎯 FUNGSI UTAMA YANG DIPERBAIKI
  void _scrollToSelectedThumbnail(int index) {
    if (!_thumbnailScrollController.hasClients) return;

    // Ukuran item thumbnail (lebar + margin)
    const double itemWidth = 70.0 + 12.0; // width 70 + margin right 12
    const double padding = 16.0;

    // Hitung offset yang diperlukan untuk item index berada di awal viewport
    final double offsetToStart = (index * itemWidth) + padding;

    // Hitung posisi tengah viewport
    final double screenWidth = MediaQuery.of(context).size.width;
    final double centerOffset = (screenWidth / 2) - (itemWidth / 2);

    // Target scroll untuk menengahkan item
    double targetScroll = offsetToStart - centerOffset;

    // Dapatkan batas scroll
    final double maxScroll =
        _thumbnailScrollController.position.maxScrollExtent;
    final double minScroll =
        _thumbnailScrollController.position.minScrollExtent;

    // LOGIKA PENGECUALIAN UNTUK DUA ITEM PERTAMA
    if (index <= 1) {
      // Jika item 0 atau 1, biarkan di posisi awal (tidak perlu digeser ke tengah)
      targetScroll = minScroll;
    }

    // Clamp nilai scroll agar tidak melebihi batas
    final double finalScroll = targetScroll.clamp(minScroll, maxScroll);

    // Animate scroll
    _thumbnailScrollController.animateTo(
      finalScroll,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  // ------------------------------------

  // Helper: build shimmer placeholder
  Widget _buildShimmer({double? width, double? height, BorderRadius? radius}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius ?? BorderRadius.zero,
        ),
      ),
    );
  }

  // Helper: full network url builder (sesuaikan jika base url berbeda)
  String _buildImageUrl(String rawPath) {
    if (rawPath.startsWith('/')) {
      return 'https://your-domain.com$rawPath';
    }
    return 'https://your-domain.com/$rawPath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Lihat Detail'),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductStateLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductStateError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(
                        ProductEventGetDetailProduct(widget.productId),
                      );
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is ProductStateLoadedProduct) {
            final product = state.detailProduct;

            if (product.variants.isEmpty) {
              return const Center(child: Text('Tidak ada varian tersedia'));
            }

            // Panggil _startAutoSlide DAN _scrollToSelectedThumbnail (0) setelah frame pertama dibuat
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startAutoSlide(product.variants.length);
              _scrollToSelectedThumbnail(
                _selectedVariantIndex,
              ); // Scroll ke item 0/pertama
            });

            final selectedVariant = product.variants[_selectedVariantIndex];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Utama dengan AnimatedSwitcher
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(50, 50, 93, 0.25),
                            blurRadius: 5,
                            spreadRadius: -1,
                            offset: Offset(0, 2),
                          ),
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.3),
                            blurRadius: 3,
                            spreadRadius: -1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.98, end: 1.0)
                                        .animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeInOut,
                                          ),
                                        ),
                                    child: child,
                                  ),
                                );
                              },
                          child: selectedVariant.image.isNotEmpty
                              ? CachedNetworkImage(
                                  key: ValueKey<int>(selectedVariant.id),
                                  imageUrl: _buildImageUrl(
                                    selectedVariant.image,
                                  ),
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => _buildShimmer(
                                    height: 300,
                                    radius: BorderRadius.circular(12),
                                  ),
                                  errorWidget: (context, url, error) {
                                    // fallback ke asset local (jika tersedia)
                                    final assetPath =
                                        'assets${selectedVariant.image}';
                                    return Image.asset(
                                      assetPath,
                                      fit: BoxFit.contain,
                                      errorBuilder: (ctx, err, stack) {
                                        return const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 80,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )
                              : Container(
                                  key: ValueKey<int>(selectedVariant.id),
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Thumbnail Gallery (Gambar Kecil) - gunakan CachedNetworkImage & shimmer placeholder
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      controller: _thumbnailScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: product.variants.length,
                      itemBuilder: (context, index) {
                        final variant = product.variants[index];
                        final isSelected = index == _selectedVariantIndex;

                        return GestureDetector(
                          onTap: () {
                            _selectVariant(index, product.variants.length);
                          },
                          child: Container(
                            width: 70,
                            height: 70,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.secondaryColor
                                    : Colors.grey[300]!,
                                width: isSelected ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: variant.image.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: _buildImageUrl(variant.image),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          _buildShimmer(
                                            width: 70,
                                            height: 70,
                                            radius: BorderRadius.circular(6),
                                          ),
                                      errorWidget: (context, url, error) {
                                        final assetPath =
                                            'assets${variant.image}';
                                        return Image.asset(
                                          assetPath,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) {
                                            return const Icon(
                                              Icons.image,
                                              color: Colors.grey,
                                            );
                                          },
                                        );
                                      },
                                    )
                                  : const Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Pilih Warna/Type Section - DINAMIS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Builder(
                      builder: (context) {
                        final hasColors = product.variants.any(
                          (v) =>
                              (v as dynamic).color != null &&
                              (v as dynamic).color.toString().isNotEmpty,
                        );
                        final String sectionLabel = hasColors
                            ? 'Pilih Warna'
                            : 'Pilih Type';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sectionLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: product.variants.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final variant = entry.value;
                                final isSelected =
                                    index == _selectedVariantIndex;

                                // Read color/type dynamically (some models may not have these fields)
                                final String displayText = (() {
                                  try {
                                    final dyn = variant as dynamic;
                                    if (hasColors &&
                                        dyn.color != null &&
                                        dyn.color.toString().isNotEmpty)
                                      return dyn.color.toString();
                                    if (!hasColors &&
                                        dyn.type != null &&
                                        dyn.type.toString().isNotEmpty)
                                      return dyn.type.toString();
                                  } catch (_) {}
                                  return '';
                                })();

                                if (displayText.isEmpty)
                                  return const SizedBox.shrink();

                                return GestureDetector(
                                  onTap: () {
                                    _selectVariant(
                                      index,
                                      product.variants.length,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.secondaryColor
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.secondaryColor
                                            : const Color(0x4DB1B0B0),
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      displayText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: Colors.black87,
                                        fontFamily: AppFonts.primaryFont,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Item Name & Product Info (Tetap sama)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Item name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            selectedVariant.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Kode', selectedVariant.code),
                        if ((selectedVariant as dynamic).type != null &&
                            (selectedVariant as dynamic).type
                                .toString()
                                .isNotEmpty)
                          _buildInfoRow(
                            'Tipe',
                            (selectedVariant as dynamic).type.toString(),
                          ),
                        if (product.category != null)
                          _buildInfoRow('Kategori', product.category!.name),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            );
          }

          return const Center(child: Text('Data tidak tersedia'));
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
