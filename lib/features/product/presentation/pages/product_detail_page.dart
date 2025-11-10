// lib/features/product/presentation/pages/product_detail_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 💡 Import library CachedNetworkImage
// Asumsi import entitas dan bloc Anda:
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedVariantIndex = 0;
  Timer? _autoSlideTimer;
  final ScrollController _thumbnailScrollController = ScrollController();
  
  // ⚙️ CONFIG: Durasi auto-slide dalam detik (ubah sesuai kebutuhan)
  final int _autoSlideDuration = 3; 
  // ⚠️ Ganti dengan domain Anda yang sebenarnya
  final String _imageBaseUrl = 'https://your-domain.com';

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductEventGetDetailProduct(widget.productId));
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel(); 
    _thumbnailScrollController.dispose(); 
    super.dispose();
  }

  void _startAutoSlide(int variantsLength) {
    _autoSlideTimer?.cancel(); 
    
    _autoSlideTimer = Timer.periodic(Duration(seconds: _autoSlideDuration), (timer) {
      if (mounted) {
        setState(() {
          _selectedVariantIndex = (_selectedVariantIndex + 1) % variantsLength;
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
    _scrollToSelectedThumbnail(index);
    _startAutoSlide(variantsLength);
  }

  void _scrollToSelectedThumbnail(int index) {
    if (!_thumbnailScrollController.hasClients) return;

    const double itemWidth = 70.0 + 12.0; 
    const double padding = 16.0;
    
    final double offsetToStart = (index * itemWidth) + padding;
    
    final double screenWidth = MediaQuery.of(context).size.width;
    final double centerOffset = (screenWidth / 2) - (itemWidth / 2);
    
    double targetScroll = offsetToStart - centerOffset;
    
    final double maxScroll = _thumbnailScrollController.position.maxScrollExtent;
    final double minScroll = _thumbnailScrollController.position.minScrollExtent;
    
    // Logika Pengecualian (Item 0 dan 1)
    if (index <= 1) {
        targetScroll = minScroll;
    }
    
    final double finalScroll = targetScroll.clamp(minScroll, maxScroll);
    
    _thumbnailScrollController.animateTo(
      finalScroll,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 🆕 Widget yang menggunakan CachedNetworkImage
  Widget _buildMainImage(int variantId, String imagePath) {
    final String fullUrl = '$_imageBaseUrl$imagePath';
    final bool isPlaceholder = imagePath.isEmpty;

    if (isPlaceholder) {
      return Container(
          key: ValueKey<int>(variantId),
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 80,
              color: Colors.grey,
            ),
          ),
      );
    }
    
    return CachedNetworkImage(
        key: ValueKey<int>(variantId), // PENTING: Key unik untuk AnimatedSwitcher
        imageUrl: fullUrl,
        fit: BoxFit.contain,
        // 🚀 Placeholder saat loading
        placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[300]!),
            ),
        ),
        // ❌ Error Widget (fallback ke asset jika ada)
        errorWidget: (context, url, error) => Image.asset(
            'assets$imagePath', // Ganti dengan path asset yang sesuai jika ada
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
        ),
    );
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
        title: const Text(
          'Lihat Detail',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductStateLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductStateError) {
            // ... (Kode Error Anda)
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

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startAutoSlide(product.variants.length);
              _scrollToSelectedThumbnail(_selectedVariantIndex); 
            });

            final selectedVariant = product.variants[_selectedVariantIndex];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Gambar Utama dengan AnimatedSwitcher dan CachedNetworkImage
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                                child: child,
                              ),
                            );
                          },
                          // ➡️ Menggunakan _buildMainImage yang sudah Cached
                          child: _buildMainImage(selectedVariant.id, selectedVariant.image),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Thumbnail Gallery (Gambar Kecil) dengan CachedNetworkImage
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      controller: _thumbnailScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: product.variants.length,
                      itemBuilder: (context, index) {
                        final variant = product.variants[index];
                        final isSelected = index == _selectedVariantIndex;
                        final String thumbnailUrl = '$_imageBaseUrl${variant.image}';


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
                                    ? const Color(0xFFB71C1C)
                                    : Colors.grey[300]!,
                                width: isSelected ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: variant.image.isNotEmpty
                                  ? CachedNetworkImage( // 🚀 Thumbnail pakai CachedNetworkImage
                                        imageUrl: thumbnailUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(
                                            child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                        ),
                                        errorWidget: (context, url, error) => Image.asset(
                                            'assets${variant.image}', // Fallback asset
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, stack) {
                                                return const Icon(
                                                    Icons.image,
                                                    color: Colors.grey,
                                                );
                                            },
                                        ),
                                    )
                                  : const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Pilih Warna/Type Section (Tidak ada perubahan)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Builder(
                      builder: (context) {
                        final hasColors = product.variants.any((v) => v.color.isNotEmpty);
                        final String sectionLabel = hasColors ? 'Pilih Warna' : 'Pilih Type';
                        
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
                              children: product.variants.asMap().entries.map((entry) {
                                final index = entry.key;
                                final variant = entry.value;
                                final isSelected = index == _selectedVariantIndex;

                                final String displayText = hasColors 
                                    ? variant.color 
                                    : variant.type;

                                if (displayText.isEmpty) return const SizedBox.shrink();

                                return GestureDetector(
                                  onTap: () {
                                    _selectVariant(index, product.variants.length);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFFFC107)
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFFFA000)
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      displayText,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: Colors.black87,
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

                  // Item Name & Product Info (Tidak ada perubahan)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Item name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
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
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Kode', selectedVariant.code),
                        if (selectedVariant.type.isNotEmpty)
                          _buildInfoRow('Tipe', selectedVariant.type),
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}