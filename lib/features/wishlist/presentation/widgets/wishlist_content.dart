// lib/features/wishlist/presentation/widgets/wishlist_content.dart
import 'package:ekaplus_ekatunggal/constant.dart';
// import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_state.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/widgets/wishlist_empty_state.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/widgets/wishlist_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WishlistContent extends StatelessWidget {
  final String userId;

  const WishlistContent({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistBloc, WishlistState>(
      builder: (context, wishlistState) {
        if (wishlistState is WishlistLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }

        if (wishlistState is WishlistError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    wishlistState.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontFamily: AppFonts.primaryFont,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (wishlistState is WishlistLoaded) {
          if (wishlistState.items.isEmpty) {
            return const WishlistEmptyState();
          }

          return WishlistListView(
            userId: userId,
            wishlistItems: wishlistState.items,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}