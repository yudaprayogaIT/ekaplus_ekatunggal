// lib/features/product/presentation/widgets/product_card.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_event.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final double width;
  final bool showWishlistButton;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.width = 180,
    this.showWishlistButton = true,
  }) : super(key: key);

  String _firstVariantImage(Product p) {
    try {
      if (p.variants.isNotEmpty) {
        final v = p.variants.first;
        final raw = (v as dynamic).image ?? '';
        if (raw is String && raw.isNotEmpty) {
          return raw.replaceFirst(RegExp(r'^/+'), 'assets/');
        }
      }
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _firstVariantImage(product);

    return BlocBuilder<AuthSessionCubit, AuthSessionState>(
      builder: (context, authState) {
        final isLoggedIn = authState is AuthSessionAuthenticated;
        final userId = isLoggedIn ? authState.user.id : null;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: width,
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(50, 50, 93, 0.177),
                    blurRadius: 5,
                    spreadRadius: -1,
                    offset: Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.137),
                    blurRadius: 3,
                    spreadRadius: -1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image with wishlist button overlay
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: imagePath.isNotEmpty
                            ? Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.image_not_supported),
                                ),
                              )
                            : const Center(child: Icon(Icons.image, size: 36)),
                      ),

                      // 🔥 Wishlist Button (Only show if logged in)
                      if (isLoggedIn && showWishlistButton && userId != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: BlocBuilder<WishlistBloc, WishlistState>(
                            builder: (context, wishlistState) {
                              bool isInWishlist = false;

                              if (wishlistState is WishlistLoaded) {
                                isInWishlist = wishlistState.isInWishlist(product.id.toString());
                              }

                              return GestureDetector(
                                onTap: () {
                                  // Toggle wishlist
                                  context.read<WishlistBloc>().add(
                                        ToggleWishlistItem(
                                          userId: userId,
                                          productId: product.id.toString(),
                                        ),
                                      );

                                  // Show snackbar feedback
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isInWishlist
                                            ? '❤️ Dihapus dari wishlist'
                                            : '💚 Ditambahkan ke wishlist',
                                      ),
                                      duration: const Duration(milliseconds: 800),
                                      backgroundColor: isInWishlist
                                          ? Colors.grey[700]
                                          : Colors.green,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isInWishlist
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 20,
                                    color: isInWishlist
                                        ? Colors.red
                                        : Colors.grey[600],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Product info
                  SizedBox(
                    height: 65,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product.name.length < 13) const Spacer(),
                                Text(
                                  product.name.toUpperCase(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Lihat',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor,
                                    fontFamily: AppFonts.secondaryFont,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              CupertinoIcons.arrow_right,
                              size: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}