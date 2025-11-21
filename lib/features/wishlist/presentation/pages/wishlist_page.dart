// lib/features/wishlist/presentation/pages/wishlist_page.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_event.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  // 🔥 Ubah nomor WhatsApp di sini
  static const String whatsappNumber = '6285788837057'; // Ganti dengan nomor Anda
  static const String adminName = 'Admin Vika';

  @override
  void initState() {
    super.initState();
    // Load products untuk mendapatkan detail produk
    context.read<ProductBloc>().add(const ProductEventGetAllProducts(1)); // ✅ PERBAIKAN: Tambah parameter
  }

  // 🔥 Function untuk buka WhatsApp
   Future<void> _openWhatsApp(String productName) async {
    // Bersihkan nomor (hapus spasi, tanda +, dll)
    final cleanNumber = whatsappNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    final message = Uri.encodeComponent(
      'Halo $adminName, saya ingin menanyakan perihal produk $productName',
    );

    // 🔥 Coba beberapa format URL WhatsApp
    final List<String> whatsappUrls = [
      // Format 1: wa.me (paling universal)
      'https://wa.me/$cleanNumber?text=$message',
      
      // Format 2: api.whatsapp.com (web)
      'https://api.whatsapp.com/send?phone=$cleanNumber&text=$message',
      
      // Format 3: Deep link Android
      'whatsapp://send?phone=$cleanNumber&text=$message',
    ];

    bool successfullyOpened = false;

    // Coba buka satu per satu
    for (String url in whatsappUrls) {
      try {
        final uri = Uri.parse(url);
        
        // Check jika bisa dibuka
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          successfullyOpened = true;
          print('✅ WhatsApp opened with: $url');
          break; // Sukses, keluar dari loop
        }
      } catch (e) {
        print('⚠️ Failed to open with $url: $e');
        continue; // Coba URL berikutnya
      }
    }

    // Jika semua gagal
    if (!successfullyOpened && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('WhatsApp Tidak Tersedia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pastikan WhatsApp sudah terinstall di perangkat Anda.'),
              const SizedBox(height: 12),
              const Text('Nomor yang akan dihubungi:'),
              const SizedBox(height: 4),
              SelectableText(
                cleanNumber,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.primaryFont,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
            // 🔥 Tombol untuk buka Play Store / App Store
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final storeUrl = Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.whatsapp',
                );
                if (await canLaunchUrl(storeUrl)) {
                  await launchUrl(storeUrl, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('Install WhatsApp'),
            ),
          ],
        ),
      );
    }
  }

  // 🔥 Modal konfirmasi hapus
  void _showDeleteConfirmation(BuildContext context, String userId, String productId, String productName) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Apakah Anda yakin ingin menghapus item ini dari wishlist?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.primaryFont,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.primaryFont,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Hapus dari wishlist
                        context.read<WishlistBloc>().add(
                              ToggleWishlistItem(
                                userId: userId,
                                productId: productId,
                              ),
                            );
                        Navigator.pop(dialogContext);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$productName dihapus dari wishlist'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppFonts.primaryFont,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 Modal info lebih lanjut
  void _showInfoDialog(BuildContext context, String productName) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Apakah Anda ingin menanyakan produk ini langsung?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.primaryFont,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Info Lebih lanjut',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontFamily: AppFonts.primaryFont,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.primaryFont,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _openWhatsApp(productName);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Lanjutkan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppFonts.primaryFont,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<AuthSessionCubit, AuthSessionState>(
        builder: (context, authState) {
          // Check if user logged in
          final isLoggedIn = authState is AuthSessionAuthenticated;
          final userId = isLoggedIn ? authState.user.id : null;

          return Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                color: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SafeArea(
                  bottom: false,
                  child: Center(
                    child: const Text(
                      'Wishlist',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: isLoggedIn
                    ? _buildWishlistContent(userId!)
                    : _buildLockedState(),
              ),
            ],
          );
        },
      ),
    );
  }

  // 🔥 Locked State (User belum login)
  Widget _buildLockedState() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const Spacer(),
            
            // Icon
            SizedBox(
              width: 140,
              height: 140,
              child: Center(
                child: Image.asset(
                  'assets/images/wishlistIcon.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.favorite_border,
                    size: 120,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Text
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: 'Wishlist Anda Masih Kosong\n',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  TextSpan(
                    text: 'Tambahkan produk favorit Anda untuk mengetahui produk lebih detail.',
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Button
            ElevatedButton(
              onPressed: () {
                context.go('/');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.secondaryColor,
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Jelajahi Produk',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  // 🔥 Wishlist Content (User sudah login)
  Widget _buildWishlistContent(String userId) {
    return BlocBuilder<WishlistBloc, WishlistState>(
      builder: (context, wishlistState) {
        if (wishlistState is WishlistLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (wishlistState is WishlistError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  wishlistState.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        }

        if (wishlistState is WishlistLoaded) {
          if (wishlistState.items.isEmpty) {
            // Empty wishlist (tapi user sudah login)
            return _buildEmptyWishlist();
          }

          // Ada wishlist items
          return BlocBuilder<ProductBloc, ProductState>(
            builder: (context, productState) {
              if (productState is! ProductLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              final products = productState.products;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header "Pilih"
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Text(
                      'Pilih',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.primaryFont,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),

                  // List items
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: wishlistState.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final wishlistItem = wishlistState.items[index];
                        
                        // ✅ PERBAIKAN: Gunakan try-catch untuk handle product not found
                        try {
                          final product = products.firstWhere(
                            (p) => p.id.toString() == wishlistItem.productId,
                          );

                          return _buildWishlistItem(
                            context,
                            userId,
                            product.id.toString(),
                            product.name,
                            _getProductImage(product),
                          );
                        } catch (e) {
                          // ✅ Product tidak ditemukan, tampilkan placeholder
                          return _buildWishlistItem(
                            context,
                            userId,
                            wishlistItem.productId,
                            'Product ID: ${wishlistItem.productId}',
                            '',
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // Helper untuk get product image
  String _getProductImage(dynamic product) {
    try {
      if (product.variants != null && product.variants.isNotEmpty) {
        final variant = product.variants.first;
        final raw = (variant as dynamic).image ?? '';
        if (raw is String && raw.isNotEmpty) {
          return raw.replaceFirst(RegExp(r'^/+'), 'assets/');
        }
      }
    } catch (e) {
      print('⚠️ Error getting product image: $e');
    }
    return '';
  }

  // 🔥 Wishlist Item Widget
  Widget _buildWishlistItem(
    BuildContext context,
    String userId,
    String productId,
    String productName,
    String imagePath,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imagePath.isNotEmpty
                  ? Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported,
                        size: 40,
                      ),
                    )
                  : const Icon(Icons.image, size: 40),
            ),
          ),

          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.primaryFont,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Button Hapus
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showDeleteConfirmation(
                          context,
                          userId,
                          productId,
                          productName,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          side: BorderSide(color: Colors.grey[400]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontFamily: AppFonts.primaryFont,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Button Info Lebih Lanjut
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showInfoDialog(context, productName),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          backgroundColor: AppColors.secondaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Info Lebih Lanjut',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            fontFamily: AppFonts.primaryFont,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 Empty Wishlist (user sudah login tapi wishlist kosong)
  Widget _buildEmptyWishlist() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const Spacer(),
            
            // Icon
            Icon(
              Icons.favorite_border,
              size: 120,
              color: Colors.grey[400],
            ),

            const SizedBox(height: 24),

            // Text
            Text(
              'Wishlist Anda Masih Kosong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan produk favorit Anda untuk\nmengetahui produk lebih detail.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),

            const Spacer(),

            // Button
            ElevatedButton(
              onPressed: () {
                context.go('/');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.secondaryColor,
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Jelajahi Produk',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}