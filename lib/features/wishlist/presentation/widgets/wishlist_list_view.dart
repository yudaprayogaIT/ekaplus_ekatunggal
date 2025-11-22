// lib/features/wishlist/presentation/widgets/wishlist_list_view.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/widgets/wishlist_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WishlistListView extends StatelessWidget {
  final String userId;
  final List<dynamic> wishlistItems;

  const WishlistListView({
    Key? key,
    required this.userId,
    required this.wishlistItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, productState) {
        if (productState is! ProductLoaded) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }

        final products = productState.products;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Pilih',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.primaryFont,
                  color: AppColors.blackColor,
                ),
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: wishlistItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final wishlistItem = wishlistItems[index];
                  
                  try {
                    final product = products.firstWhere(
                      (p) => p.id.toString() == wishlistItem.productId,
                    );

                    return WishlistItemCard(
                      userId: userId,
                      productId: product.id.toString(),
                      productName: product.name,
                      imagePath: _getProductImage(product),
                    );
                  } catch (e) {
                    return WishlistItemCard(
                      userId: userId,
                      productId: wishlistItem.productId,
                      productName: 'Product ID: ${wishlistItem.productId}',
                      imagePath: '',
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
}