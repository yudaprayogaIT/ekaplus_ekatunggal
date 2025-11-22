// lib/features/wishlist/presentation/widgets/wishlist_empty_state.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class WishlistEmptyState extends StatelessWidget {
  const WishlistEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const Spacer(),

            Icon(
              FontAwesomeIcons.solidHeart,
              size: 120,
              color: Color(0xffD43834),
            ),

            const SizedBox(height: 24),

            Text(
              'Wishlist Anda Masih Kosong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan produk favorit Anda untuk\nmengetahui produk lebih detail.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () => context.go('/'),
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
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.blackColor,
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
